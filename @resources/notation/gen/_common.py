"""Shared loader for the econark-notation generators.

Each generator (gen_latex, gen_myst, gen_markdown, gen_lint) reads the registry
from the fixed source files next to this module's parent directory and writes
one artifact.  Output location is overridable with --out-dir (used by
tests/check_sync.py to regenerate into a tempdir and byte-compare).

Determinism: symbols are always emitted sorted by semantic key; NO timestamps
appear in any generated file (the registry version is the only version marker),
so re-running a generator is byte-identical.
"""
import argparse
import os

import yaml

HERE = os.path.dirname(os.path.abspath(__file__))
NOTATION_DIR = os.path.dirname(HERE)


def load_notation():
    with open(os.path.join(NOTATION_DIR, "notation.yml"), encoding="utf-8") as f:
        return yaml.safe_load(f)


def load_terminology():
    with open(os.path.join(NOTATION_DIR, "terminology.yml"), encoding="utf-8") as f:
        return yaml.safe_load(f)


def version(doc):
    return str(doc["meta"]["version"])


def sorted_symbols(doc):
    """(key, entry) pairs sorted by semantic key."""
    return sorted(doc["symbols"].items())


def macro_symbols(doc):
    """Only the symbols that carry a LaTeX macro, sorted by key."""
    out = []
    for key, entry in sorted_symbols(doc):
        latex = entry.get("latex") or {}
        if latex.get("macro"):
            out.append((key, entry))
    return out


def out_dir_from_argv(default=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("--out-dir", default=default or NOTATION_DIR,
                    help="directory to write the artifact into (default: the registry dir)")
    args = ap.parse_args()
    return args.out_dir


def write(path, text):
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    return path
