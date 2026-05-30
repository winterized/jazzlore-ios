# iOS 26 Liquid Glass App Icons Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
>
> **Note on shape:** This plan is asset generation + a mid-plan human-in-the-loop GUI step + build verification, not a code-logic TDD task. "Test" steps are concrete verification commands with expected output. Tasks are tagged 🤖 (Claude-executable) or 👤 (user, in the Icon Composer / Xcode GUI). Do NOT attempt to automate the 👤 tasks — Icon Composer is the only reliable writer of `icon.json` and cannot be driven headlessly.

**Goal:** Give the three Jazzlore iOS apps (Metronome, Chords, Scales) a coherent iOS 26 Liquid Glass app-icon family via layered `.icon` files, where each app's brand dot is the consistent glassy hero, with Chords as the gold standard and one-revert rollback.

**Architecture:** Self-contained per-app layer SVGs (faithful one-time derivation of the frozen master designs) live in the iOS repo. A `sharp`-based generator rasterizes them to 1024² PNG layers (background / accents / dot). The user assembles those into `AppIcon.icon` per app in Icon Composer (hero-dot-only glass, Default variant only) and drags each into its Xcode project. Claude verifies structure + build. The existing flat `AppIcon.appiconset` stays in git as the rollback artifact; per Apple's default behavior the `.icon` renders on all iOS versions.

**Tech Stack:** Node 26 / npm 11, `sharp` (SVG→PNG), Icon Composer (Xcode 26.5), `xcodebuild`, Capacitor 8 + Swift Package Manager (`App.xcodeproj` + `CapApp-SPM`, no CocoaPods).

**Spec:** `docs/superpowers/specs/2026-05-30-ios26-liquid-glass-icons-design.md`

---

## File Structure

Created/modified files (all in `jazzlore-ios`; `<app>` ∈ {metronome, chords, scales}):

- `package.json` (root) — **create**: minimal, `"type": "module"`, `sharp` devDependency, `icons:layers` script. Sole responsibility: declare the layer-generation tooling.
- `scripts/generate-icon-layers.mjs` — **create**: one generator, iterates the three apps, rasterizes each app's 3 layer SVGs → 3 PNGs. Sole responsibility: SVG→PNG layer rasterization.
- `<app>/assets/icon-layers/1-bg.svg` `2-accents.svg` `3-dot.svg` — **create** (9 files): self-contained layer sources, committed.
- `<app>/assets/icon-layers/1-bg.png` `2-accents.png` `3-dot.png` — **generated** (9 files), committed so the build never depends on regenerating.
- `<app>/ios/App/App/AppIcon.icon` — **create in Icon Composer** (3 packages): the assembled layered icon, placed beside `Assets.xcassets`.
- `<app>/ios/App/App.xcodeproj/project.pbxproj` — **modify** (3 files): file reference for `AppIcon.icon` added to the App target (written by Xcode when the user drags the file in).
- `.gitignore` (root) — **create/modify**: ignore `node_modules/`.

`AppIcon.icon` lives in `ios/App/App/` (conventional app-icon location, what Xcode references). The layer PNG *inputs* live in `<app>/assets/icon-layers/`. This resolves the two location mentions in the spec: inputs in `assets/icon-layers/`, the assembled package in `ios/App/App/`.

---

## Task 1: 🤖 Author the 9 layer SVG sources

Faithful decomposition of the frozen masters. All use `width="1024" height="1024" viewBox="0 0 512 512"` so sharp renders crisply at native 1024 (important for the thin 10px lines). Background is opaque; accents/dot have transparent backgrounds. Circles centered at (256,256), r=112.

**Files:**
- Create: `metronome/assets/icon-layers/{1-bg.svg,2-accents.svg,3-dot.svg}`
- Create: `chords/assets/icon-layers/{1-bg.svg,2-accents.svg,3-dot.svg}`
- Create: `scales/assets/icon-layers/{1-bg.svg,2-accents.svg,3-dot.svg}`

- [ ] **Step 1: Write the three shared/per-app background layers** (identical content in all three `1-bg.svg`)

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 512 512">
  <!-- Layer 1 / background. Canonical design: ~/Documents/jazzlore/assets/icons/<app>/pwa-master.svg
       Full opaque #0a0a0a square; iOS 26 applies the rounded-rect mask, so no corner radius here. -->
  <rect width="512" height="512" fill="#0a0a0a"/>
