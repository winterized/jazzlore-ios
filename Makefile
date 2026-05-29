# Jazzlore iOS — build orchestration.
#
# Wraps the offline-first PWAs from github.com/winterized/jazzlore as native iOS apps.
# Each target builds an app's PWA in the web repo, copies its dist into the Capacitor
# project's web dir, and syncs the iOS native project.

# Path to a local checkout of the web monorepo (github.com/winterized/jazzlore).
JAZZLORE_WEB ?= $(HOME)/Documents/jazzlore

.PHONY: metronome

## metronome: build the Metronome PWA and sync it into the Capacitor iOS project
metronome:
	@echo "==> Building @jazzlore/metronome from $(JAZZLORE_WEB)"
	pnpm -C "$(JAZZLORE_WEB)" -F @jazzlore/metronome build
	@echo "==> Copying dist/ -> metronome/www/"
	rm -rf metronome/www
	mkdir -p metronome/www
	cp -R "$(JAZZLORE_WEB)/apps/metronome/dist/." metronome/www/
	@echo "==> cap sync ios"
	cd metronome && npx cap sync ios
	@echo "==> Done. Open in Xcode with:  cd metronome && npx cap open ios"
