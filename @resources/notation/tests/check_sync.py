#!/usr/bin/env python3
"""Verify the committed generated artifacts match what the generators produce.

Regenerates every artifact into a tempdir and byte-compares against the
committed copies.  Nonzero exit on any drift.  Wire as CI / pre-commit, or run
`python tests/check_sync.py` as the pre-push ritual.
"""
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
NOTATION_DIR = os.path.dirname(HERE)
GEN = os.path.join(NOTATION_DIR, "gen")

# generator -> [(artifact name, committed path relative to the registry dir)]
ARTIFACTS = {
    "gen_latex.py": [("econark-notation.sty", "econark-notation.sty")],
    "gen_myst.py": [("notation-math.yml", "notation-math.yml")],
    "gen_markdown.py": [("NOTATION.md", "NOTATION.md")],
    "gen_lint.py": [("notation-lint.sh", "notation-lint.sh")],
    "gen_shortcuts.py": [("econark-math.yml", "econark-math.yml"),
                         ("econark-shortcuts.md", os.path.join("..", "markdown", "econark-shortcuts.md"))],
}


def main():
    failures = []
    missing = []
    with tempfile.TemporaryDirectory() as tmp:
        for gen, outputs in sorted(ARTIFACTS.items()):
            r = subprocess.run([sys.executable, os.path.join(GEN, gen), "--out-dir", tmp],
                               capture_output=True, text=True)
            if r.returncode != 0:
                print(f"generator {gen} FAILED:\n{r.stderr}")
                return 2
            for artifact, rel in outputs:
                fresh = os.path.join(tmp, artifact)
                committed = os.path.normpath(os.path.join(NOTATION_DIR, rel))
                if not os.path.exists(committed):
                    missing.append(rel)
                    continue
                with open(fresh, "rb") as a, open(committed, "rb") as b:
                    if a.read() != b.read():
                        failures.append(rel)
    if missing:
        print("MISSING committed artifact(s):", ", ".join(missing))
    if failures:
        print("DRIFT: committed artifact(s) differ from their generators:",
              ", ".join(failures))
        print("Fix: rerun the generators and commit "
              "(e.g. `python gen/gen_latex.py`).")
    if missing or failures:
        return 1
    n = sum(len(v) for v in ARTIFACTS.values())
    print(f"check_sync: all {n} artifacts match their generators.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
