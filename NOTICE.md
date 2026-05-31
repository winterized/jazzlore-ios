# NOTICE

This repository is MIT-licensed (see [LICENSE](LICENSE)). Its runtime npm
dependencies — Capacitor and its plugins — are themselves MIT-licensed.

Beyond those, the repository bundles one piece of third-party content that
carries its own license:

## Geist (typeface)

`scripts/assets/geist-600.woff2` (Geist SemiBold / weight 600)

The **Geist** typeface is © Vercel, Inc., licensed under the
**SIL Open Font License, Version 1.1** (OFL-1.1).

It is vendored here solely as a **build-time input**: the splash-master
generator (`scripts/generate-splash-masters.mjs`) uses it to render the
"jazzlore" wordmark onto the splash master image. The font itself is **not**
embedded in, linked by, or redistributed within the shipped iOS apps.

- SIL Open Font License 1.1: <https://openfontlicense.org/>
- Geist: <https://vercel.com/font>
