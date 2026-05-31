# Jazzlore iOS

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Native iOS wrappers for the offline-first [Jazzlore](https://jazzlore.com) jazz reference apps —
the distribution layer that ships them on the **App Store**. The apps themselves live in the
public web monorepo at [github.com/winterized/jazzlore](https://github.com/winterized/jazzlore);
this repo wraps their production builds as thin native shells using
[Capacitor](https://capacitorjs.com).

## The pattern

Each app here is a **thin Capacitor shell** around an existing PWA:

- The web build is **bundled into the app** (no live URL) — fully offline, identical to the
  installed PWA experience.
- **No native UI, no extra capabilities or entitlements.** The only Capacitor plugin is
  `@capacitor/splash-screen` (for the branded launch/splash); otherwise the user sees the
  existing web UI full-screen, with the PWA's own safe-area handling.
- Capacitor serves the bundled assets from `capacitor://localhost`, so the PWA runs exactly
  as it does on the web.

## The apps

Each app is its own Capacitor project. The native `ios/` directory is committed and editable;
generated artifacts (`www/`, build output, `DerivedData`) are ignored.

| Dir                        | Bundle ID                | Home-screen name | App Store name     | Status  |
| -------------------------- | ------------------------ | ---------------- | ------------------ | ------- |
| [`metronome/`](metronome/) | `com.jazzlore.metronome` | Jazz Metronome   | Jazzlore Metronome | shipped |
| [`chords/`](chords/)       | `com.jazzlore.chords`    | Jazz Chords      | Jazzlore Chords    | built   |
| [`scales/`](scales/)       | `com.jazzlore.scales`    | Jazz Scales      | Jazzlore Scales    | built   |

**Metronome** is live on the App Store; **Chords** and **Scales** are built to the same pattern
and pending submission. You can try the web versions any time at [jazzlore.com](https://jazzlore.com).

## Architecture

- **Capacitor 8**, with the iOS platform managed via **Swift Package Manager** (no CocoaPods).
- **iOS 16+** deployment target.
- A **monorepo with one app per top-level subdirectory** (`metronome/`, `chords/`, `scales/`),
  each a self-contained Capacitor project with its own `package.json` and `ios/` tree.
- A shared **root `Makefile`** orchestrates builds: each `make <app>` target pulls the
  corresponding PWA's production build from the public web repo and syncs it into the shell.

## Prerequisites

- **Node 22+** and **pnpm** (the web repo is a pnpm workspace).
- **Xcode 26+** with the iOS 16 SDK or later.
- An **Apple Developer account** for code signing, if you intend to run on a device or submit to
  the App Store. (The simulator needs no account.)
- A local checkout of the web monorepo
  [winterized/jazzlore](https://github.com/winterized/jazzlore) — defaults to
  `~/Documents/jazzlore`; override with `JAZZLORE_WEB`.

## Building an app

The web source lives in a **separate** repo. Point `JAZZLORE_WEB` at a local checkout, then run
the per-app make target:

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

`make <app>` runs `pnpm -F @jazzlore/<app> build` in the web repo, copies the resulting `dist/`
into `<app>/www/`, and runs `npx cap sync ios`.

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

## Contributing

Free and **MIT-licensed** — issues and pull requests are welcome. This is primarily a personal
portfolio project, so response times are best-effort, but bug reports and suggestions are
appreciated.

A couple of notes for forks:

- The **bundle IDs** (`com.jazzlore.*`) and the App Store listings are reserved by the author.
  If you fork this to build your own apps, change the bundle IDs in each `capacitor.config.ts`
  and Xcode project to ones you own.
- The committed Apple **Team ID** is public metadata, not a secret; replace it with your own for
  signing.

## License

MIT © Aurélien Fontaine — see [LICENSE](LICENSE).

This repository also vendors the **Geist** typeface (© Vercel, SIL Open Font License 1.1), used
only at build time to render the splash wordmark. See [NOTICE.md](NOTICE.md).
