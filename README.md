# Jazzlore iOS

Native iOS wrappers for the offline-first [Jazzlore](https://jazzlore.com) PWAs — built to
ship on the **App Store**. The web apps themselves live in the main monorepo at
[github.com/winterized/jazzlore](https://github.com/winterized/jazzlore); this repo wraps
their production builds as thin native shells using [Capacitor](https://capacitorjs.com).

## The pattern

Each app here is a **thin Capacitor shell** around an existing PWA:

- The web build is **bundled into the app** (no live URL) — fully offline, identical to the
  installed PWA experience.
- **No native UI, no extra capabilities/entitlements.** The only Capacitor plugin is
  `@capacitor/splash-screen` (for the branded launch/splash); otherwise the user sees the
  existing web UI full-screen, with the PWA's own safe-area handling.
- Capacitor serves the bundled assets from `capacitor://localhost`, so the PWA runs exactly
  as it does on the web.

## Monorepo layout

Each app is its own Capacitor project (Capacitor 8, SPM, iOS 16 deployment target). The
native `ios/` directory is committed and editable; generated artifacts (`www/`, build
output, DerivedData) are ignored.

| Dir          | Bundle ID                 | Home-screen name | App Store name        | Status  |
| ------------ | ------------------------- | ---------------- | --------------------- | ------- |
| `metronome/` | `com.jazzlore.metronome`  | Jazz Metronome   | Jazzlore Metronome    | shipped |
| `chords/`    | `com.jazzlore.chords`     | Jazz Chords      | Jazzlore Chords       | built   |
| `scales/`    | `com.jazzlore.scales`     | Jazz Scales      | Jazzlore Scales       | built   |

## Building an app

The web source lives in a **separate** repo. Point `JAZZLORE_WEB` at a local checkout of
[winterized/jazzlore](https://github.com/winterized/jazzlore) (defaults to
`~/Documents/jazzlore`), then run the per-app make target:

```sh
# Build a PWA, copy its dist into the Capacitor project, and sync iOS:
make metronome
make chords
make scales

# Custom path to the web repo:
make scales JAZZLORE_WEB=/path/to/jazzlore

# Then open in Xcode and ▶ Build & Run:
cd scales && npx cap open ios
```

`make <app>` runs `pnpm -F @jazzlore/<app> build` in the web repo, copies the resulting
`dist/` into `<app>/www/`, and runs `npx cap sync ios`.

## Icons & splash

Both are generated from per-app sources under `<app>/assets/` by repo-root scripts (run from
the repo root, not a web build):

```sh
# iOS 26 Liquid Glass icon layers -> <app>/assets/icon-layers/*.png:
npm run icons:layers

# Branded launch/splash master -> <app>/assets/splash-master.png:
npm run splash:masters
```

`splash:masters` composes the app mark (the flat `assets/icon-only.png`) plus the `jazzlore`
wordmark (Geist, rendered from a vendored woff2) on a `#0a0a0a` field. It writes **masters
only** — to update the shipped launch images, regenerate each app's `Splash.imageset` from its
master with `@capacitor/assets`, using an isolated `--assetPath` so the icon set is never
touched (the script prints the exact command on completion). The launch-screen background in
`ios/App/App/Base.lproj/LaunchScreen.storyboard` is `#0a0a0a` to match, and the splash is hidden
on web-app mount via `@capacitor/splash-screen` (configured in each `capacitor.config.ts`).

## Status

All three apps are bootstrapped to the same Capacitor pattern: **metronome** (the pilot,
shipped), **chords**, and **scales**. Private for now; will be open-sourced (MIT) once the
App Store submissions are settled.
