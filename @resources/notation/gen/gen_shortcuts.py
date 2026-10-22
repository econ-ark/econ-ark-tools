#!/usr/bin/env python3
"""Generate the web copies of econark-shortcuts.sty, so nobody edits them by hand.

The owner ruled (2026-10-22) that econark-shortcuts.sty stays hand-edited, and that its copies are
generated, with a drift test (tests/check_sync.py).  This writes two artifacts:

  econark-math.yml       a mystmd `project.math` map of EVERY shared macro: all of
                         econark-shortcuts.sty plus the registry's own rows, consumed via `extends:`.
  econark-shortcuts.md   the Markdown mirror at @resources/markdown/ (\\newcommand lines in a
                         {% raw %} block), which BufferStockTheory-make's MyST pipeline reads.

Both are KaTeX-safe: LaTeX-only constructs are rewritten (KATEX_REWRITES below).  Where a name is
in both files, the shortcuts' definition is used; tests/check_shortcuts_agree.py checks that the
two print the same glyph.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _common as C  # noqa: E402

ARTIFACTS = ("econark-math.yml", "econark-shortcuts.md")
STY = os.path.join(C.NOTATION_DIR, "..", "texlive", "texmf-local", "tex", "latex",
                   "econark-shortcuts.sty")
MIRROR_DIR = os.path.join(C.NOTATION_DIR, "..", "markdown")

# LaTeX-only constructs and their KaTeX forms, applied in order.
KATEX_REWRITES = [
    (r"\text{\fontencoding{T1}\selectfont\TH}", r"\text{Þ}"),
    (r"\text{\fontencoding{T1}\selectfont\th}", r"\text{þ}"),
    (r"\rotatebox{180}{$\uFunc$}", r"\uFunc^{-1}"),
    (r"\null", r"{}"),
]


def _group(s, i):
    """Return (content, end) of the brace group starting at s[i] == '{'."""
    assert s[i] == "{", s[i:i + 20]
    depth = 0
    for j in range(i, len(s)):
        if s[j] == "\\":
            continue
        if s[j] == "{" and (j == 0 or s[j - 1] != "\\"):
            depth += 1
        elif s[j] == "}" and s[j - 1] != "\\":
            depth -= 1
            if depth == 0:
                return s[i + 1:j], j + 1
    raise ValueError("unbalanced braces: " + s[i:i + 60])


def _unwrap(cmd, s, nargs, keep):
    """Replace every \\cmd{a1}...{a_nargs} by its keep-th argument (1-based)."""
    while True:
        k = s.find(cmd + "{")
        if k < 0:
            return s
        args, j = [], k + len(cmd)
        for _ in range(nargs):
            a, j = _group(s, j)
            args.append(a)
        s = s[:k] + args[keep - 1] + s[j:]


def katex_safe(expansion):
    for a, b in KATEX_REWRITES:
        expansion = expansion.replace(a, b)
    expansion = _unwrap(r"\ensuremath", expansion, 1, 1)
    expansion = _unwrap(r"\hyperlink", expansion, 2, 2)
    expansion = _unwrap(r"\href", expansion, 2, 2)
    expansion = re.sub(r"\\sb(?![A-Za-z])", "_", expansion)
    expansion = re.sub(r"\\sp(?![A-Za-z])", "^", expansion)
    return expansion


def read_shortcuts():
    """[(name, nargs, expansion)] in file order, from \\ARKcommand and \\ARKcommandParam lines."""
    text = open(STY, encoding="utf-8").read()
    out, seen = [], set()
    for line in text.split("\n"):
        stripped = line.lstrip()
        if stripped.startswith("%"):
            continue
        m = re.match(r"\\ARKcommand(Param)?\{(\\[A-Za-z]+)\}", stripped)
        if not m:
            continue
        j = m.end()
        nargs = 0
        if m.group(1):
            n, j = _group(stripped, j)
            nargs = int(n)
        exp, j = _group(stripped, j)
        name = m.group(2)
        if name in seen:          # a later \ARKcommand wins in LaTeX; keep the last
            out = [t for t in out if t[0] != name]
        seen.add(name)
        out.append((name, nargs, exp))
    return out


def merged(doc):
    """Shortcuts first (file order), then registry-only macros (by key)."""
    entries = [(n, a, katex_safe(e)) for n, a, e in read_shortcuts()]
    names = {n for n, _, _ in entries}
    for _, entry in C.macro_symbols(doc):
        macro = entry["latex"]["macro"]
        if macro not in names:
            entries.append((macro, 0, entry["latex"]["expansion"]))
            names.add(macro)
    return entries


def _yaml_squote(s):
    return "'" + s.replace("'", "''") + "'"


def render_map(doc):
    v = C.version(doc)
    lines = [
        f"# econark-math.yml — AUTO-GENERATED from econark-shortcuts.sty and notation.yml v{v}. DO NOT EDIT.",
        "# Every shared macro, KaTeX-safe. Consume via `extends: [<path>/econark-math.yml]` in myst.yml.",
        "# Regenerate: python @resources/notation/gen/gen_shortcuts.py",
        "version: 1",
        "project:",
        "  math:",
    ]
    for name, _, exp in merged(doc):
        lines.append(f"    {_yaml_squote(name)}: {_yaml_squote(exp)}")
    return "\n".join(lines) + "\n"


def render_mirror(doc):
    v = C.version(doc)
    lines = [f"<!-- AUTO-GENERATED from econark-shortcuts.sty (registry v{v}) by "
             "@resources/notation/gen/gen_shortcuts.py. DO NOT EDIT. -->",
             "{% raw %}", ""]
    for name, nargs, exp in merged(doc):
        arg = f"[{nargs}]" if nargs else ""
        lines.append(f"\\newcommand{{{name}}}{arg}{{{exp}}}")
    lines += ["", "{% endraw %}"]
    return "\n".join(lines) + "\n"


def main():
    out_dir = C.out_dir_from_argv(default="__default__")
    doc = C.load_notation()
    if out_dir == "__default__":
        targets = (os.path.join(C.NOTATION_DIR, ARTIFACTS[0]), os.path.join(MIRROR_DIR, ARTIFACTS[1]))
    else:
        targets = tuple(os.path.join(out_dir, a) for a in ARTIFACTS)
    print("wrote", C.write(targets[0], render_map(doc)))
    print("wrote", C.write(targets[1], render_mirror(doc)))


if __name__ == "__main__":
    main()
