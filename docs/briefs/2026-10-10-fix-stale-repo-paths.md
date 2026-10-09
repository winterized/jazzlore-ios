# Replace the old ~/Documents repository paths in docs and comments

Slug: fix-stale-repo-paths
Effort: high
Depends on: makefile-web-repo-default

## Why

The repositories moved from `~/Documents` to `~/Developer` on 2026-10-09, because iCloud Drive syncs `~/Documents`. The Makefile now defaults to `~/Developer/jazzlore`, but other tracked files still name the old locations. The review of the Makefile task listed them: `docs/widget-content.md` (lines 19-23) tells the reader to run `cd ~/Documents/jazzlore && pnpm widget:content`, and there are mentions in `docs/widget-design.md`, `docs/ios26-liquid-glass-icons-design.md`, a comment in `scripts/generate-icon-layers.mjs`, and header comments in the `<app>/assets/icon-layers/*.svg` files. The old folders are being deleted, so a reader or a session that follows these paths ends up nowhere. According to that review, the widget content generator writes into the folder next to the web repository, so the command also has to start from the right place.

## Change

Every tracked file that says where the web repository (`jazzlore`), this repository (`jazzlore-ios`) or `JazzDBPopulator` lives, or gives a command that uses such a path, names the `~/Developer` location. Nothing else about those files changes.

## Decisions

- All mentions are updated, including those in older design documents, because the old locations will no longer exist and a stale path helps nobody.
- `docs/DECISIONS.md` and everything under `docs/briefs/` stay as written. They are the record of what was true and decided at the time, including the move itself.
- If the header comments in the icon-layer SVG files are written by `scripts/generate-icon-layers.mjs`, change the generator and the existing headers so that they agree. Do not regenerate the artwork: apart from the header comment, each SVG stays byte for byte the same.

## Out of scope

- Any change to what a script, generator or the Makefile does.
- Any change in the web repository. If the widget generator there has an old path built in, say so in the final report.
- Rewording or restructuring the documents beyond the paths.

## Done when

- `git grep -n -e "Documents/jazzlore" -e "Documents/JazzDBPopulator"` prints only lines in `docs/DECISIONS.md` and under `docs/briefs/`.
- `docs/widget-content.md` gives the content generation command starting from `~/Developer/jazzlore`.
- `git diff` for each changed SVG shows only header comment lines.
- `scripts/test.sh` passes.

## Check by hand

Nothing.

## Open questions

None.
