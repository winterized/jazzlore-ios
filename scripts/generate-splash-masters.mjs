/**
 * Generate the branded splash MASTER PNGs for the three Capacitor iOS apps.
 *
 * iOS-only. Produces one 2732x2732 master per app — the single source that
 * feeds both launch layers: @capacitor/assets rasterizes it into the per-device
 * Splash.imageset, and the LaunchScreen.storyboard renders that same imageset.
 * Generating both layers from one composition is what removes the launch->splash
 * seam.
 *
 * Composition (identical across apps — only the icon changes; that is the family
 * signal). Two elements, no third:
 *   - App mark: <app>/assets/icon-only.png (flat 1024^2), resized to ICON_PX and
 *     centered horizontally with its optical center at ICON_OPTICAL_CENTER_PCT of
 *     the master height. Composited as-is: the icon's own background is #0a0a0a
 *     (icon.json 1-bg = display-p3 0.03922...), identical to BG, so the mark
 *     floats on black with no visible tile edge — the chosen seamless look.
 *   - Wordmark: the single lowercase word "jazzlore" in Geist SemiBold (weight
 *     600), tracking -0.005em, amber #f4a233 (the web --accent-text brand color),
 *     visual width WORDMARK_WIDTH_FRAC of the icon width, baseline at
 *     WORDMARK_BASELINE_PCT of the master height.
 *
 * Geist is rendered from the in-repo woff2 (scripts/assets/geist-600.woff2,
 * vendored from the web monorepo) decompressed to sfnt and converted to vector
 * paths — no system-font dependency, pixel-exact glyphs.
 *
 * Run:  npm run splash:masters
 * Output (per app):  <app>/assets/splash-master.png
 *
 * GAP LEVER: icon optical center (42%) and wordmark baseline (85%) are precise
 * anchors from the brief; together they fix the icon->wordmark gap at ~0.73
 * icon-heights (logged below). If the gate finds that too tight, lower
 * ICON_OPTICAL_CENTER_PCT toward 0.40 to open the gap and re-run.
 */

import sharp from 'sharp'
import opentype from 'opentype.js'
import { decompress } from 'wawoff2'
import { readFileSync } from 'node:fs'
import { resolve } from 'node:path'

const ROOT = resolve(import.meta.dirname, '..')
const APPS = ['metronome', 'chords', 'scales']

// ---- Composition constants (master is a MASTER x MASTER square) ----
const MASTER = 2732
const BG = { r: 0x0a, g: 0x0a, b: 0x0a, alpha: 1 } // #0a0a0a
const ICON_PX = Math.round(MASTER * 0.35) // ~956px, 35% of master width
const ICON_OPTICAL_CENTER_PCT = 0.42 // optical center, from top (gap lever)
const WORDMARK = 'jazzlore'
const WORDMARK_FILL = '#f4a233' // --accent-text amber
const WORDMARK_WIDTH_FRAC = 0.375 // visual width as fraction of icon width
const WORDMARK_BASELINE_PCT = 0.85 // baseline, from top
const WORDMARK_TRACKING_EM = -0.005 // letter-spacing

// Derived icon geometry
const ICON_LEFT = Math.round((MASTER - ICON_PX) / 2)
const ICON_TOP = Math.round(MASTER * ICON_OPTICAL_CENTER_PCT - ICON_PX / 2)
const ICON_BOTTOM = ICON_TOP + ICON_PX

// ---- Wordmark layout (manual per-glyph so tracking + kerning are honored) ----
function layoutWordmark(font, text, fontSize, x0, baselineY) {
  const path = new opentype.Path()
  const glyphs = font.stringToGlyphs(text)
  const scale = fontSize / font.unitsPerEm
  const tracking = WORDMARK_TRACKING_EM * fontSize
  let x = x0
  for (let i = 0; i < glyphs.length; i++) {
    const glyph = glyphs[i]
    path.extend(glyph.getPath(x, baselineY, fontSize))
    x += glyph.advanceWidth * scale
    if (i < glyphs.length - 1) x += font.getKerningValue(glyph, glyphs[i + 1]) * scale
    x += tracking
  }
  return path
}

