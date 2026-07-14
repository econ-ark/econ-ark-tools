#!/usr/bin/env python3
"""Generate NOTATION.md from notation.yml + terminology.yml.

The human/agent-readable face of the registry: an at-a-glance symbol table plus
a details section (define / aliases / dialects / conflicts / ruling per symbol),
then the terminology rules (banned / defined / conventions).  This is the file
the consuming repos' AGENTS.md points sessions at.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _common as C  # noqa: E402

ARTIFACT = "NOTATION.md"


def cell(s):
    if s is None:
        return ""
    return str(s).replace("|", "\\|").replace("\n", " ")


def code(s):
    return f"`{cell(s)}`" if s else ""


def render(notation, terminology):
    v = C.version(notation)
    out = []
    out.append(f"# econark notation registry — v{v}")
    out.append("")
    out.append("**AUTO-GENERATED** from `notation.yml` + `terminology.yml`. DO NOT EDIT this "
               "file; edit the YAML and run `python gen/gen_markdown.py`. A notational or "
               "terminology ruling is a PR against the YAML (see `README.md`).")
    out.append("")
    out.append("## Symbols")
    out.append("")
    out.append("| Object | Symbol | Macro | Expansion | Python | Gloss |")
    out.append("|---|---|---|---|---|---|")
    for key, e in C.sorted_symbols(notation):
        latex = e.get("latex") or {}
        out.append("| {} | {} | {} | {} | {} | {} |".format(
            cell(key), cell(e.get("unicode")),
            code(latex.get("macro")), code(latex.get("expansion")),
            code(e.get("python")), cell(e.get("gloss")),
        ))
    out.append("")

    # Details: only symbols with something beyond the table columns.
    detail_keys = []
    for key, e in C.sorted_symbols(notation):
        if any(e.get(k) for k in ("define", "aliases", "dialects",
                                  "conflicts_checked", "ruling")):
            detail_keys.append((key, e))
    if detail_keys:
        out.append("## Definitions, dialects & rulings")
        out.append("")
        for key, e in detail_keys:
            out.append(f"### {key}")
            out.append("")
            if e.get("define"):
                out.append(f"- **define:** {cell(e['define'])}")
            for a in (e.get("aliases") or []):
                out.append(f"- **alias:** {cell(a)}")
            if e.get("conflicts_checked"):
                out.append(f"- **conflicts checked:** {cell(e['conflicts_checked'])}")
            for dkey, d in (e.get("dialects") or {}).items():
                bits = [f"expansion `{d.get('expansion','')}`"]
                if d.get("home"):
                    bits.append(f"home: {d['home']}")
                if d.get("status"):
                    bits.append(f"**{d['status']}**")
                if d.get("note"):
                    bits.append(d["note"])
                out.append(f"- **dialect `{dkey}`:** " + "; ".join(cell(b) for b in bits))
            r = e.get("ruling")
            if r:
                rbits = [f"{r.get('date','')}", f"source: {r.get('source','')}"]
                if r.get("rationale"):
                    rbits.append(f"rationale: {r['rationale']}")
                out.append(f"- **ruling:** " + " · ".join(cell(b) for b in rbits))
            out.append("")

    # Terminology
    out.append("## Terminology")
    out.append("")
    banned = terminology.get("banned") or []
    if banned:
        out.append("### Banned terms")
        out.append("")
        out.append("| Term | Use instead | Scope | Ruling |")
        out.append("|---|---|---|---|")
        for b in banned:
            r = b.get("ruling") or {}
            out.append("| {} | {} | {} | {} |".format(
                cell(b.get("term")), cell(b.get("use")),
                cell(b.get("scope") or "all prose"),
                cell(f"{r.get('date','')} ({r.get('source','')})"),
            ))
        out.append("")
    defined = terminology.get("defined") or []
    if defined:
        out.append("### Defined terms")
        out.append("")
        for d in defined:
            r = d.get("ruling") or {}
            out.append(f"- **{cell(d.get('term'))}** — {cell(d.get('definition'))} "
                       f"_(ruling {cell(r.get('date',''))}, {cell(r.get('source',''))})_")
        out.append("")
    conventions = terminology.get("conventions") or []
    if conventions:
        out.append("### Conventions")
        out.append("")
        for c in conventions:
            r = c.get("ruling") or {}
            out.append(f"- {cell(c.get('rule'))} "
                       f"_(ruling {cell(r.get('date',''))}, {cell(r.get('source',''))})_")
        out.append("")
    return "\n".join(out)


def main():
    out_dir = C.out_dir_from_argv()
    notation = C.load_notation()
    terminology = C.load_terminology()
    path = C.write(os.path.join(out_dir, ARTIFACT), render(notation, terminology))
    print(f"wrote {path}")


if __name__ == "__main__":
    main()
