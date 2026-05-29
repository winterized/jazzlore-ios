# Jazzlore iOS

Native iOS wrappers for the offline-first [Jazzlore](https://jazzlore.com) PWAs — built to
ship on the **App Store**. The web apps themselves live in the main monorepo at
[github.com/winterized/jazzlore](https://github.com/winterized/jazzlore); this repo wraps
their production builds as thin native shells using [Capacitor](https://capacitorjs.com).

## The pattern

Each app here is a **thin Capacitor shell** around an existing PWA:

- The web build is **bundled into the app** (no live URL) — fully offline, identical to the
  installed PWA experience.
- **No native UI, no extra capabilities/entitlements, no plugins beyond Capacitor core.** The
  user sees the existing web UI full-screen, with the PWA's own safe-area handling.
- Capacitor serves the bundled assets from `capacitor://localhost`, so the PWA runs exactly
  as it does on the web.

## Monorepo layout

```
metronome/   ← Capacitor project (pilot — the one that's built)
chords/      ← (planned)
scales/      ← (planned)
```

Each app is its own Capacitor project (`com.jazzlore.<app>`). The native `ios/` directory is
committed and editable; generated artifacts (`www/`, build output, DerivedData) are ignored.

## Building an app

The web source lives in a **separate** repo. Point `JAZZLORE_WEB` at a local checkout of
[winterized/jazzlore](https://github.com/winterized/jazzlore) (defaults to
`~/Documents/jazzlore`), then run the per-app make target:

```sh
# Build the metronome PWA, copy its dist into the Capacitor project, and sync iOS:
make metronome

# Custom path to the web repo:
make metronome JAZZLORE_WEB=/path/to/jazzlore

# Then open in Xcode and ▶ Build & Run:
cd metronome && npx cap open ios
```

`make <app>` runs `pnpm -F @jazzlore/<app> build` in the web repo, copies the resulting
`dist/` into `<app>/www/`, and runs `npx cap sync ios`.

## Status

Pilot stage — **metronome** proves the Capacitor pattern before it's replicated to chords
and scales. Private for now; will be open-sourced (MIT) once the pattern is settled.
