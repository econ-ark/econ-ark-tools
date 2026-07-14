#!/usr/bin/env python3
"""Generate econark-notation.sty from notation.yml.

Emits one \\providecommand per registry symbol that carries a macro (base
dialect only — dialects are documentation, not macros).  \\providecommand
DEFERS to any macro already defined, so this file loads alongside
econark-shortcuts.sty without a clash: where a macro name is shared and the
expansions agree it is a no-op; where they differ (a declared MIGRATION-PENDING
dialect, e.g. \\PermGroFac), whatever is already loaded wins.  Load this file
alone (or first) to get the registry's base dialect.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _common as C  # noqa: E402

ARTIFACT = "econark-notation.sty"


def render(doc):
    v = C.version(doc)
    lines = [
        f"% econark-notation.sty — AUTO-GENERATED from notation.yml v{v}. DO NOT EDIT.",
        "% Source of truth: @resources/notation/notation.yml (edit there, regenerate).",
        "% Uses \\providecommand: defers to any macro already defined (e.g. by",
        "% econark-shortcuts.sty). Load alone/first for the registry's base dialect.",
        "% Regenerate: python @resources/notation/gen/gen_latex.py",
        "",
    ]
    for key, entry in C.macro_symbols(doc):
        macro = entry["latex"]["macro"]
        expansion = entry["latex"]["expansion"]
        lines.append(f"\\providecommand{{{macro}}}{{{expansion}}}  % {key}")
    lines.append("")
    return "\n".join(lines)


def main():
    out_dir = C.out_dir_from_argv()
    doc = C.load_notation()
    path = C.write(os.path.join(out_dir, ARTIFACT), render(doc))
    print(f"wrote {path}")


if __name__ == "__main__":
    main()
