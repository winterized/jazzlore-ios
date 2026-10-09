# Jazzlore iOS

App Store wrappers for the offline-first Jazzlore PWAs: four thin Capacitor 8 shells (Metronome, Chords, Scales, Musicians) plus the native "musician of the day" widget in Musicians. The web apps are in a separate repository, winterized/jazzlore; this one holds only the native shells, their Xcode projects, and the icon and splash tooling.

## Commands

- Build and run every test: `scripts/test.sh`
- Narrower: `scripts/test.sh musicians` (any of metronome, chords, scales, musicians); options starting with `-` go to the Musicians test run, e.g. `scripts/test.sh musicians -only-testing:MusicianWidgetTests/MusicianRotationTests`. `scripts/build.sh [app…]` builds without testing (a warm build of all four takes a few seconds; the tests add about 15). Logs are in `.build-cli/`.
- A fresh worktree needs no setup: `scripts/test.sh` runs `npm ci` per app and, when an app has no web bundle, builds against a placeholder one. Never commit `www/`, `ios/App/App/public/`, `capacitor.config.json` or `config.xml`.
- The real web bundle, to run or archive an app: `make <app>`, then `cd <app> && npx cap open ios`. It builds from `~/Developer/jazzlore` (`JAZZLORE_WEB=<path>` picks another checkout), with whatever that repository has checked out.
- Icon layers and splash masters: `npm ci` at the root, then `npm run icons:layers` or `npm run splash:masters`.

## Project memory

The repository is the memory; no chat or session is.

- `docs/ARCHITECTURE.md`: how the system is built today.
- `docs/DECISIONS.md`: dated decisions and their reasons, newest last.
- `docs/briefs/`: the brief of every task, as I wrote it.

## How a task runs

One brief is one task. Each task runs in its own git worktree and branch, so that two or three can run side by side, and it reaches `main` only through `.claude/hooks/land.sh`. I approve the plan and read the result. I am not watching in between, so once the plan is approved, carry the task through to the end without checking in.

1. **Plan.** Read the brief, `docs/ARCHITECTURE.md` and `docs/DECISIONS.md`, then present a plan.
2. **Start.** After I approve: if the session is on `main`, enter a worktree named after the brief's slug before changing anything. Save the brief exactly as I gave it to `docs/briefs/<YYYY-MM-DD>-<slug>.md` and commit it first. The reviewer reads the brief from that file.
3. **Implement.** Commit as you go.
4. **Keep the memory true**, in the same branch. Update `docs/ARCHITECTURE.md` when the change makes it wrong. Append to `docs/DECISIONS.md` each decision the brief records and each choice of yours that a later session would need to know about.
5. **Test.** Run `scripts/test.sh` until it passes, then commit everything so the working tree is clean.
6. **Review.** Delegate to the `reviewer` subagent, giving it only the branch name and the path of the brief. Don't tell it what you did or where to look: it works from the diff. Wait for its report. A hook saves the report; you don't write it anywhere.
7. **If the verdict is BLOCK**, fix every blocker and major finding, run the tests, commit, and ask for one more review. Two reviews per task is the limit. If you think a finding is wrong, don't work around it: stop and tell me which finding and why.
8. **If the verdict is PASS**, run `.claude/hooks/land.sh`. It runs the tests again on exactly what will land, merges and pushes. It can take as long as the test suite, so give it time or run it in the background. If it refuses, do what its message says. If that calls for a third review, stop and tell me.
9. **Report.** Say whether the task landed, and as which commit, or where it stopped and why. Give the command that shows the task's whole diff and the path of each review report. List every finding that was not fixed, minor ones included, in one line each.

Things that are mine:

- `.claude/settings.json`, `.claude/hooks/` and `.claude/agents/reviewer.md` are write-protected, and `land.sh` refuses a branch that changes them. If a task seems to need a change there, stop and tell me.
- `git push` is blocked for sessions. `land.sh` is the only way onto `main`.

## Conventions

- Web app behaviour lives in winterized/jazzlore, not here. A fix to what the web UI does is a change in that repository. When a problem's cause is in the web repository, don't work around it here: say so in the final report, with the evidence.
- `<app>/ios/App/CapApp-SPM/Package.swift` belongs to the Capacitor CLI. Add a plugin with `npm install` in the app, then `npx cap sync ios`; don't hand-edit it.
- Xcode project changes are made by editing `project.pbxproj`, mirroring an existing entry (file reference, build file, group child, build phase). `AppIcon.icon` packages come from Icon Composer; never hand-edit their `icon.json`.
- `@capacitor/assets generate` also regenerates the app icon when it finds `<app>/assets/icon-only.png`. Generate splash images from an isolated `--assetPath`; `npm run splash:masters` prints the command.
- Signing team `V78LBF2887` is committed on purpose; signing keys and profiles never are. Every App Store upload needs a higher `CURRENT_PROJECT_VERSION`.
- The Musicians widget pool (`MusicianWidget/Resources/musicians.json` and `Portraits.xcassets`) is generated in the web repository by `pnpm widget:content`. The imagesets on disk must match the pool (39 today); a missing portrait does not fail the build.
- Files named `<name> 2.<ext>` are sync-conflict copies. Never commit one; `scripts/test.sh` fails if one is tracked.
