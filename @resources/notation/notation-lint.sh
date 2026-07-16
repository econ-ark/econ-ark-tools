#!/usr/bin/env bash
# notation-lint.sh — AUTO-GENERATED from terminology.yml (registry v1.0.0). DO NOT EDIT.
# Source of truth: @resources/notation/terminology.yml (edit there, regenerate).
# Regenerate: python @resources/notation/gen/gen_lint.py
# Exit 0 = clean; 1 = a banned term was found (review or waive it).
set -uo pipefail

SCOPE=()
WAIVE=""
while (($#)); do
  case "$1" in
    --scope) SCOPE+=("$2"); shift 2;;
    --waive) WAIVE="$2"; shift 2;;
    -h|--help) echo "usage: $0 --scope <path> [--scope ...] [--waive <file>]"; exit 0;;
    *) echo "unknown arg: $1" >&2; exit 2;;
  esac
done
((${#SCOPE[@]})) || SCOPE=(".")

EXCLUDES=(--exclude-dir=.git)
EXCLUDES+=(--exclude="notation.yml")
EXCLUDES+=(--exclude="terminology.yml")
EXCLUDES+=(--exclude="NOTATION.md")
EXCLUDES+=(--exclude="notation-lint.sh")
EXCLUDES+=(--exclude="CHANGELOG.md")
EXCLUDES+=(--exclude="RULING_TEMPLATE.md")
EXCLUDES+=(--exclude="README.md")
EXCLUDES+=(--exclude="DRIFT-AUDIT-2026-07.md")
if [[ -n "$WAIVE" && -f "$WAIVE" ]]; then
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    EXCLUDES+=(--exclude-dir="$line" --exclude="$line")
  done < "$WAIVE"
fi

STATUS=0
check() {
  local term="$1" repl="$2"
  local hits
  hits=$(grep -rniE "\b${term}\b" "${SCOPE[@]}" "${EXCLUDES[@]}" 2>/dev/null)
  if [[ -n "$hits" ]]; then
    printf "BANNED: %s  (use: %s)\n" "$term" "$repl"
    printf "%s\n" "$hits" | sed "s/^/  /"
    STATUS=1
  fi
}

check "production" "estimated / estimation"
check "certainty equivalent" "perfect foresight"
check "target band" "'the target' / 'the return region around the target m̂'"

if ((STATUS)); then
  echo "notation-lint: banned term(s) found (waive intentional uses with --waive)." >&2
else
  echo "notation-lint: clean."
fi
exit $STATUS
