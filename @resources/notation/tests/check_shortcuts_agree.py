#!/usr/bin/env python3
"""check_shortcuts_agree.py — every macro name in BOTH econark-shortcuts.sty and the registry
must print the same thing.

Typesets each shared macro twice with pdflatex, once with econark-notation.sty alone and once with
econark-shortcuts.sty alone, and compares the width, height and depth of the boxes. Different glyphs
almost always differ in some dimension; identical expansions written differently (\\Min{x} against
\\underline{x}) do not. Skips, exit 0, when pdflatex is not installed.

Exit 0 = all shared names agree; 1 = a mismatch; 2 = the test documents failed to compile.
"""
import os
import re
import shutil
import subprocess
import sys
import tempfile

import yaml

HERE = os.path.dirname(os.path.abspath(__file__))
NOTATION = os.path.dirname(HERE)
LATEX_DIR = os.path.join(NOTATION, "..", "texlive", "texmf-local", "tex", "latex")
STY = os.path.join(LATEX_DIR, "econark-shortcuts.sty")

PREAMBLE = r"""\documentclass{article}
\usepackage[T1]{fontenc}
\usepackage{amsmath,amssymb}
\usepackage[mathscr]{eucal}
"""


def shared_names():
    reg = yaml.safe_load(open(os.path.join(NOTATION, "notation.yml"), encoding="utf-8"))
    reg_macros = {(e.get("latex") or {}).get("macro") for e in reg["symbols"].values()} - {None}
    sty = open(STY, encoding="utf-8").read()
    sty_macros = set(re.findall(r"^\s*\\ARKcommand\{(\\[A-Za-z]+)\}", sty, re.M))
    return sorted(reg_macros & sty_macros)


def measure(tmp, package, names):
    body = "\n".join(
        r"\sbox0{$\displaystyle %s$}\typeout{AGREE|%s|\the\wd0|\the\ht0|\the\dp0}" % (n, n[1:])
        for n in names)
    tex = os.path.join(tmp, f"agree_{package}.tex")
    with open(tex, "w", encoding="utf-8") as f:
        f.write(PREAMBLE + f"\\usepackage{{{package}}}\n\\begin{{document}}\n{body}\n\\end{{document}}\n")
    env = dict(os.environ, TEXINPUTS=f"{NOTATION}:{os.path.abspath(LATEX_DIR)}//:")
    r = subprocess.run(["pdflatex", "-interaction=nonstopmode", "-halt-on-error", tex],
                       cwd=tmp, env=env, capture_output=True, text=True)
    log = open(os.path.join(tmp, f"agree_{package}.log"), encoding="latin-1").read()
    if r.returncode != 0:
        errs = [ln for ln in log.splitlines() if ln.startswith("!")][:5]
        print(f"check_shortcuts_agree: {package} failed to compile: {errs}")
        return None
    return {m.group(1): m.group(2) for m in re.finditer(r"AGREE\|(\w+)\|([^\n]+)", log)}


def main():
    if not shutil.which("pdflatex"):
        print("check_shortcuts_agree: pdflatex not found; skipped.")
        return 0
    names = shared_names()
    with tempfile.TemporaryDirectory() as tmp:
        reg = measure(tmp, "econark-notation", names)
        sc = measure(tmp, "econark-shortcuts", names)
    if reg is None or sc is None:
        return 2
    bad = [n for n in names if reg.get(n[1:]) != sc.get(n[1:])]
    for n in bad:
        print(f"  MISMATCH {n}: registry {reg.get(n[1:])}  shortcuts {sc.get(n[1:])}")
    if bad:
        print(f"check_shortcuts_agree: {len(bad)} of {len(names)} shared names print differently.")
        return 1
    print(f"check_shortcuts_agree: all {len(names)} shared names print the same in both files.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
