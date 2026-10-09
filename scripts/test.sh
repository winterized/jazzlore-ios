#!/bin/sh
# Builds every app and runs every test. Exits 0 only if all of it passed.
#
#   scripts/test.sh                       everything
#   scripts/test.sh musicians chords      only these apps (metronome chords scales musicians)
#   scripts/test.sh musicians -only-testing:MusicianWidgetTests/MusicianRotationTests
#                                         options starting with "-" go to the Musicians test run
#   BUILD_ONLY=1 scripts/test.sh          build without running the tests
#
# Needs no terminal and no prior setup: each app gets `npm ci` when its
# node_modules is missing or stale, and, when it has no web bundle, a
# placeholder one (the real one comes from `make <app>`). Each checkout has
# its own derived data and its own simulator, so worktrees can run this at
# the same time. Prints failures and a summary; full logs go to .build-cli/.

set -u

ALL_APPS="metronome chords scales musicians"
DEVICE="iPhone 17"   # device type for the test simulator; the runtime is the newest installed

top=$(git rev-parse --show-toplevel) && cd "$top" || exit 1
main=$(dirname "$(cd "$(git rev-parse --git-common-dir)" && pwd -P)")
repo=$(basename "$main")
out="$top/.build-cli"
mkdir -p "$out"

apps=""
for arg in "$@"; do
  case $arg in
    -*) ;;
    metronome|chords|scales|musicians) apps="$apps $arg" ;;
    *) echo "test.sh: unknown argument: $arg (apps: $ALL_APPS; xcodebuild options start with -)" >&2; exit 2 ;;
  esac
done
[ -n "$apps" ] || apps=$ALL_APPS
# What remains in "$@" after this loop: only the xcodebuild options, in order.
n=$#
while [ "$n" -gt 0 ]; do
  case $1 in -*) set -- "$@" "$1" ;; esac
  shift; n=$((n - 1))
done

failed=""
start_all=$(date +%s)

# step NAME LOG COMMAND...: runs COMMAND with its output in LOG and reports the result.
step() {
  name=$1 log=$2; shift 2
  t0=$(date +%s)
  if "$@" > "$log" 2>&1; then
    echo "ok    $name ($(( $(date +%s) - t0 ))s)"
  else
    echo "FAIL  $name ($(( $(date +%s) - t0 ))s)"
    grep -E 'error:|\*\* [A-Z -]+ FAILED \*\*|Executed [0-9]+ tests?|Test run with|: failed|✘|npm (ERR|error)' "$log" |
      sort -u | tail -n 40 | sed 's/^/      /'
    echo "      full log: $log"
    failed="$failed $name"
  fi
}

tree_before=$(git diff HEAD | shasum)

# Sync-conflict copies ("config 2.xml", "Portraits 2.xcassets/...") must never be tracked.
conflict_copies() {
  if git ls-files | grep -E '(^|/)[^/]* 2(\.[^/]*)?(/|$)'; then
    echo "tracked files named '<name> 2.<ext>' are sync-conflict copies; remove them"
    return 1
  fi
}
step "no conflict copies" "$out/conflict-copies.log" conflict_copies

node_check() {
  for f in $(git ls-files 'scripts/*.mjs'); do node --check "$f" || return 1; done
}
step "node --check scripts" "$out/node-check.log" node_check

# Installs the app's npm dependencies (the Swift packages point into
# node_modules) and makes sure the files `cap sync` generates exist.
bootstrap() {
  app=$1
  if [ ! -f "$app/node_modules/.package-lock.json" ] ||
     [ "$app/package-lock.json" -nt "$app/node_modules/.package-lock.json" ]; then
    (cd "$app" && npm ci --prefer-offline --no-audit --no-fund) || return 1
  fi
  gen="$app/ios/App/App"
  if [ ! -d "$gen/public" ] || [ ! -f "$gen/capacitor.config.json" ] || [ ! -f "$gen/config.xml" ]; then
    if [ ! -f "$app/www/index.html" ]; then
      mkdir -p "$app/www"
      printf '<!doctype html>\n<title>placeholder</title>\n<p>Placeholder web bundle written by scripts/test.sh. Run <code>make %s</code> for the real one.</p>\n' "$app" \
        > "$app/www/index.html"
    fi
    (cd "$app" && npx --no-install cap copy ios) || return 1
  fi
}

