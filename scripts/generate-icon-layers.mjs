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
const APPS = ['metronome', 'chords', 'scales', 'musicians']
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
  console.log(`Done. ${APPS.length * LAYERS.length} layer PNGs written.`)
}

await main()
