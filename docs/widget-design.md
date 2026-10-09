# Musicians iOS — Widget v1.1 Design Document

**"Musician of the Day" home-screen widget**

| | |
|---|---|
| **Status** | Design / research only — no code written |
| **Author** | Claude (autonomous research session) |
| **Date** | 2026-06-06 |
| **For** | Aurélien — review when you're back at the laptop |
| **Target app** | Jazzlore Musicians (`com.jazzlore.musicians`, Team `V78LBF2887`) |
| **Deployment target** | iOS 16.0 (confirmed in `musicians/ios/App/App.xcodeproj`) |
| **Capacitor** | 8.3.4 (confirmed in `musicians/package.json`) |

---

## 0. TL;DR — read this first

You want a home-screen widget that shows **one curated jazz musician per day** (portrait + name + one-line hook), and tapping it opens that musician's page in the Musicians app.

This is your **first real Swift / SwiftUI / WidgetKit work**. Capacitor genuinely cannot help: a widget is a separate iOS app-extension target that runs in its own process, written in Swift + SwiftUI, with no WebView, no React, no Capacitor runtime. The good news: SwiftUI is declarative and will feel familiar coming from React (views are a function of state; `@State`/`@Binding` ≈ `useState`/props).

**My headline recommendation for v1.1 is deliberately conservative**, because the biggest risk here is not the product — it's you fighting an unfamiliar toolchain on three fronts at once (Swift language, SwiftUI, WidgetKit) plus a fourth (Capacitor↔native data bridge). So I recommend you **cut the data-bridge front entirely for v1.1**:

> **Recommended v1.1 architecture: a fully self-contained Swift widget.** Bundle a **rotation pool of a few dozen musicians** (the 12 hand-curated core *plus* ~30–40 "surprise" picks sampled from your existing `polished-ids` pool — see §3) directly into the widget extension at build time: each record is id, name, fact, deep-link, and a pre-resized portrait. Pick today's musician with a **deterministic date-hash** so the widget never needs the network, never needs the app to have launched, and works offline forever. Rotation is computed in-process. Tap opens the app via a custom URL scheme.
>
> **You explicitly want surprises, and your repo already supports it for free:** `GET /api/musicians/polished-ids` returns the ~200 musicians that have **both a bio summary and a portrait** — i.e. "has a picture and enough data," exactly your bar. We sample a few dozen of those into the bundle. A ~50-musician pool means a **~50-day rotation cycle**: genuinely surprising, never sparse, still 100% offline.
>
> The "live App Group container written by the Capacitor app" pattern (the one your prompt frames as option (a)) is the **right long-term architecture** and I describe it fully — but I recommend **deferring it to v1.2**. It buys you the ability to refresh the curated list without an app release, at the cost of the hardest, least-familiar piece of work in the whole project. Don't pay that cost on your first Swift project.

Everything below justifies that recommendation and gives you what you need to make the call yourself.

---

## 1. WidgetKit fundamentals

### 1.1 What WidgetKit is

WidgetKit (introduced iOS 14, matured heavily through iOS 17/18) is the framework for building home-screen, lock-screen, and StandBy widgets. **Widgets are built entirely in SwiftUI** — there is no UIKit escape hatch for the widget's view body. A widget is not a mini-app; it is a **timeline of pre-rendered snapshots**. WidgetKit asks your code for a set of "what should I show, and at what time" entries, renders them ahead of time, and then displays them on a schedule. Your widget code is **not running** while the user looks at it — only when WidgetKit decides to regenerate the timeline.

This "render-ahead, not live" model is the single most important mental shift from web. There is no event loop, no `useEffect`, no live data binding while the widget is on screen. You hand the system a filmstrip; it plays frames.

### 1.2 Widget sizes and home-screen real estate

| Family | Grid footprint (typical 6×4 home screen) | Fits "4 icons"? | Tap zones |
|---|---|---|---|
| `.systemSmall` | 2×2 — **the space of 4 app icons** | ✅ exactly your framing | **One** tap target only (whole widget) |
| `.systemMedium` | 4×2 — 8 icons | larger | Multiple tap zones via `Link` |
| `.systemLarge` | 4×4 — 16 icons | much larger | Multiple tap zones |
| `.systemExtraLarge` | iPad only | n/a | Multiple |
| `.accessoryRectangular` / `.accessoryCircular` / `.accessoryInline` | Lock-screen / StandBy | n/a | One |

Your framing — *"takes the space of 4 icons"* — **is exactly `.systemSmall` (2×2)**. That is the right primary target. A small widget has exactly **one tap target**, which is perfect for "tap → open this musician." (Medium/large can have multiple `Link` regions; small widgets must use the single `widgetURL(_:)` modifier — see §4.5.)

### 1.3 How widgets refresh: the timeline model

Three protocols you implement:

- **`TimelineEntry`** — a value type with a `date` and whatever data the view needs to render one frame. For us: `MusicianEntry { date, musicianID, name, hook, portrait, deepLink }`.
- **`TimelineProvider`** (static) or **`AppIntentTimelineProvider`** (configurable, iOS 17+) — supplies entries. Three methods:
  - `placeholder(in:)` — instant, dataless skeleton shown in the widget gallery and while loading. Must be synchronous and cheap.
  - `snapshot(in:completion:)` — a single representative entry for the gallery preview. Should be fast; can use sample data.
  - `timeline(in:completion:)` — the real array of entries + a **reload policy**.
- **`Timeline`** — `Timeline(entries: [...], policy: ...)`.

**Reload policies** (`TimelineReloadPolicy`):

| Policy | Meaning | Fit for "musician of the day" |
|---|---|---|
| `.atEnd` | Ask for a new timeline after the last entry's date passes. | OK fallback |
| `.after(date)` | Ask for a new timeline no earlier than `date`. | Reasonable |
| `.never` | Never auto-refresh; only `WidgetCenter.shared.reloadTimelines(ofKind:)` from the app triggers a reload. | Used in the App Group pattern |

