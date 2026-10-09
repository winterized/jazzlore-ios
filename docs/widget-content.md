# Widget content — regeneration

The "Jazz Musicians" home-screen widget (`MusicianWidget` target) is a
**Pattern (d)** self-contained widget: its rotation pool ships **inside the app
binary** with no runtime network. The bundled content lives at:

```
musicians/ios/App/MusicianWidget/Resources/
  musicians.json            # [{ id, name, fact, deepLinkPath }] × 39
  Portraits.xcassets/       # one <wikidata_Qxxxx>.imageset per musician,
                            #   512×512 JPEG (face-aware crop, q80)
```

Both are **generated**, not hand-edited. The generator is the single thing
that talks to the BFF (once, from a laptop — never at runtime).

## How to regenerate

The generator lives in the **web monorepo** (`~/Developer/jazzlore`):

```bash
cd ~/Developer/jazzlore
pnpm widget:content          # → scripts/generate-widget-content.mjs
```

It writes straight into this iOS repo (resolved as a sibling of the web repo;
override with `IOS_REPO=/path`, BFF origin with `BFF=https://…`).

What it does:

1. Reads the **approved pool** (`docs/widget-pool.json` — produced by the
   Phase 0 license/likeness audit, `docs/widget-license-audit.md`): musician
   ids + `source` (`curated` | `polished`).
2. **Curated tier** → name + portrait via the light `/api/musicians/by-ids`
   endpoint; `fact` = the hand-written editorial hook from
   `/api/musicians/curated`. (The light endpoint is deliberate: the heavy
   `/api/musicians/:id` detail query times out Aura's 9s budget for the
   highest-degree greats — Miles, Blakey — i.e. issue #155 hits build time
   too. Curated facts are hooks, so name + portrait is all that's needed.)
3. **Polished tier** → `/api/musicians/:id` for the structured fact
   `"<instrument> · <era> · <birth>–<death>"`.
4. Downloads each portrait, face-aware square-crops + resizes to 512² JPEG,
   writes `Portraits.xcassets` + `musicians.json` (curated greats interleaved
   evenly among the polished surprises for rotation cadence).
5. Aborts if **any** musician fails — the bundled pool must be complete.

Then rebuild the app (`make musicians` is not needed for the widget — the
widget target compiles the Resources directly; just build the App scheme in
Xcode or `xcodebuild`).

## Changing the pool

To add/remove/reshuffle musicians, edit the approved pool first
(`docs/widget-pool.json`) — keeping the license/likeness bar from
`docs/widget-license-audit.md` (PD/CC0/CC-BY/CC-BY-SA with tap-to-attribution;
deceased; jazz-genre; live portrait URL) — then re-run `pnpm widget:content`
and commit the regenerated `Resources/` here.

## Asset-name contract

The Swift side derives each portrait's asset-catalog name from the musician id
with the **same** rule the generator uses, so `musicians.json` omits the image
name:

```
assetName(id) = id.replace(/[^A-Za-z0-9]/g, "_")   // wikidata:Q93341 → wikidata_Q93341
```

Keep these two in sync — a mismatch silently breaks the portrait lookup.