</svg>
```

- [ ] **Step 2: Write `metronome/assets/icon-layers/2-accents.svg`** (vertical amber bar line)

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 512 512">
  <!-- Layer 2 / accents (metronome): vertical amber bar line, full height. Matte, flat. -->
  <line x1="256" y1="0" x2="256" y2="512" stroke="#f4a233" stroke-width="10" stroke-linecap="butt"/>
</svg>
```

- [ ] **Step 3: Write `metronome/assets/icon-layers/3-dot.svg`** (mauve brand dot)

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 512 512">
  <!-- Layer 3 / brand dot (metronome): percussion mauve. The glass hero. -->
  <circle cx="256" cy="256" r="112" fill="#a06b6b"/>
</svg>
```

- [ ] **Step 4: Write `chords/assets/icon-layers/2-accents.svg`** (2 amber satellite dots)

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 512 512">
  <!-- Layer 2 / accents (chords): two amber satellite dots flanking the brand dot. Matte, flat. -->
  <circle cx="256" cy="92" r="32" fill="#f4a233"/>
  <circle cx="256" cy="420" r="32" fill="#f4a233"/>
</svg>
```

- [ ] **Step 5: Write `chords/assets/icon-layers/3-dot.svg`** (purple brand dot)

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 512 512">
  <!-- Layer 3 / brand dot (chords): voice purple. The glass hero (gold-standard reference). -->
  <circle cx="256" cy="256" r="112" fill="#8a72a8"/>
</svg>
```

- [ ] **Step 6: Write `scales/assets/icon-layers/2-accents.svg`** (5 amber staff lines)

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 512 512">
  <!-- Layer 2 / accents (scales): 5-line amber staff, full width. Matte, flat. -->
  <g stroke="#f4a233" stroke-width="10" stroke-linecap="butt">
    <line x1="0" y1="176" x2="512" y2="176"/>
    <line x1="0" y1="216" x2="512" y2="216"/>
    <line x1="0" y1="256" x2="512" y2="256"/>
    <line x1="0" y1="296" x2="512" y2="296"/>
    <line x1="0" y1="336" x2="512" y2="336"/>
  </g>
</svg>
```

- [ ] **Step 7: Write `scales/assets/icon-layers/3-dot.svg`** (blue brand dot)

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 512 512">
  <!-- Layer 3 / brand dot (scales): strings blue. The glass hero. -->
  <circle cx="256" cy="256" r="112" fill="#6f8caa"/>
</svg>
```

- [ ] **Step 8: Verify all 9 files exist**

Run: `ls metronome/assets/icon-layers/*.svg chords/assets/icon-layers/*.svg scales/assets/icon-layers/*.svg | wc -l`
Expected: `9`

(No commit yet — commit happens in Task 3 with the generated PNGs.)

---

## Task 2: 🤖 Create the generator tooling

**Files:**
- Create: `package.json` (root)
- Create: `.gitignore` (root)
- Create: `scripts/generate-icon-layers.mjs`

- [ ] **Step 1: Create root `package.json`**

```json
{
  "name": "jazzlore-ios-tooling",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "description": "iOS-repo-only tooling (app-icon layer generation).",
  "scripts": {
    "icons:layers": "node scripts/generate-icon-layers.mjs"
  },
  "devDependencies": {
    "sharp": "^0.34.0"
  }
}
```

- [ ] **Step 2: Create/append root `.gitignore`**

```
node_modules/
```

(If `.gitignore` already exists, append the line only if absent.)

- [ ] **Step 3: Create `scripts/generate-icon-layers.mjs`**

```javascript
/**
 * Generate iOS 26 Liquid Glass icon LAYER PNGs from per-app layer SVGs.
 *
 * iOS-only. The flat PWA/icon pipeline lives in the web monorepo and is
 * unrelated. Source of truth for layer geometry/colors: each app's
 * assets/icon-layers/*.svg (a faithful, frozen derivation of the design
 * masters at ~/Documents/jazzlore/assets/icons/<app>/pwa-master.svg).
 *
 * Per app, reads:  <app>/assets/icon-layers/{1-bg,2-accents,3-dot}.svg
 * Per app, writes: <app>/assets/icon-layers/{1-bg,2-accents,3-dot}.png  (1024x1024)
 *
 * Background renders opaque; accents/dot preserve transparency. Re-run when
 * a layer SVG changes:  npm run icons:layers
 */

