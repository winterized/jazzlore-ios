# iOS 26 Liquid Glass App Icons — Design

**Date:** 2026-05-30
**Repo:** `jazzlore-ios` (single repo, three Capacitor app subdirs: `metronome/`, `chords/`, `scales/`)
**Status:** Approved design — ready for implementation plan

## Problem

The three iOS app icons (Jazz Metronome, Jazz Chords, Jazz Scales) do not read as one
visual family when seen side-by-side on the iOS 26 home screen. Two issues were reported:
"black background drift" and "liquid-glass inconsistency."

### Pre-flight diagnosis (what's actually true)

Investigation proved **neither reported bug exists at the asset level**:

- **Background:** all three master SVGs use exactly `#0a0a0a`; all three generated
  1024² PNGs are **pixel-identical `#0a0a0a`** at every corner, with **no alpha** and
  **no embedded color profile** (plain sRGB). There is no drift to fix.
- **Generation chain is clean:** each `ios/.../AppIcon.appiconset/AppIcon-512@2x.png` is
  byte-for-byte SHA-256 identical to that app's `assets/icon-only.png`, which post-dates
  the masters. All three pass through one identical `sharp(svg).resize().png()` path — no
  per-app drift is possible.

The real cause is **icon composition**, not color or generation. iOS 26 applies the
Liquid Glass / specular treatment at render time from the icon's pixels. Since all three
assets are format-identical, the divergence comes purely from content:

- **Chords** = isolated filled circles on a near-solid black field → the system specular
  highlight lands cleanly on the central dot and the large uninterrupted black reads as
  "intense." This is the look the user considers perfect.
- **Metronome** = one bright amber line spanning full height, edge to edge.
- **Scales** = five bright amber lines spanning full width, edge to edge.

Those bright, thin, high-luminance amber lines break up the black field and present
edge-to-edge geometry the auto-glassification handles differently from a single isolated
blob, which is why Metronome/Scales don't match Chords.

## Goal

Make the three icons read as one family by adopting the **proper iOS 26 layered `.icon`
(Icon Composer)** path, so each app's brand dot gets an identical, controlled Liquid Glass
treatment instead of relying on the system auto-glassifying a flat PNG. The current Chords
icon is the gold standard; the result must match or beat it, with Chords rollback always
one `git revert` away.

## Non-goals / frozen constraints

- **Do not change the icon design.** Dot colors are fixed: metronome dot `#a06b6b` (mauve;
  the amber `#f4a233` in metronome is the bar line, not the dot), chords dot `#8a72a8`
  (purple), scales dot `#6f8caa` (blue). Background `#0a0a0a`. Accent motifs (bar line /
  satellite dots / staff lines) unchanged.
- **Do not touch the web monorepo.** This is now iOS-repo-only work. The flat PWA icon
  pipeline (`~/Documents/jazzlore/scripts/generate-icons.mjs` and the master SVGs) is the
  design source of truth and stays as-is. PWA icons are not regenerated.
- **Do not change non-icon code** in any app.

## Design decisions (locked)

1. **Glass scope — hero dot only.** Background flat; amber accents flat/matte behind the
   glass plane; only the brand dot is raised onto the front glass group so it catches the
   moving specular highlight. This deliberately makes the bright amber lines *recede* —
   directly neutralizing the diagnosed source of incoherence — and makes the glassy dot the
   single consistent hero across all three apps.
2. **Appearance variants — Default only.** iOS 26 auto-derives Dark and Tinted. We do not
   hand-author them (Tinted would strip the per-app brand color to a flat system monochrome,
   losing identity, so it is not worth authoring).
3. **Authoring workflow — GUI-authored, fully prepped.** Claude generates pixel-perfect
   layer PNGs + the Xcode wiring + structural build verification and writes an exact
   Icon Composer recipe. The user assembles the layers and tunes the hero-dot glass by eye
   in Icon Composer (the only reliable writer of `icon.json`, whose schema Apple does not
   publicly document), saving `AppIcon.icon` per app.

## Architecture

### Layer decomposition (3 transparent 1024×1024 PNGs per app)

Rasterized from self-contained per-app layer SVGs (see File layout). Geometry/colors are a
faithful one-time derivation of the frozen masters.

| Layer | metronome | chords | scales |
|---|---|---|---|
| **1. Background** (opaque, full 1024² square) | `#0a0a0a` | `#0a0a0a` | `#0a0a0a` |
| **2. Accents** (transparent bg) | vertical amber line, full height, 10px `#f4a233` | 2 amber satellite dots r=32 `#f4a233` at cy=92 & cy=420 | 5 amber staff lines, 10px `#f4a233`, at y=176/216/256/296/336 |
| **3. Brand dot** (transparent bg, top) | circle r=112 `#a06b6b` | circle r=112 `#8a72a8` | circle r=112 `#6f8caa` |

