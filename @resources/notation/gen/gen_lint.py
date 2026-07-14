#!/usr/bin/env python3
"""Generate notation-lint.sh from terminology.yml.

The lint is a HEURISTIC gate: it word-boundary-greps for each banned term and
reports offending file:line so a human can confirm (some bans are sense-specific
— e.g. 'production' is banned only in the software sense — which grep cannot
disambiguate; that is what --waive and human review are for).  Model: the G1
battery that verified the 2026-07-14 BST revision.

Usage of the generated script:
    notation-lint.sh --scope <path> [--scope <path> ...] [--waive <file>]
The waiver file lists directory-name / file-name globs (grep --exclude semantics),
one per line (# comments allowed) — e.g. run logs, inputs, refuter-reviewed proofs,
THEOREM-REF-pinned files.  See README.md for the default config block.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _common as C  # noqa: E402

ARTIFACT = "notation-lint.sh"

# The registry's own files legitimately name the banned terms; always exclude them.
SELF_EXCLUDE = [
    "notation.yml", "terminology.yml", "NOTATION.md", "notation-lint.sh",
    "CHANGELOG.md", "RULING_TEMPLATE.md", "README.md", "DRIFT-AUDIT-2026-07.md",
]


def sh_dq(s):
    """Escape for a bash double-quoted string."""
    return s.replace("\\", "\\\\").replace('"', '\\"').replace("$", "\\$").replace("`", "\\`")


def ere(s):
    """Escape ERE metacharacters so a term is matched literally."""
    out = []
    for ch in s:
        if ch in r".[]{}()*+?^$|\\":
            out.append("\\" + ch)
        else:
            out.append(ch)
    return "".join(out)


def render(notation, terminology):
    v = C.version(notation)
    banned = terminology.get("banned") or []
    lines = []
    lines.append("#!/usr/bin/env bash")
    lines.append(f"# notation-lint.sh — AUTO-GENERATED from terminology.yml (registry v{v}). DO NOT EDIT.")
    lines.append("# Source of truth: @resources/notation/terminology.yml (edit there, regenerate).")
    lines.append("# Regenerate: python @resources/notation/gen/gen_lint.py")
    lines.append("# Exit 0 = clean; 1 = a banned term was found (review or waive it).")
    lines.append("set -uo pipefail")
    lines.append("")
    lines.append("SCOPE=()")
    lines.append('WAIVE=""')
    lines.append("while (($#)); do")
    lines.append('  case "$1" in')
    lines.append('    --scope) SCOPE+=("$2"); shift 2;;')
    lines.append('    --waive) WAIVE="$2"; shift 2;;')
    lines.append('    -h|--help) echo "usage: $0 --scope <path> [--scope ...] [--waive <file>]"; exit 0;;')
    lines.append('    *) echo "unknown arg: $1" >&2; exit 2;;')
    lines.append("  esac")
    lines.append("done")
    lines.append('((${#SCOPE[@]})) || SCOPE=(".")')
    lines.append("")
    lines.append("EXCLUDES=(--exclude-dir=.git)")
    # default self-exclusions
    for name in SELF_EXCLUDE:
        lines.append(f'EXCLUDES+=(--exclude="{name}")')
    lines.append('if [[ -n "$WAIVE" && -f "$WAIVE" ]]; then')
    lines.append('  while IFS= read -r line; do')
    lines.append('    [[ -z "$line" || "$line" == \\#* ]] && continue')
    lines.append('    EXCLUDES+=(--exclude-dir="$line" --exclude="$line")')
    lines.append('  done < "$WAIVE"')
    lines.append("fi")
    lines.append("")
    lines.append("STATUS=0")
    lines.append("check() {")
    lines.append('  local term="$1" repl="$2"')
    lines.append("  local hits")
    lines.append('  hits=$(grep -rniE "\\b${term}\\b" "${SCOPE[@]}" "${EXCLUDES[@]}" 2>/dev/null)')
    lines.append('  if [[ -n "$hits" ]]; then')
    lines.append('    printf "BANNED: %s  (use: %s)\\n" "$term" "$repl"')
    lines.append('    printf "%s\\n" "$hits" | sed "s/^/  /"')
    lines.append("    STATUS=1")
    lines.append("  fi")
    lines.append("}")
    lines.append("")
    for b in banned:
        term = ere(b["term"])
        repl = b.get("use", "")
        lines.append(f'check "{sh_dq(term)}" "{sh_dq(repl)}"')
    lines.append("")
    lines.append('if ((STATUS)); then')
    lines.append('  echo "notation-lint: banned term(s) found (waive intentional uses with --waive)." >&2')
    lines.append("else")
    lines.append('  echo "notation-lint: clean."')
    lines.append("fi")
    lines.append("exit $STATUS")
    lines.append("")
    return "\n".join(lines)


def main():
    out_dir = C.out_dir_from_argv()
    notation = C.load_notation()
    terminology = C.load_terminology()
    path = C.write(os.path.join(out_dir, ARTIFACT), render(notation, terminology))
    os.chmod(path, 0o755)
    print(f"wrote {path}")


if __name__ == "__main__":
    main()