import sharp from 'sharp'
import { readFileSync } from 'node:fs'
import { resolve } from 'node:path'

const ROOT = resolve(import.meta.dirname, '..')
const APPS = ['metronome', 'chords', 'scales']
const LAYERS = ['1-bg', '2-accents', '3-dot']
const SIZE = 1024

async function main() {
  for (const app of APPS) {
    for (const layer of LAYERS) {
      const src = resolve(ROOT, `${app}/assets/icon-layers/${layer}.svg`)
      const out = resolve(ROOT, `${app}/assets/icon-layers/${layer}.png`)
      const svg = readFileSync(src)
      // density 144 ensures crisp rasterization of thin 10px strokes before the
      // resize guard; SVGs already declare width/height 1024 so this is belt-and-braces.
      await sharp(svg, { density: 144 })
        .resize(SIZE, SIZE, { fit: 'fill' })
        .png()
        .toFile(out)
      console.log(`  ${app}/${layer}.png`)
    }
  }
  console.log('Done. 9 layer PNGs written.')
}

await main()
```

- [ ] **Step 4: Install dependencies**

Run: `npm install`
Expected: completes, creates `node_modules/sharp`.

- [ ] **Step 5: Verify sharp loads**

Run: `node -e "import('sharp').then(m => console.log('sharp', m.default.versions.sharp))"`
Expected: prints `sharp <version>` with no error.

(No commit yet — commit in Task 3.)

---

## Task 3: 🤖 Generate and verify the layer PNGs, then commit

**Files:**
- Generated: `<app>/assets/icon-layers/{1-bg,2-accents,3-dot}.png` (9 files)

- [ ] **Step 1: Run the generator**

Run: `npm run icons:layers`
Expected: prints 9 layer lines + `Done. 9 layer PNGs written.`

- [ ] **Step 2: Verify dimensions and alpha per layer**

Run:
```bash
for app in metronome chords scales; do
  for layer in 1-bg 2-accents 3-dot; do
    f=$app/assets/icon-layers/$layer.png
    printf "%-26s " "$f"
    sips -g pixelWidth -g pixelHeight -g hasAlpha "$f" 2>/dev/null | tr '\n' ' '; echo
  done
done
```
Expected: every file `pixelWidth: 1024  pixelHeight: 1024`. `1-bg` may show `hasAlpha: no` (opaque is fine); `2-accents` and `3-dot` must show `hasAlpha: yes`.

- [ ] **Step 3: Verify pixel correctness (dot color + transparency)**

Run:
```bash
python3 - <<'PY'
import struct, zlib, os
def load(path):
    d=open(path,'rb').read(); i=8; idat=b''; w=h=ct=None
    while i<len(d):
        ln=struct.unpack('>I',d[i:i+4])[0]; typ=d[i+4:i+8]; ch=d[i+8:i+8+ln]
        if typ==b'IHDR': w,h,bd,ct=struct.unpack('>IIBB',ch[:10])
        elif typ==b'IDAT': idat+=ch
        elif typ==b'IEND': break
        i+=12+ln
    raw=zlib.decompress(idat); nch={0:1,2:3,4:2,6:4}[ct]; stride=w*nch
    out=bytearray(w*h*nch); prev=bytearray(stride); pos=0
    for y in range(h):
        ft=raw[pos]; pos+=1; line=bytearray(raw[pos:pos+stride]); pos+=stride
        for x in range(stride):
            a=line[x-nch] if x>=nch else 0; b=prev[x]; c=prev[x-nch] if x>=nch else 0
            if ft==1: line[x]=(line[x]+a)&255
            elif ft==2: line[x]=(line[x]+b)&255
            elif ft==3: line[x]=(line[x]+((a+b)>>1))&255
            elif ft==4:
                p=a+b-c; pa=abs(p-a); pb=abs(p-b); pc=abs(p-c)
                pr=a if(pa<=pb and pa<=pc) else (b if pb<=pc else c); line[x]=(line[x]+pr)&255
        out[y*stride:(y+1)*stride]=line; prev=line
    return w,nch,out
