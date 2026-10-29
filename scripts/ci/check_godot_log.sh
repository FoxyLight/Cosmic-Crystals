#!/usr/bin/env bash
# Godot can exit 0 despite GDScript parse errors in scenes that were imported or
# launched. CI must inspect the actual engine log, not just its process exit.
set -euo pipefail

if (( $# == 0 )); then
  echo "usage: bash scripts/ci/check_godot_log.sh <godot-command> [args...]" >&2
  exit 2
fi

logfile="$(mktemp)"
trap 'rm -f "$logfile"' EXIT

# pipefail preserves actual nonzero Godot exit codes, even while teeing output.
"$@" 2>&1 | tee "$logfile"

# Godot's parse/runtime diagnostics are not always reflected in the exit code.
# Match only engine ERROR/SCRIPT ERROR diagnostic markers, not routine 'Error'
# words in explanatory text, file paths, or print output from test fixtures.
if grep -Eq 'SCRIPT ERROR:|(^|[[:space:]])ERROR:|Parse Error:|Failed to load script' "$logfile"; then
  echo "::error::Godot emitted a script/parser/runtime error despite its exit code."
  exit 1
fi
