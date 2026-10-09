#!/bin/sh
# Builds the apps without running the tests: scripts/test.sh with BUILD_ONLY=1.
#   scripts/build.sh                  every app
#   scripts/build.sh musicians        only these apps
BUILD_ONLY=1 exec "$(dirname "$0")/test.sh" "$@"