**The key trick for a daily widget:** you do *not* need a daily background wake-up. Pre-compute **one entry per day for the next N days** in a single `timeline(...)` call, each with `date` set to midnight of that day. WidgetKit will automatically flip to the next entry at each midnight **with zero code running at midnight**. Set the policy to `.atEnd` so when the N days run out, it regenerates. This is the canonical pattern and it sidesteps the refresh-budget problem below almost entirely.

**Refresh budget (important constraint):** the system throttles how often it will actually *call your provider*. In practice a widget gets roughly **40–70 provider invocations per day** (≈ one every 15–60 min), and the system — not you — decides timing. `.after(midnight)` is a *request*, not a guarantee. This is exactly why the "pre-compute N days of midnight-stamped entries in one shot" approach is correct: it doesn't depend on the system waking you up on time. ([Apple: Keeping a widget up to date](https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date))

### 1.4 Widget bundle structure inside the Xcode project

A widget is a **separate target** — an App Extension — inside the same `.xcodeproj`. When you add it (Xcode → File → New → Target → *Widget Extension*), Xcode creates:

```
musicians/ios/App/
  App.xcodeproj
  App/                      ← existing Capacitor host app target
    ...
  MusicianWidget/           ← NEW widget extension target
    MusicianWidget.swift           (the @main WidgetBundle + Widget definition)
    Provider.swift                 (TimelineProvider/AppIntentTimelineProvider)
    MusicianEntryView.swift        (the SwiftUI view)
    Assets.xcassets                (widget's own asset catalog)
    Info.plist
    MusicianWidget.entitlements     (App Groups go here, in v1.2)
```

Key facts:
- The extension has its **own bundle ID**, conventionally `com.jazzlore.musicians.MusicianWidget`, and its own Info.plist, deployment target, and code-signing. It ships *inside* the main app's `.app` bundle — one App Store submission, not two.
- The extension does **not** link your Capacitor/SPM code and should not. Keep it tiny.
- Note your project uses **CapApp-SPM** (Swift Package Manager) for the Capacitor host. The widget target is independent of that package; don't try to share the SPM target with it.

### 1.5 "Runs in its own process" — what it means concretely

The widget is a distinct executable launched by the iOS WidgetKit host (`chronod`/`PlugInKit`), **not** by your app. Consequences:

- ❌ No `window`, no DOM, no React, no JS, no Capacitor plugins, no WebView.
- ❌ No access to the app's in-memory state or the WebView's `localStorage`/`IndexedDB`. The PWA's data is invisible to the widget.
- ✅ The only ways to share data app→widget: **(1)** a shared **App Group** container (files + a shared `UserDefaults` suite), **(2)** bundling data into the widget at build time, or **(3)** the widget fetching from the network itself.
- ✅ The widget can open the app via a URL; the app can tell the widget to reload via `WidgetCenter`.

This process boundary is *the* reason your prompt's framing is correct: "Capacitor cannot help here." It can't. The widget is pure native iOS.

### 1.6 Static vs configurable widgets

- **`StaticConfiguration`** — no user customization. The widget shows what your provider decides. *This is what "musician of the day" wants.*
- **`AppIntentConfiguration`** (iOS 17+) / `IntentConfiguration` (iOS 16) — user long-presses → *Edit Widget* → picks options (e.g. "which era?" or "which musician?"). Backed by an `AppIntent` (iOS 17) or an Intents-framework `INIntent` (iOS 16). More code, more concepts.

Recommendation: **`StaticConfiguration` for v1.1.** Configurability is a §6 decision but my strong lean is *static* — a daily rotation is, by definition, the system choosing for the user; that's the whole charm.

### 1.7 Interaction model

- **Tap-to-open (all you need):** `.widgetURL(url)` on a small widget, or `Link(destination:)` regions on medium/large. Tapping launches the app with that URL, which you handle in the Capacitor shell to navigate to the musician page (see §4.5). Works on **iOS 16+**.
- **Interactive widgets (iOS 17+):** buttons/toggles *inside* the widget that run an `AppIntent` without leaving the home screen (e.g. a "next musician" button, a "favorite" toggle). Richer, but iOS 17+ only and more to learn. Not needed for v1.1.

### 1.8 Memory & execution constraints (this will bite you if ignored)