function translatePath(path, dx) {
  for (const cmd of path.commands) {
    if (cmd.x != null) cmd.x += dx
    if (cmd.x1 != null) cmd.x1 += dx
    if (cmd.x2 != null) cmd.x2 += dx
  }
  return path
}

async function loadGeist() {
  const woff2 = readFileSync(resolve(ROOT, 'scripts/assets/geist-600.woff2'))
  const ttf = await decompress(woff2) // Uint8Array (sfnt)
  return opentype.parse(ttf.buffer.slice(ttf.byteOffset, ttf.byteOffset + ttf.byteLength))
}

function buildWordmark(font) {
  const targetWidth = WORDMARK_WIDTH_FRAC * ICON_PX
  const centerX = MASTER / 2
  const baselineY = Math.round(MASTER * WORDMARK_BASELINE_PCT)

  // First pass at a reference size to measure visual width, then solve fontSize.
  const REF = 1000
  const refBox = layoutWordmark(font, WORDMARK, REF, 0, 0).getBoundingBox()
  const fontSize = (REF * targetWidth) / (refBox.x2 - refBox.x1)

  // Final layout at the solved size, then center horizontally on its visual bbox.
  let path = layoutWordmark(font, WORDMARK, fontSize, 0, baselineY)
  const box = path.getBoundingBox()
  translatePath(path, centerX - (box.x1 + box.x2) / 2)
  const finalBox = path.getBoundingBox()

  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${MASTER}" height="${MASTER}" viewBox="0 0 ${MASTER} ${MASTER}"><path d="${path.toPathData(2)}" fill="${WORDMARK_FILL}"/></svg>`
  return { svg, finalBox, baselineY }
}

async function main() {
  const font = await loadGeist()
  const { svg, finalBox, baselineY } = buildWordmark(font)

  // Gap diagnostics (icon bottom -> wordmark cap-line / baseline), in icon-heights.
  const gapToCap = finalBox.y1 - ICON_BOTTOM
  const gapToBaseline = baselineY - ICON_BOTTOM
  console.log(`Composition: master=${MASTER}  icon=${ICON_PX}px @ top=${ICON_TOP},left=${ICON_LEFT} (optical center ${(ICON_OPTICAL_CENTER_PCT * 100).toFixed(0)}%)`)
  console.log(`Wordmark "${WORDMARK}": baseline=${baselineY} (${(WORDMARK_BASELINE_PCT * 100).toFixed(0)}%), visual w=${(finalBox.x2 - finalBox.x1).toFixed(0)}px (${((finalBox.x2 - finalBox.x1) / ICON_PX * 100).toFixed(1)}% of icon)`)
  console.log(`Icon->wordmark gap: ${gapToCap.toFixed(0)}px to cap-line (${(gapToCap / ICON_PX).toFixed(2)} icon-h), ${gapToBaseline.toFixed(0)}px to baseline (${(gapToBaseline / ICON_PX).toFixed(2)} icon-h)`)

  const wordmarkBuf = Buffer.from(svg)
  for (const app of APPS) {
    const iconPath = resolve(ROOT, `${app}/assets/icon-only.png`)
    const out = resolve(ROOT, `${app}/assets/splash-master.png`)
    const icon = await sharp(iconPath).resize(ICON_PX, ICON_PX, { fit: 'fill' }).toBuffer()
    await sharp({ create: { width: MASTER, height: MASTER, channels: 4, background: BG } })
      .composite([
        { input: icon, top: ICON_TOP, left: ICON_LEFT },
        { input: wordmarkBuf, top: 0, left: 0 },
      ])
      .png()
      .toFile(out)
    console.log(`  ${app}/assets/splash-master.png`)
  }
  console.log('Done. 3 splash masters written.')
}

await main()
