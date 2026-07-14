#!/usr/bin/env python3
"""Generate notation-math.yml from notation.yml.

A mystmd config fragment carrying a `project.math` map (base dialect only),
consumed via `extends:` in a consuming project's myst.yml.  Structure matches
the existing mystmd-math-macros.yml the BST pipeline already produces:

    version: 1
    project:
      math:
        '\\macro': 'expansion'

Every expansion must be plain-KaTeX-renderable on its own (gate G0-4).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _common as C  # noqa: E402

ARTIFACT = "notation-math.yml"


def render(doc):
    v = C.version(doc)
    lines = [
        f"# notation-math.yml — AUTO-GENERATED from notation.yml v{v}. DO NOT EDIT.",
        "# Source of truth: @resources/notation/notation.yml (edit there, regenerate).",
        "# Consume via `extends: [<path>/notation-math.yml]` in your myst.yml.",
        "# Regenerate: python @resources/notation/gen/gen_myst.py",
        "version: 1",
        "project:",
        "  math:",
    ]
    for key, entry in C.macro_symbols(doc):
        macro = entry["latex"]["macro"]
        expansion = entry["latex"]["expansion"]
        # single-quote wrapping; the registry forbids single quotes in expansions
        if "'" in macro or "'" in expansion:
            raise ValueError(f"single quote in macro/expansion for {key!r}; "
                             "gen_myst cannot single-quote it safely")
        lines.append(f"    '{macro}': '{expansion}'")
    lines.append("")
    return "\n".join(lines)


def main():
    out_dir = C.out_dir_from_argv()
    doc = C.load_notation()
    path = C.write(os.path.join(out_dir, ARTIFACT), render(doc))
    print(f"wrote {path}")


if __name__ == "__main__":
    main()