- **Hard ceiling ≈ 30 MB resident memory** for a widget extension. Exceed it → the system **jetsams** (kills) the extension and the user sees a blank/placeholder widget. This is the #1 cause of "my widget is blank" bug reports. ([Apple feedback FB8832751](https://github.com/feedback-assistant/reports/issues/177))
- A **full-resolution portrait JPEG decoded into a `UIImage` can easily blow the entire 30 MB budget by itself.** A 3000×3000 photo decodes to ~36 MB of bitmap. This is why image pre-sizing (§5.2) is non-negotiable.
- Provider execution is **time-boxed** (a few seconds). No long work, no big synchronous downloads on the main path.
- Apple's own guidance for widget images: prefer **URL-backed file images you've already downloaded and resized**, resize with `UIImage.preparingThumbnail(of:)`, and **never** use `Data(contentsOf:)` to pull from the network inline. ([Apple Developer Forums: WidgetKit memory](https://developer.apple.com/forums/thread/650204))

---

## 2. Data-flow architecture — three patterns compared

The app/PWA is the source of truth for "which musicians, what data, what fact." The widget runs in a separate process and cannot read the WebView's storage. Here are the three patterns from your prompt, plus the one I actually recommend.

### Pattern (a) — Shared App Group container, app pre-computes a schedule

The Capacitor app, on launch, writes the next N days of musician-of-the-day data (id, name, hook, portrait file, deep-link) into a shared **App Group** container that both processes can read. The widget reads from the container on its refresh schedule.

```
[Capacitor PWA in WebView]
        │  (needs a NATIVE bridge — JS can't touch the container directly)
        ▼
[capacitor-widget-bridge plugin]  ── setItem(group, key, json) ──▶ shared UserDefaults suite
                                  ── writes portrait files ─────▶ App Group container dir
                                  ── reloadAllTimelines() ──────▶ WidgetCenter
        ▼
[group.com.jazzlore.musicians]  (sandboxed dir + UserDefaults suite, readable by both)
        ▲
[MusicianWidget process]  ── reads JSON + portrait files on each timeline() call
```

- **Complexity:** *High for you specifically.* Requires: enable App Groups capability on **both** targets, add a native bridge plugin (see §2.5), write JSON from JS, and — the sharp edge — **get portrait image files into the container**. The community plugin handles `UserDefaults` strings well but image-file writing is under-documented (§2.5). You'll likely write a small custom Capacitor plugin for the image files. That's Swift work *and* Capacitor-plugin work on your first Swift project.
- **Offline:** ✅ Excellent once written — pure local reads.
- **Freshness:** ✅ Good — the curated list can change and the widget updates next time the app runs (then `reloadAllTimelines()`).
- **Cost:** ~3–5 days *on top of* the Swift learning curve, mostly fighting the image-file bridge.

### Pattern (b) — Network-fetching widget

The widget's `timeline(...)` calls `URLSession` against the BFF (`https://musicians.jazzlore.com/api/musicians/curated`) on each refresh, downloads the portrait, builds the entry.

- **Complexity:** Medium Swift, but introduces real failure surface in a constrained process.
- **Offline:** ❌ First render with no cache = blank/placeholder. Widgets are *expected* to render offline.
- **Freshness:** ✅ Always live — but you don't need "live" for a hand-reviewed pool of a few dozen historical figures whose facts never change.
- **Backend note (cold-start mitigated):** Neo4j Aura auto-pauses after ~3 days idle (the `waking` 503 state in `useMusicianData.ts` exists for this), but **Aurélien runs a cron that wakes the instance every 48 h**, so it should never be cold for a daily widget refresh. Cold-start is therefore *not* the reason to avoid this pattern. The real reasons stand on their own: a widget's provider is time-boxed to a few seconds, network calls add a transient-failure + offline surface (a dropped request = blank widget), and **you simply don't need "live" data for a few dozen essentially-static historical figures.** Paying network fragility to keep a fixed pool fresh is a bad trade — and when you *do* want to grow the pool, you re-run the build script and ship a point release.
- **Cost:** Medium, but high *ongoing* fragility for zero freshness benefit on a static set. **Not recommended.**

### Pattern (c) — Hybrid (local cache + occasional network refresh)

Widget reads a local cache (App Group) for instant/offline render, and *opportunistically* refreshes from the BFF when it gets a provider call and the cache is stale.

- **Complexity:** Highest — it's (a) **plus** (b) **plus** cache-invalidation logic.
- **Offline:** ✅ Good (falls back to cache).
- **Freshness:** ✅ Good.
- **Cost:** Highest. This is the "correct enterprise answer" and the **wrong** first-Swift-project answer. Over-engineered for a few-dozen static pool.

### Pattern (d) — **[RECOMMENDED for v1.1]** Build-time bundled, self-contained widget

Treat the rotation pool as **static editorial content shipped with the binary**. At build time you bake into the widget target's asset catalog: a few dozen pre-resized portraits (§5.2) and a small JSON (id, name, fact, deep-link). The pool = the 12 hand-curated core + a few dozen sampled from `polished-ids` (§3). The widget computes "today's musician" by **date-hash** (§4.5) entirely in-process. No App Group, no network, no Capacitor bridge.

- **Complexity:** **Lowest.** Pure SwiftUI + a tiny provider. This is essentially the WidgetKit "hello world" plus your real data and a date hash. It is the *ideal* shape for a learning project.
- **Offline:** ✅ Perfect — there is no online.
- **Freshness:** ⚠️ The pool (and portraits) only change with an app release. **For a hand-reviewed set of a few dozen canonical/polished jazz figures, this is completely acceptable** — these are historical musicians whose facts don't change; you re-run the build script and ship a point release if you want to grow or reshuffle the pool. Not a hot-fix scenario.
- **Pool size vs bundle/memory:** bundling ~50 portraits at ~512² JPEG (~80–150 KB each) adds only ~5–7 MB to the app download — trivial. Crucially, the **30 MB widget runtime limit is per-render** (one portrait decoded at a time), so a *larger pool does not raise jetsam risk* — only the single displayed image's size matters (§4.3). You could bundle a few hundred before download size becomes a conversation.
- **First-install correctness:** ✅ Works the instant the widget is added, even if the app has *never been launched* — a real gotcha that bites patterns (a)/(c), and that App Review will hit (§9).
- **Cost:** ~1–2 days beyond hello-world. Conceptually it *is* Pattern (a) with the container frozen at build time — so it's a clean stepping stone, not a throwaway.

### 2.5 The Capacitor↔App Group bridge reality (why (a) is hard *for this stack*)

Researched and confirmed:

- **`@capacitor/preferences` will NOT do it.** Its `group` config option is just a **key prefix** on standard `UserDefaults` — it does *not* write to a shared App Group suite. Widely reported. ([Capacitor discussion #7560](https://github.com/ionic-team/capacitor/discussions/7560), [capacitor-plugins #226](https://github.com/ionic-team/capacitor-plugins/issues/226))
- **`capacitor-widget-bridge`** is the purpose-built community plugin: `setItem/getItem/removeItem` against a shared `UserDefaults` suite, plus `reloadAllTimelines()` / `reloadTimelines(ofKind:)`. It **requires Capacitor 8.x** — you're on **8.3.4**, so it's compatible. ([libraries.io](https://libraries.io/npm/capacitor-widget-bridge)) **But** its docs do *not* specify image/binary handling — it's a `UserDefaults` string bridge. Portraits (files) likely need a small custom plugin or base64-in-UserDefaults (ugly, and base64 in `UserDefaults` risks the 30 MB widget budget on read).

**This is the crux of why I defer (a) to v1.2.** The string bridge is easy; the *image* bridge is the unfamiliar, under-documented part, and it's exactly the kind of thing that turns a 2-day task into a 2-week yak-shave on a first Swift project. (Flagged as an open question in §10.)

### 2.6 Recommendation

> **v1.1: Pattern (d) — self-contained bundled widget with date-hash rotation.**
> **v1.2: migrate to Pattern (a)** — once you're fluent in Swift and want to update the curated set without an app release. Because (d) already models the data shape exactly as (a)'s container would, the migration is "swap the data source," not a rewrite.

Skip (b) and (c) entirely. (b) adds network fragility for zero freshness benefit on a static pool (and even though the 48 h keep-warm cron removes the cold-start risk, the offline/transient-failure surface remains), and (c) is over-engineering for a few-dozen static figures.

---

## 3. Where the data actually comes from (grounding in your repo)

You already have everything the widget needs — including the broader "surprise" pool — it's just on the wrong side of the process boundary today. There are **two tiers** of source data:

**Tier 1 — the 12 hand-curated core** (`~/Developer/jazzlore/apps/musicians/src/data/curated.ts`, `CURATED: CuratedPick[]`):
- `id` — canonical `wikidata:Q…` (e.g. Miles Davis = `wikidata:Q93341`)
- `hook` — a **hand-written one-line editorial fact**, perfect for the widget ("Reinvented jazz five times and never looked back.")
- Hydrated to live name/portrait/subtitle via `GET /api/musicians/curated` → `CuratedCard { id, name, hook, subtitle, photo, portrait }`.

**Tier 2 — the "polished" pool for surprises** (this is the piece that makes your "few dozen" ask cheap):
- `GET /api/musicians/polished-ids` → `{ ids: string[] }` — **the ~200 musicians that have BOTH a bio summary AND a portrait.** Documented in `useMusicianData.ts` as the subset built precisely so Random Jump never drops a user on a sparse musician. **This is your "has a picture and enough data" filter, already implemented server-side.**
- `GET /api/musicians/by-ids?ids=…` (≤20 per call) → `{ items: MusicianMinimal[] }` with `{ id, name, photo, portrait, primaryInstrument }` — cheap batch hydrate for names + portraits.
- `GET /api/musicians/:id` → full `MusicianDetail` with `bioSummary`, `primaryInstruments`, `era`, `birthYear`/`deathYear`, `portrait` — use this when you want a richer derived fact line (§4 fact model).

**Shared facts:**
- **Portraits** are external (Wikimedia-style) images at `portrait.url`, each carrying its own **license + attribution** — relevant for widget display and App Review (§9). *Note: a few-dozen pool means a few-dozen distinct licenses to clear — see §10.*
- **Deep-link target** is the web route `GET /musicians/:id` (`App.tsx`: `<Route path="/musicians/:id" element={<MusicianPage/>}/>`), id URL-encoded (`wikidata:Q93341` → `wikidata%3AQ93341`).

**Practical build-time pipeline for Pattern (d)** — a Node script in the web monorepo (alongside `scripts/generate-splash-masters.mjs`):
1. Read `CURATED` (the 12, with hooks) → tier-1 records.
2. `GET /api/musicians/polished-ids` → ~200 candidates. **Sample ~30–40** (random with a *fixed seed* for reproducible builds, or hand-pick — see §3.1) and `by-ids`/detail-hydrate them → tier-2 records.
3. For tier-2, **derive a fact line** (instrument + era + life-years, or trimmed `bioSummary` — §4 fact model). Tier-1 keeps its hand-written `hook`.
4. Download each portrait, square-crop + resize to ~512², write images + a single `musicians.json` (the merged pool, with a `source: "curated" | "polished"` tag per record) into the widget target's asset catalog.
5. Run manually when you want to grow/reshuffle the pool. Neo4j stays the single source of truth; the build freezes a snapshot into the binary.

### 3.1 Curating the surprise pool (one editorial decision worth making)

Because the pool is **bundled** (not live), you get to *see exactly what ships* — so a quick human pass over the sampled ~30–40 is cheap and high-value. The `polished-ids` filter (bio + portrait) guarantees no *empty* cards, but it does **not** guarantee every portrait is flattering, correctly attributed, or genuinely jazz-famous (the DB has ~2,000+ musicians; "polished" just means "has bio + photo"). Recommended build-script guardrails on top of `polished-ids`, then a 10-minute eyeball:
- require `primaryInstruments` non-empty **and** (`birthYear` present **or** `era` present) so the derived fact line is never threadbare;
- de-dupe against the 12 core;
- optionally pin a hand-picked allowlist of ~40 "second-tier greats" (Blakey-era sidemen, etc.) instead of random sampling, for full editorial control. *This is a §5 decision (#3).*

---

## 4. Data model for "musician of the day"

### 4.1 The cached/bundled record

```swift
struct WidgetMusician: Codable, Identifiable {
    let id: String          // "wikidata:Q93341" — canonical, also the deep-link key
    let name: String        // "Miles Davis" (hydrated from BFF at build time)
    let fact: String        // tier-1: hand-written hook; tier-2: derived line (§4.6)
    let imageName: String   // asset-catalog name OR container-relative filename
    let source: Source      // .curated | .polished — lets the UI/analytics distinguish
    // deep link is DERIVED from id at render time — don't store the full URL
    enum Source: String, Codable { case curated, polished }
}
```

The whole **pool** is the bundled `[WidgetMusician]` (the merged tier-1 + tier-2 records from §3). The widget loads it once per `timeline(...)` and date-hashes into it (§4.5).

Plus a `TimelineEntry`:

```swift
struct MusicianEntry: TimelineEntry {
    let date: Date          // midnight of the day this entry represents
    let musician: WidgetMusician
}
```

### 4.2 What to show in `.systemSmall`

A 2×2 small widget is tight. Prioritize ruthlessly:

1. **Portrait** as the background or the dominant top region.
2. **Name** — bold, 1 line, truncating.
3. **Fact** — 2 lines max, smaller. For the 12 core this is the hand-written `hook`; for the surprise picks it's the derived line (§4.6). Both read as one short, interesting line.

Optional: a tiny "TODAY" / date pill, or a small sax/note glyph. Keep attribution **out** of the small widget face (no room) — handle license compliance via the bundled-image provenance and the in-app page (§9).

### 4.6 The fact line — a two-tier model (new, because of the broader pool)

The 12 core have hand-written hooks. The ~30–40 surprise picks do **not** — so derive their fact line at build time from structured fields, which is more reliable than slicing prose:

- **Recommended (structured, consistent):** `"<primary instrument> · <era> · <birth>–<death>"` → e.g. `"Tenor saxophone · Hard bop · 1926–1967"`. Always one tidy line, never awkward mid-sentence truncation, and the data (`primaryInstruments[0]`, `era`, `birthYear`/`deathYear`) is exactly what `MusicianDetail` carries.
- **Alternative (prose):** first sentence of `bioSummary`. More "interesting" but variable length, can truncate mid-clause, and quality varies across 200 musicians. Riskier on a 2×2 surface.
- **Stretch (best of both):** hand-write hooks for the surprise pool too. Highest editorial quality, real ongoing effort. Since the pool is bundled and you review it anyway (§3.1), you *could* write ~40 hooks once — but don't gate v1 on it.

**Recommendation:** structured derived line for tier-2, hand-written hook for tier-1, both stored in the same `fact` field so the view doesn't branch.

### 4.3 Image sizing — the make-or-break detail

- **Resize at build time** (Pattern d) or **in the Capacitor app before writing** (Pattern a) — **never** decode a full-res image inside the widget. The 30 MB jetsam limit (§1.8) means a single large portrait kills the widget.
- **Target size:** `.systemSmall` renders at roughly 158×158 pt → ~474×474 px at @3x. **Resize to ~512×512 (or 640×640 for headroom), JPEG quality ~0.8.** That's ~50–150 KB on disk and a few MB decoded — comfortably under budget. Going bigger buys nothing on a 2×2 surface.
- **Square crop** the portraits (center or face-aware) so the small-widget layout is predictable.
- Where resizing happens: **build-time Node script** (Pattern d) using `sharp` (you likely already have it for splash/icon work), or `UIImage.preparingThumbnail(of:)` in the app before write (Pattern a). Build-time is simpler and keeps the widget dumb.

### 4.4 Schedule depth (how many days to pre-compute)

For Pattern (d) the "schedule" is virtual — the date-hash (§4.5) makes *every* day computable on demand, so you generate entries lazily. Practically, generate **~7 days** of midnight-stamped entries per `timeline(...)` call with `.atEnd`. Seven is plenty: it covers a week of WidgetKit not bothering to call you, and regenerates cheaply. (For Pattern a, 7–14 days of pre-written records is a fine cache depth; 30 is overkill and just costs container space.)

### 4.5 Rotation logic — "today's musician"

**Recommended: deterministic date-hash.**

```swift
func musicianForDay(_ date: Date, in list: [WidgetMusician]) -> WidgetMusician {
    let cal = Calendar.current
    let day = cal.ordinality(of: .day, in: .era, for: date) ?? 0  // days since reference
    return list[day % list.count]
}
```

- Cycles through the whole pool in order, repeating every `N` days (`N` ≈ 40–50). Deterministic → the widget, the app, and any future surface all agree on "today's musician" with zero shared state. This is *why* deterministic beats random: no need to persist "what did we show yesterday."
- **vs random-no-repeat:** random needs persisted history (which musician on which day) to avoid repeats — shared state you'd have to store and sync. With a ~50-item pool the fixed cycle is ~50 days long, so it already *feels* surprising; the "looks like a march" problem that mattered at N=12 basically vanishes. Still, store the pool in a **build-time shuffled order** (interleave the 12 core among the surprises so a banger lands every few days rather than all 12 up front) for a good cadence.
- **Want the core to appear more often?** Weight it: build the rotation array with each tier-1 musician inserted 2–3× and each tier-2 once, then `index % array.count`. Still deterministic and stateless — just a longer pre-expanded array baked at build time.

**Recommendation:** date-hash into a **build-time shuffled, lightly core-weighted** pool array. Deterministic, stateless, surprising, and the greats still surface regularly.

---

## 5. Decisions you need to make (your call — recommendations included)

Each of these is genuinely yours; I give a recommendation and the reasoning, but flag them as decisions because they're product/taste calls, not technical necessities.

| # | Decision | Options | My recommendation | Why |
|---|---|---|---|---|
| 1 | **Widget size** | small / medium / large / multi | **`.systemSmall` only** for v1.1 | Matches your "4 icons" framing exactly; one tap target = clean "tap → open"; least layout work. Add medium in v1.2 if wanted. |
| 2 | **Configurable or static** | static / configurable | **Static** | "Musician of the day" *is* the system choosing. Configurability adds AppIntent complexity for little value. |
| 3 | **Rotation pool** | 12 curated / few-dozen polished / random vs hand-picked | **12 core + ~30–40 from `polished-ids`** (decided: you want surprises) | `polished-ids` already guarantees bio+portrait, killing the "sparse musician" risk. Open sub-decision: **random-sampled (fixed seed) vs hand-picked allowlist** for the surprise tier — hand-pick if you want full control over who represents jazz on a home screen; random+seed if you trust the filter + a quick eyeball (§3.1). |
| 4 | **Rotation policy** | date-hash / random-no-repeat | **Date-hash into a shuffled, core-weighted pool** | Deterministic + stateless even at ~50 items. Random-no-repeat needs persisted history. (§4.5) |
| 5 | **Fact line** | hook / structured / bio-prose / hand-write all | **Hook (tier-1) + structured derived line (tier-2)** | The 12 keep their soul; the surprises get `instrument · era · years` — always tidy, never awkward truncation. Hand-writing ~40 more hooks is a worthwhile *stretch*, not a v1 gate. (§4.6) |
| 6 | **Image** | existing Wikimedia portrait / custom art | **Existing portrait** | It exists, it's recognizable, it's what the app shows. Custom art is a separate (expensive) design project. Mind attribution (§9). |
| 7 | **iOS 17+ interactive vs 16+ static** | richer / broader | **16+ static, tap-to-open** | Your family targets iOS 16. Static tap-to-open works on 16+ and covers 100% of your users. Interactive (iOS 17+) buys a "next" button you don't need yet. |

The two genuinely-yours calls (not rubber-stampable): **#3's sub-decision** (random-seeded vs hand-picked surprise pool — a control-vs-effort tradeoff) and **#5** (how interesting the surprise-tier fact line needs to be — structured data vs hand-written prose). Both are best judged looking at the real pool on a real device.

---

## 6. Phased implementation plan with effort estimates

Estimates assume you're **learning Swift from scratch** but are a senior engineer who picks up languages fast. Ranges are honest — the wide ones reflect "unknown unknowns in an unfamiliar toolchain." Days = focused working days, not calendar.

### Phase 0 — WidgetKit hello-world (learn the toolchain)
- **Deliverable:** A static "Hello, Jazz" widget showing hard-coded text, added via Xcode's Widget Extension template, running on a **real device** (not just simulator).
- **You'll learn:** target creation, the `@main WidgetBundle`, `StaticConfiguration`, `TimelineProvider` stub, the SwiftUI view body, deploying an extension to device, the widget gallery.
- **What can go wrong:** code-signing the new target (provisioning profile for the extension's bundle ID — your Team `V78LBF2887` must generate one); the extension's deployment target must be ≤ 16.0; simulator caching stale widgets (delete + re-add).
- **Estimate:** **1–2 days** (most of it is Swift/Xcode orientation, not widget logic).

### Phase 1 — Data model + bundled content (Pattern d)
- **Deliverable:** `WidgetMusician`/`MusicianEntry` types; a `musicians.json` + placeholder portraits in the widget's asset catalog; provider reads them.
- **You'll learn:** `Codable` (≈ JSON typing in TS, pleasantly familiar), asset catalogs, loading a bundled resource in Swift.
- **What can go wrong:** bundling resources into an *extension* target (not the app target) — easy to put them in the wrong place and get nil at runtime.
- **Estimate:** **1 day.**
- *(In a Pattern-(a) world this phase is instead "App Group + bridge plugin + write/read" and balloons to 3–5 days — see §2. Deferring it is most of why v1.1 is small.)*

### Phase 2 — Pool assembly + image pre-sizing pipeline
- **Deliverable:** a Node script (in the web monorepo, mirroring `scripts/generate-splash-masters.mjs`) that assembles the full pool — pulls the 12 from `/api/musicians/curated`, samples ~30–40 from `/api/musicians/polished-ids` + hydrates via `by-ids`/detail, derives tier-2 fact lines (§4.6), applies the §3.1 guardrails — then square-crops + resizes every portrait to ~512² and writes images + the merged `musicians.json` into the widget asset catalog. Plus a **10-minute editorial eyeball** of the sampled surprise pool (§3.1). Real content replaces placeholders.
- **You'll learn:** nothing new in Swift — this is your home turf (Node + sharp). The pool sampling/fact-derivation/guardrail logic is the only added work vs the 12-only version.
- **What can go wrong:** portrait URLs occasionally missing (`photo: false`) → script must handle/skip; a sampled musician with a weak portrait or thin derived fact slips through (the editorial eyeball catches these); facial crops decapitating tall portraits (§10). (The BFF should be warm — the 48 h keep-warm cron means no cold Aura wake; if you run it right after a long pause, just retry.)
- **Estimate:** **1–2 days** (was ~0.5–1 for 12-only; the pool sampling + fact derivation + editorial pass is the delta from your broader-pool decision).

### Phase 3 — Real widget UI (portrait + name + hook)
- **Deliverable:** A polished `.systemSmall` view: portrait, name, hook, in the Jazzlore visual language (dark `#0a0a0a` background per your splash spec).
- **You'll learn:** SwiftUI layout (`ZStack`/`VStack`, `.font`, `.lineLimit`, `ContainerRelativeShape`, `.foregroundStyle`), image rendering, the iOS 17 `.containerBackground` API (with a 16-compatible fallback).
- **What can go wrong:** text truncation on long names ("Cannonball Adderley"); contrast of white text over a busy photo (use a gradient scrim); the iOS 17 `containerBackground` requirement — widgets built with the iOS 17 SDK **must** declare a container background or they look broken in StandBy/Lock — needs an `if #available` branch.
- **Estimate:** **2–3 days** (SwiftUI layout fiddliness is where first-timers lose time, but it's the fun part and most React-transferable).

### Phase 4 — Rotation + scheduling
- **Deliverable:** date-hash rotation through the fixed shuffled order; `timeline(...)` emits ~7 midnight-stamped entries with `.atEnd`; verified the face changes at midnight.
- **You'll learn:** `Calendar`/`DateComponents` (fiddly but bounded), the timeline pre-compute pattern.
- **What can go wrong:** timezone/midnight edge cases (use the user's `Calendar.current`, set entries to *start of day*); testing "does it flip at midnight" is slow in real life — temporarily shrink the interval to minutes to verify, then restore.
- **Estimate:** **1–2 days.**

### Phase 5 — Polish
- **Deliverable:** redaction/placeholder states, gallery snapshot with a good sample (Miles), accessibility labels (VoiceOver reads "Musician of the day: Miles Davis. Reinvented jazz five times…"), optional medium size.
- **What can go wrong:** scope creep. Timebox it.
- **Estimate:** **1–2 days** (more if you add medium).

### Phase 6 — Testing + App Store submission as v1.1
- **Deliverable:** on-device testing across devices/iOS versions, memory check (confirm well under 30 MB — Xcode's debug gauge on the extension), bump `MARKETING_VERSION` to 1.1, App Store Connect submission with widget described in *Notes for Review*.
- **What can go wrong:** widget jetsam from an oversized image you missed (re-check §5.2); App Review wanting the widget's purpose explained; the gotcha that **App Review may add the widget before ever launching the app** — Pattern (d) survives this; Pattern (a) would show empty (another reason for (d)).
- **Estimate:** **1–2 days** (plus review wait — submit *after* Chords/Scales clear, per your sequencing).

### Totals

| | Pattern (d) — recommended | Pattern (a) — if you insist |
|---|---|---|
| **Sum** | **~9–14 focused days** | ~14–21 focused days |
| **Calendar (learning, part-time)** | ~2–4 weeks | ~4–6 weeks |

*(The broader-pool decision added ~0.5–1 day in Phase 2 vs the 12-only plan — the only place pool size moves the estimate. Phases 0/1/3/4/5/6 are identical whether the pool is 12 or 50, because the widget renders one musician at a time.)*

Be kind to yourself on the estimate: the *first* SwiftUI view takes a day; the fifth takes an hour. Most of the range is Phase 0/3 learning tax that you pay once.

---

## 7. Learning resources (curated for a React/TS senior)

Quality over quantity — these 7, in roughly the order you'd touch them.

1. **Apple — *Develop in Swift Tutorials* + *SwiftUI essentials* (WWDC24).** The fastest "Swift the language, in an hour" + the declarative-UI model. As a React dev, skim the language, slow down on `struct` vs `class`, value semantics, and optionals (`?`/`!`/`if let`/`guard`). [developer.apple.com/tutorials/swiftui](https://developer.apple.com/tutorials/swiftui) · [SwiftUI essentials (WWDC24)](https://developer.apple.com/videos/play/wwdc2024/10150/)

2. **Hacking with Swift — Paul Hudson (your canonical reference).** *100 Days of SwiftUI* is the comprehensive guide; you won't do all 100, but his **WidgetKit articles** are the best free practical tutorials anywhere. Search "Hacking with Swift WidgetKit." Paul's prose is the friendliest on-ramp for someone who already knows how to program. [hackingwithswift.com](https://www.hackingwithswift.com/)

3. **Apple — *Creating a widget extension* + *Keeping a widget up to date*.** The two canonical docs for the timeline model and refresh budget — read these before Phase 4. [Keeping a widget up to date](https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date) · [WidgetKit docs](https://developer.apple.com/documentation/widgetkit)

4. **Swift Senpai — "How to Update or Refresh a Widget."** The clearest single explanation of `.atEnd` / `.after` / `.never` and the refresh budget, with diagrams. Read alongside #3. [swiftsenpai.com/development/refreshing-widget](https://swiftsenpai.com/development/refreshing-widget/)

5. **Answertopia / SwiftLee — Widget deep-linking + `onOpenURL`.** Exactly the `widgetURL` → app-side handling you need for tap-to-open. [SwiftLee: Deeplink URL handling](https://www.avanderlee.com/swiftui/deeplink-url-handling/) · [Answertopia WidgetKit deep link](https://www.answertopia.com/swiftui/a-swiftui-widgetkit-deep-link-tutorial/)

6. **"SwiftUI for React developers" mental-model bridge.** SwiftUI state ≈ React: `@State`≈`useState`, `@Binding`≈ lifted state/props callback, `@StateObject`/`@ObservedObject`≈ context/store, `body`≈`render()`, view modifiers ≈ chained styling. A good framing piece: Nabil Ridhwan's *"Is Swift Worth Learning… a React Native Developer's Take"* and the broader "SwiftUI is declarative like React" discussions. [blog.nabilridhwan.com](https://blog.nabilridhwan.com/is-learning-swift-worth-it-my-experience-with-swift-as-a-prior-react-native-developer)

7. **`capacitor-widget-bridge` README (for v1.2 only).** When you migrate to the App Group pattern, this is the plugin. Read its iOS setup + the App Groups capability steps. [github.com/.../capacitor-widget-bridge](https://libraries.io/npm/capacitor-widget-bridge) — and Capacitor's own [App Groups discussion #7560](https://github.com/ionic-team/capacitor/discussions/7560) for *why* `@capacitor/preferences` won't do it.

> **The single highest-leverage move:** do Phase 0 (hello-world on device) *entirely* by following Paul Hudson's WidgetKit tutorial start to finish before you touch Jazzlore data. Get the toolchain frustration out of the way against throwaway code.

---

## 8. The React → Swift/SwiftUI mental-model cheat sheet

A quick orientation so the code samples above don't look alien:

| React / TS | SwiftUI / Swift | Note |
|---|---|---|
| `function Comp(props)` returning JSX | `struct View: View { var body: some View }` | `body` ≈ `render()`; recomputed from state |
| `useState` | `@State private var x` | local mutable view state |
| props / lifted state setter | `@Binding var x` | two-way |
| context / global store | `@StateObject` / `@ObservedObject` + `ObservableObject` | not needed for this widget |
| `interface Foo {}` | `struct Foo: Codable {}` | value type, JSON via `Codable` |
| `x?.y ?? z` | `x?.y ?? z` | optionals are nearly identical |
| `Array.map/filter` | `.map/.filter` | same, value-semantic |
| CSS / styled chaining | view modifiers `.font().padding().foregroundStyle()` | order matters in SwiftUI |
| `null`/`undefined` | `Optional` (`?`), unwrapped via `if let`/`guard let` | the one concept worth real study |

The biggest adjustments: **value semantics** (structs are copied, not referenced — no more accidental shared mutation), **optionals are enforced by the compiler** (no more `undefined is not a function`), and **`some View`** (an opaque return type — just trust it for now).

---

## 9. App Review considerations specific to widgets

- **Widgets must align with the app's core purpose** and offer real, useful functionality (Guideline 4.2 / extension rules). "Musician of the day → opens the musician's page" is squarely on-purpose. ✅ ([App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/))
- **No advertising in widgets.** N/A for you, but worth knowing.
- **Describe the widget in *Notes for Review*** in App Store Connect with specifics ("Adds a home-screen widget showing a daily-rotating curated jazz musician; tapping opens that musician's page"). Generic descriptions get bounced.
- **Test on a real device.** Reviewers (and jetsam bugs) catch simulator-only issues. Confirm the widget isn't blank.
- **First-install / app-never-launched:** reviewers may add the widget without launching the app. **Pattern (d) renders correctly here; Pattern (a)/(c) would show empty until the app runs once** — a real rejection risk. (Strong point in (d)'s favor.)
- **Image licensing / attribution (the one to actually think about).** Portraits carry `license` + `attribution` (`ImageAttribution`) — these are Wikimedia-style assets. Displaying a face on a home-screen widget with *no* visible attribution may be fine under the license *if* attribution is reasonably accessible (e.g. on the in-app musician page the tap leads to), but **this needs a deliberate check per the specific licenses** (CC-BY vs CC-BY-SA vs public-domain differ). Don't assume. (See §10.) Also consider **publicity/likeness** for portraits of musicians — generally fine for editorial/educational use, but a known sensitivity for commercial app surfaces.

---

## 10. Open questions & risks (known-unknowns, not blockers)

Flagged rather than guessed — these are the things to resolve *during* implementation, with Aurélien's eyes on them.

1. **🟡 Capacitor→App Group image-file bridge (defers, doesn't block).** `capacitor-widget-bridge` is a `UserDefaults` *string* bridge; writing portrait **files** into the App Group container is under-documented and may need a small custom Capacitor plugin (native Swift). This is the single biggest unknown in Pattern (a) and the main reason v1.1 uses Pattern (d), which avoids it. *Investigate before committing to v1.2.*
2. **🟡 Portrait license compliance — now across a few-dozen pool.** This grew with the broader pool: instead of 12 licenses you're clearing ~40–50, and the surprise tier's images are whatever Wikimedia/MusicBrainz had (more license variety: CC-BY, CC-BY-SA, public-domain, occasionally non-free). The build script should **capture each portrait's `license` + `attribution` into `musicians.json`** (even if not shown on the widget face) so provenance ships with the build and you can audit it. Confirm whether home-screen display without inline attribution is compliant and whether the in-app attribution (on the linked musician page) satisfies each license. The editorial eyeball (§3.1) is also the moment to drop any image with an awkward or non-free license. Likely fine; verify, don't assume. (§9)
3. **🟢 Custom URL scheme vs Universal Links for tap-to-open.** Musicians doesn't currently bundle `@capacitor/app`. Tap-to-open needs either a custom scheme (`jazzlore-musicians://musician/<id>`) registered in Info.plist + handled in the shell, or Universal Links (associated domains — more setup). Recommend **custom scheme** for v1.1. Verify the Capacitor shell can intercept the inbound URL and navigate the WebView to `/musicians/<id>` (likely via `@capacitor/app`'s `appUrlOpen` listener — a small add to the bundled web app's native-shell code path).
4. **🟡 Square-crop strategy across a few-dozen pool.** Center-crop is trivial but can decapitate. With ~50 portraits, manual per-image crop rects stop being free — consider **face-aware auto-crop** (Vision framework / `sharp`'s attention strategy at build time) with a quick eyeball, rather than hand-cropping all 50. Bounded, but bigger than at N=12.
5. **🟢 `containerBackground` / iOS 17 SDK requirement.** Building against the iOS 17+ SDK makes `.containerBackground` mandatory for correct rendering. Needs an `if #available(iOS 17, *)` branch to stay correct on iOS 16. Bounded, known pattern.
6. **🟢 Widget app icon / gallery presentation.** The widget shows a display name + description in the gallery — needs copy and (optionally) a tinted preview. Minor.
7. **🟢 Fallback for a pick with no portrait.** `polished-ids` already guarantees a portrait, so the surprise tier is safe; but if any of the 12 core returns `photo: false`, the build script needs a fallback (a branded "no portrait" card, mirroring the app's `noPhotoFigures` treatment). Bounded.
8. **🟢 Multi-app generalization (future).** Metronome/Chords/Scales have no equivalent daily content, so this widget is Musicians-specific. But the *pattern* (bundled data + date-hash + tap-to-open) is reusable if you ever want, e.g., a "chord of the day." Out of scope for v1.1; worth keeping the widget code factored cleanly in case.

---

## Appendix A — Concrete deep-link contract (proposed)

| Layer | Value |
|---|---|
| URL scheme | `jazzlore-musicians` (register in widget's `widgetURL` and app's `Info.plist` `CFBundleURLTypes`) |
| Widget emits | `jazzlore-musicians://musician/wikidata:Q93341` (id percent-encoded) |
| Shell handles | `appUrlOpen` → parse `musician/<id>` → navigate WebView to `/musicians/<encodedId>` |
| Web route hit | `/musicians/wikidata%3AQ93341` → `<MusicianPage/>` |

## Appendix B — File/target layout (proposed, Pattern d)

```
musicians/ios/App/
  App.xcodeproj                         (add MusicianWidget target here)
  App/                                  (existing Capacitor host — unchanged)
  MusicianWidget/
    MusicianWidgetBundle.swift          @main, WidgetBundle
    MusicianWidget.swift                Widget + StaticConfiguration
    Provider.swift                      TimelineProvider, date-hash rotation
    MusicianEntryView.swift             SwiftUI .systemSmall view
    Model.swift                         WidgetMusician, MusicianEntry (Codable)
    Resources/
      musicians.json                    ~40–50 records (id, name, fact, imageName, source)
      Portraits.xcassets                ~40–50 pre-resized ~512² square portraits
    Info.plist
    MusicianWidget.entitlements         (empty in v1.1; App Group added in v1.2)

# in the WEB monorepo (~/Developer/jazzlore), alongside scripts/generate-splash-masters.mjs:
scripts/generate-widget-content.mjs     pulls /api/musicians/curated, resizes, writes Resources/
```

---

*End of design document. No code was changed and nothing was committed in producing this — it's a research deliverable only. Recommended next action when you're back: skim §0 and §5, accept/override the seven decisions in §5, then start with Phase 0 against Paul Hudson's WidgetKit tutorial before touching any Jazzlore data.*
