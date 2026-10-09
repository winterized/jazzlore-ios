# Point the Makefile's default web repository at ~/Developer/jazzlore

Slug: makefile-web-repo-default
Effort: high
Depends on: record-review-policy

## Why

`make <app>` builds an app's PWA in a local checkout of the web repository, winterized/jazzlore, found through `JAZZLORE_WEB`. Its default is still `~/Documents/jazzlore`. That folder is synced by iCloud Drive, which has copied conflict files such as `config 2.xml` into the web build and from there into this repository. The working checkout of the web repository is now `~/Developer/jazzlore`. With the old default, a plain `make <app>` silently builds from the old, synced copy.

## Change

- `make <app>` with no `JAZZLORE_WEB` builds from `~/Developer/jazzlore`.
- Passing `JAZZLORE_WEB=<path>` still overrides the default, as it does today.
- The README and `CLAUDE.md` describe the new default; `CLAUDE.md` no longer tells sessions to pass `JAZZLORE_WEB` by hand.

## Decisions

- The default is `$(HOME)/Developer/jazzlore`, because that is where repositories live now, outside iCloud.
- The override variable keeps its name, `JAZZLORE_WEB`, so existing commands keep working.

## Out of scope

- Any change to the web repository.
- Any other change to what `make <app>` does.
- Moving or deleting `~/Documents/jazzlore`.

## Done when

- The `Makefile` default for `JAZZLORE_WEB` is `$(HOME)/Developer/jazzlore`.
- `make -n metronome` prints commands that use `$HOME/Developer/jazzlore`, expanded, and `make -n metronome JAZZLORE_WEB=/tmp/x` shows `/tmp/x`.
- The README's prerequisites and build sections and the `CLAUDE.md` commands name the new default.
- `docs/DECISIONS.md` records the new default and why.
- `scripts/test.sh` passes.

## Check by hand

Run `make metronome` once with no arguments, then open the app in the simulator and see the real Metronome, not a placeholder page.

## Open questions

None.
