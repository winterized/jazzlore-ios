# Jazzlore iOS — build orchestration.
#
# Wraps the offline-first PWAs from github.com/winterized/jazzlore as native iOS apps.
# Each target builds an app's PWA in the web repo, copies its dist into the Capacitor
# project's web dir, and syncs the iOS native project.

# Path to a local checkout of the web monorepo (github.com/winterized/jazzlore).
JAZZLORE_WEB ?= $(HOME)/Documents/jazzlore

.PHONY: metronome chords scales musicians

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

## chords: build the Chords PWA and sync it into the Capacitor iOS project
chords:
	@echo "==> Building @jazzlore/chords from $(JAZZLORE_WEB)"
	pnpm -C "$(JAZZLORE_WEB)" -F @jazzlore/chords build
	@echo "==> Copying dist/ -> chords/www/"
	rm -rf chords/www
	mkdir -p chords/www
	cp -R "$(JAZZLORE_WEB)/apps/chords/dist/." chords/www/
	@echo "==> cap sync ios"
	cd chords && npx cap sync ios
	@echo "==> Done. Open in Xcode with:  cd chords && npx cap open ios"

## scales: build the Scales PWA and sync it into the Capacitor iOS project
scales:
	@echo "==> Building @jazzlore/scales from $(JAZZLORE_WEB)"
	pnpm -C "$(JAZZLORE_WEB)" -F @jazzlore/scales build
	@echo "==> Copying dist/ -> scales/www/"
	rm -rf scales/www
	mkdir -p scales/www
	cp -R "$(JAZZLORE_WEB)/apps/scales/dist/." scales/www/
	@echo "==> cap sync ios"
	cd scales && npx cap sync ios
	@echo "==> Done. Open in Xcode with:  cd scales && npx cap open ios"

## musicians: build the Musicians PWA and sync it into the Capacitor iOS project
musicians:
	@echo "==> Building @jazzlore/musicians from $(JAZZLORE_WEB)"
	pnpm -C "$(JAZZLORE_WEB)" -F @jazzlore/musicians build
	@echo "==> Copying dist/ -> musicians/www/"
	rm -rf musicians/www
	mkdir -p musicians/www
	cp -R "$(JAZZLORE_WEB)/apps/musicians/dist/." musicians/www/
	@echo "==> cap sync ios"
	cd musicians && npx cap sync ios
	@echo "==> Done. Open in Xcode with:  cd musicians && npx cap open ios"
