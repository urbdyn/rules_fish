#!/usr/bin/env bash

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail; set +e; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v3 ---

# TODO: We could instead template imports here...

FISH_RLOCATION_PATH="${FISH_RLOCATION_PATH:-{FISH}}"
FISH="$(rlocation $FISH_RLOCATION_PATH)"

# TODO: also, bazel.fish and dependencies need moved to same directory as src fish script? Not sure how to make "source" work.
# well, how does sh_binary deal with deps? They have to be library targets but I don't remember how to use them. Oh deps
# go to runfiles too.

# TODO: template this with path to bazel.fish to support portability
export BAZEL_FISH="$(rlocation _main/rules_fish/bazel.fish)"

# TODO: in scripts, source bazel.fish? It will hold these helpers and be put in path here?
"$FISH" --no-config --private "{SRCS}" $@