def px(w,nch,buf,x,y): o=(y*w+x)*nch; return tuple(buf[o:o+nch])
want={'metronome':(160,107,107),'chords':(138,114,168),'scales':(111,140,170)}
ok=True
for app,rgb in want.items():
    w,nch,buf=load(f"{app}/assets/icon-layers/3-dot.png")
    center=px(w,nch,buf,w//2,w//2); corner=px(w,nch,buf,3,3)
    c_ok=center[:3]==rgb; a_ok=(nch==4 and corner[3]==0)
    print(f"{app:10} dot center={center[:3]} (want {rgb}) {'OK' if c_ok else 'BAD'} | corner alpha={'0' if a_ok else corner}")
    ok = ok and c_ok and a_ok
print("ALL OK" if ok else "FAILURES ABOVE")
PY
```
Expected: each app `OK` for center color and `corner alpha=0`, final line `ALL OK`.

- [ ] **Step 4: Commit tooling + sources + generated PNGs**

```bash
git add package.json .gitignore scripts/generate-icon-layers.mjs \
  metronome/assets/icon-layers chords/assets/icon-layers scales/assets/icon-layers
git commit -m "feat(icons): add layered-icon layer sources + sharp generator

Per-app self-contained layer SVGs (background / amber accents / brand dot)
faithfully derived from the frozen masters, plus a sharp-based generator
that rasterizes them to 1024 PNG layers. iOS-repo-only; inputs for the
Icon Composer .icon assembly. Web monorepo untouched.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: 👤 Assemble the three `AppIcon.icon` files in Icon Composer

**This is your GUI step — Claude cannot drive Icon Composer.** Do all three; tune Chords first as the gold standard, then replicate its dot settings to the other two.

**Files (you create):**
- `metronome/ios/App/App/AppIcon.icon`
- `chords/ios/App/App/AppIcon.icon`
- `scales/ios/App/App/AppIcon.icon`

- [ ] **Step 1: Open Icon Composer**

Run (or launch from Xcode ▸ Open Developer Tool ▸ Icon Composer):
`open -a "Icon Composer"`

- [ ] **Step 2: Build the Chords icon first (gold standard)**

1. New icon. Set appearance scope to **Default only** (do not author Dark/Tinted — iOS derives them).
2. Add three layers, bottom→top, from `chords/assets/icon-layers/`:
   - `1-bg.png` → **Background** group. Opaque. No glass/specular.
   - `2-accents.png` → a **recessed/flat** group. Opaque. **Specular OFF** (keep amber matte so it does not compete with the dot).
   - `3-dot.png` → the **front glass** group. **Specular ON.**
3. Tune ONLY the dot's glass (shine/specular intensity, slight translucency, subtle shadow/depth) by eye until the rendered dot matches — or beats — the current shipping Chords icon's moving highlight. Use the preview's light-angle drag to check the highlight travels like today's icon.
4. **Record the exact dot-layer settings you landed on** (you will reuse them).
5. Save as `AppIcon.icon` into `chords/ios/App/App/`.

- [ ] **Step 3: Build the Metronome icon**

Repeat Step 2 using `metronome/assets/icon-layers/`, but apply the **same recorded dot-layer glass settings** from Chords. Save `AppIcon.icon` into `metronome/ios/App/App/`.

- [ ] **Step 4: Build the Scales icon**

Repeat Step 2 using `scales/assets/icon-layers/`, same recorded dot settings. Save `AppIcon.icon` into `scales/ios/App/App/`.

- [ ] **Step 5: Drag each `AppIcon.icon` into its Xcode project**

For each app, open `<app>/ios/App/App.xcodeproj` in Xcode and drag `AppIcon.icon` into the **App** group (the same group that contains `Assets.xcassets`), ensuring **"Add to target: App"** is checked. This makes Xcode write the correct `project.pbxproj` file reference (more reliable than hand-editing). Leave the existing `Assets.xcassets`/`AppIcon.appiconset` in place.

- [ ] **Step 6: Tell Claude when all three are saved and added.** Claude resumes at Task 5.

---

## Task 5: 🤖 Verify structure + build, then commit per app

Run once per app. Replace `<app>` with each of metronome, chords, scales.

**Files:**
- Verify: `<app>/ios/App/App/AppIcon.icon` (package: `icon.json` + `Assets/`)
- Verify/commit: `<app>/ios/App/App.xcodeproj/project.pbxproj`

- [ ] **Step 1: Verify each `.icon` package is well-formed**

Run:
```bash
for app in metronome chords scales; do
  d=$app/ios/App/App/AppIcon.icon
  echo "=== $app ==="
  test -d "$d" && echo "package: present" || echo "package: MISSING"
  test -f "$d/icon.json" && plutil -lint "$d/icon.json" 2>/dev/null || \
    python3 -c "import json,sys;json.load(open('$d/icon.json'));print('$d/icon.json: OK')" 2>/dev/null || echo "icon.json: INVALID/MISSING"
  ls "$d/Assets" 2>/dev/null | sed 's/^/  asset: /'
done
```
Expected: each app `package: present`, `icon.json` valid, and `Assets/` listing the layer images.

- [ ] **Step 2: Verify the Xcode project references `AppIcon.icon`**

Run: `for app in metronome chords scales; do echo "$app:"; grep -c "AppIcon.icon" $app/ios/App/App.xcodeproj/project.pbxproj; done`
Expected: each app prints a count `>= 1` (the file reference Xcode added). If `0`, re-do Task 4 Step 5 for that app.

- [ ] **Step 3: Confirm the app-icon build setting is still `AppIcon`**

Run: `for app in metronome chords scales; do echo "$app:"; grep "ASSETCATALOG_COMPILER_APPICON_NAME" $app/ios/App/App.xcodeproj/project.pbxproj | head -1; done`
Expected: each shows `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;` (no change needed — `.icon` name matches).

- [ ] **Step 4: Build each app (structural gate, signing disabled)**

Run (per app):
```bash
cd <app>/ios/App && \
xcodebuild -project App.xcodeproj -scheme App -sdk iphonesimulator \
  -configuration Debug CODE_SIGNING_ALLOWED=NO build | tail -20 ; cd - >/dev/null
```
Expected: ends with `** BUILD SUCCEEDED **`. The asset/icon compilation (`actool` / `iconcomposercompile`) runs as part of this — a malformed `.icon` would fail here. If a scheme-resolution error mentions the SPM package, open the project once in Xcode to let it resolve `CapApp-SPM`, then re-run.

- [ ] **Step 5: Commit per app** (run three times, once per app)

```bash
git add <app>/ios/App/App/AppIcon.icon <app>/ios/App/App.xcodeproj/project.pbxproj
git commit -m "feat(<app>): add iOS 26 Liquid Glass AppIcon.icon

Layered hero-dot-glass icon assembled in Icon Composer from the generated
layer PNGs. Coexists with the retained AppIcon.appiconset (rollback
artifact); the .icon renders on all iOS versions per Apple's default.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 6: 👤 On-device verification (your sign-off)

- [ ] **Step 1:** Archive each app in Xcode and install on your iPhone.
- [ ] **Step 2:** Evaluate the three icons side-by-side on the home screen: same intense `#0a0a0a` black, same moving glass dot — do they read as one family now?
- [ ] **Step 3:** Confirm Chords is **≥** its current shipping self. If any icon is worse, roll it back: remove that app's `AppIcon.icon` reference and `git revert` its Task 5 commit (the `AppIcon.appiconset` resumes rendering).
- [ ] **Step 4:** On approval, re-archive + re-upload to App Store Connect to replace the binaries before review (Metronome already in review; Chords/Scales not yet submitted).

---

## Notes / rollback

- **Rollback any single icon:** `git revert` that app's Task 5 commit. The retained `AppIcon.appiconset` resumes as the rendered icon. No other app is affected.
- **Regenerate layers after a design tweak:** edit the relevant `<app>/assets/icon-layers/*.svg`, run `npm run icons:layers`, re-import the changed PNG layer(s) in Icon Composer, re-save `AppIcon.icon`.
- **Frozen:** no master/PWA/web-monorepo changes; no dot-color or accent-geometry changes; no non-icon code touched.
