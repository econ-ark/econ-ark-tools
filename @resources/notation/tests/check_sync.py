#!/usr/bin/env python3
"""Verify the committed generated artifacts match what the generators produce.

Regenerates all four artifacts into a tempdir and byte-compares against the
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

ARTIFACTS = {
    "gen_latex.py": "econark-notation.sty",
    "gen_myst.py": "notation-math.yml",
    "gen_markdown.py": "NOTATION.md",
    "gen_lint.py": "notation-lint.sh",
}


def main():
    failures = []
    missing = []
    with tempfile.TemporaryDirectory() as tmp:
        for gen, artifact in sorted(ARTIFACTS.items()):
            r = subprocess.run([sys.executable, os.path.join(GEN, gen), "--out-dir", tmp],
                               capture_output=True, text=True)
            if r.returncode != 0:
                print(f"generator {gen} FAILED:\n{r.stderr}")
                return 2
            fresh = os.path.join(tmp, artifact)
            committed = os.path.join(NOTATION_DIR, artifact)
            if not os.path.exists(committed):
                missing.append(artifact)
                continue
            with open(fresh, "rb") as a, open(committed, "rb") as b:
                if a.read() != b.read():
                    failures.append(artifact)
    if missing:
        print("MISSING committed artifact(s):", ", ".join(missing))
    if failures:
        print("DRIFT: committed artifact(s) differ from their generators:",
              ", ".join(failures))
        print("Fix: rerun the generators and commit "
              "(e.g. `python gen/gen_latex.py`).")
    if missing or failures:
        return 1
    print(f"check_sync: all {len(ARTIFACTS)} artifacts match their generators.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