build() {
  app=$1
  xcodebuild build \
    -project "$app/ios/App/App.xcodeproj" \
    -scheme App \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$out/$app/DerivedData" \
    -onlyUsePackageVersionsFromResolvedFile \
    CODE_SIGNING_ALLOWED=NO
}

for app in $apps; do
  step "setup $app" "$out/$app-setup.log" bootstrap "$app" &&
    step "build $app" "$out/$app-build.log" build "$app"
done

# One simulator per checkout, so runs in parallel worktrees never share a device.
simulator() {
  sim="cc-$repo-$(basename "$top")"
  devices=$(xcrun simctl list devices -j) || return 1
  # A simulator whose runtime is gone (after an Xcode update) is unavailable: replace it.
  printf '%s' "$devices" |
    jq -r --arg n "$sim" '.devices[][] | select(.name == $n and .isAvailable != true) | .udid' |
    while read -r id; do xcrun simctl delete "$id" >/dev/null 2>&1; done
  udid=$(printf '%s' "$devices" |
         jq -r --arg n "$sim" '[.devices[][] | select(.name == $n and .isAvailable == true)][0].udid // empty')
  if [ -z "$udid" ]; then
    udid=$(xcrun simctl create "$sim" "$DEVICE" 2>/dev/null) ||
      udid=$(xcrun simctl create "$sim" "$(xcrun simctl list devicetypes -j |
             jq -r '[.devicetypes[] | select(.productFamily == "iPhone")][-1].identifier')") || return 1
  fi
  # Delete the simulators of worktrees that no longer exist.
  printf '%s' "$devices" |
    jq -r --arg p "cc-$repo-" '.devices[][] | select(.name | startswith($p)) | "\(.udid) \(.name)"' |
    while read -r id name; do
      checkout=${name#"cc-$repo-"}
      [ "$checkout" = "$repo" ] || [ -d "$main/.claude/worktrees/$checkout" ] ||
        xcrun simctl delete "$id" >/dev/null 2>&1
    done
  echo "$udid"
}

musician_tests() {
  rm -rf "$out/musicians-tests.xcresult"
  xcodebuild test \
    -project musicians/ios/App/App.xcodeproj \
    -scheme MusicianWidgetTests \
    -destination "platform=iOS Simulator,id=$udid" \
    -derivedDataPath "$out/musicians/DerivedData" \
    -resultBundlePath "$out/musicians-tests.xcresult" \
    -onlyUsePackageVersionsFromResolvedFile \
    CODE_SIGNING_ALLOWED=NO \
    "$@"
  status=$?
  xcrun simctl shutdown "$udid" >/dev/null 2>&1
  return $status
}

case " $apps " in
  *" musicians "*)
    if [ -z "${BUILD_ONLY:-}" ]; then
      if udid=$(simulator 2> "$out/simulator.log" | tail -n 1) && [ -n "$udid" ]; then
        step "test musicians" "$out/musicians-test.log" musician_tests "$@"
        grep -E 'Executed [0-9]+ tests?' "$out/musicians-test.log" | tail -n 1 | sed 's/^/      /'
      else
        echo "FAIL  simulator: could not find or create $DEVICE simulator (see $out/simulator.log)"
        failed="$failed simulator"
      fi
    fi ;;
esac

if [ "$(git diff HEAD | shasum)" != "$tree_before" ]; then
  echo "FAIL  scripts/test.sh changed tracked files:"
  git status --short | grep -v '^??' | sed 's/^/      /'
  failed="$failed tracked-files"
fi

echo "logs: $out/"
if [ -n "$failed" ]; then
  echo "FAILED:$failed ($(( $(date +%s) - start_all ))s)"
  exit 1
fi
echo "PASSED ($(( $(date +%s) - start_all ))s)"