All circles are centered at (256,256); viewBox `0 0 512 512`. Stacking back→front
(Background → Accents → Dot) reproduces each master exactly (the dot is drawn over the
line/staff). The system applies the rounded-rect corner mask, so backgrounds are plain
full squares with no corner radius baked in.

### Icon Composer recipe (user's GUI step, identical for all three apps)

1. New icon; drop in the three layers (`1-bg`, `2-accents`, `3-dot`).
2. **Background** → bottom group, no glass, opaque.
3. **Accents** → recessed/flat group, opaque, **specular off** (keeps amber matte so it
   does not compete with the dot).
4. **Dot** → front glass group, **specular on**; tune shine/translucency by eye.
5. Save as `AppIcon.icon`.

Tuning order: tune **Chords first** (the gold standard) until the glassy dot matches its
current self, record the slider values, then apply the same values to Metronome and Scales
so the family is consistent. Claude will provide recommended starting slider values in the
implementation plan.

### File layout (all in the iOS repo)

- `scripts/generate-icon-layers.mjs` (repo root) — one generator iterating the three apps;
  reads each app's layer SVGs, writes the layer PNGs. Uses `sharp`, added as a root dev
  dependency (mirrors the proven web-monorepo approach). Rasterizer choice is an
  implementation detail; if `sharp` install is problematic on this machine, an equivalent
  SVG→PNG rasterizer (e.g. `rsvg-convert`) may be substituted — output PNGs must be 1024²,
  sRGB, no profile, with correct transparency.
- Per app `<app>/assets/icon-layers/`:
  - `1-bg.svg`, `2-accents.svg`, `3-dot.svg` — self-contained layer sources (committed;
    header comment cites the master as canonical design reference)
  - `1-bg.png`, `2-accents.png`, `3-dot.png` — generated 1024² outputs (committed, so the
    build never depends on regenerating)
  - `AppIcon.icon` — package assembled by the user in Icon Composer
- Xcode: `AppIcon.icon` added to the App target in `ios/App/App/`.

### Xcode wiring & rollback safety

- `ASSETCATALOG_COMPILER_APPICON_NAME` is already `AppIcon` in all three projects, so
  naming the file `AppIcon.icon` requires **no build-setting change** — only adding the
  file reference to the App target in the Xcode project.
- The current flat `AppIcon.appiconset` **stays committed in git**. Rollback (especially
  Chords) = remove the `.icon` reference and revert one commit.
- **Default-behavior decision (resolved):** keep `AppIcon.appiconset` in place and simply
  add `AppIcon.icon` alongside it, both named `AppIcon`. Per repeated Apple Developer Forum
  reports (confirmed in Xcode 26 beta 3+ / RC), when both share the name and nothing else is
  changed, **the `.icon` wins on every iOS version** — the system auto-generates flattened
  fallback PNGs from the `.icon` for pre-iOS-26 devices. So iOS 18 devices get a
  flattened-glass render of the `.icon`, not the original appiconset PNG. The appiconset
  therefore remains in the bundle but is **not used for rendering** — it is retained purely
  as the git-rollback artifact. This is Apple's intended default path; we adopt it as-is.

## Commits

- One commit: `scripts/generate-icon-layers.mjs` + root dev-dependency + all per-app layer
  SVGs and generated PNGs.
- One commit per app for its `AppIcon.icon` + Xcode wiring (three commits).

## Verification

### Structural (Claude)
- Layer PNGs present for all three apps at 1024², correct transparency (bg opaque;
  accents/dot transparent), `#0a0a0a` / correct dot colors.
- Each `AppIcon.icon` is a well-formed package (`icon.json` + `Assets/` present).
- `xcodebuild` succeeds for all three apps with the `.icon` wired in.
- `AppIcon.icon` and `AppIcon.appiconset` coexist under the name `AppIcon` with the `.icon`
  rendering everywhere (per the resolved default-behavior decision); appiconset retained
  only for rollback.

### On-device (user)
- Archive each app, install on iPhone, evaluate the three side-by-side: same intense black,
  same moving glass dot — do they finally read as one family?
- Chords must be ≥ its current self; if not, roll Chords back.
- On approval, re-archive + re-upload to App Store Connect to replace the binaries before
  review (Metronome already in review; Chords/Scales not yet submitted).

## Risks

- **`icon.json` schema is undocumented** — mitigated by GUI authoring (Icon Composer writes
  it). Claude does not hand-edit `icon.json`.
- **Layered chords could look worse than the current flat chords** — mitigated by the
  flat appiconset remaining in git for one-revert rollback, and by tuning Chords first.
- **`.icon` requires the Xcode 26 SDK** (present: Xcode 26.5) — apps still deploy to iOS 16;
  on pre-iOS-26 devices the `.icon` flattens automatically.
