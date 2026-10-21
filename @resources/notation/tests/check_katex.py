#!/usr/bin/env python3
"""check_katex.py — guard the font choices this corpus makes against what KaTeX can actually render.

THE FAILURE THIS EXISTS TO PREVENT. KaTeX ships its Caligraphic, Script and AMS-blackboard fonts in
UPPERCASE ONLY. Ask it for a lowercase one and it does not error and does not draw a box: it renders
ordinary math italic, indistinguishable from an unstyled variable. Measured with KaTeX 0.18.4 —
`\\mathscr{g}` emits the glyph class `mathnormal`, byte-identical to plain `g`.

That is the worst shape of rendering bug for a notation registry. A missing glyph would be caught by
eye; a silent downgrade to "ordinary variable" is invisible, and it is *asymmetric* when only one
half of a pair is affected: `\\FDist` = \\mathcal{F} renders as a caligraphic F while `\\fDist` =
\\mathcal{f} renders as a plain f, so the distribution looks special and its density looks like any
other variable.

THE RULE. A symbol that needs BOTH cases must take its font from a family KaTeX has in both:
    mathrm, mathit, mathbf, mathsf, mathtt, mathfrak
The uppercase-only families
    mathcal, mathscr, mathbb
may be assigned to UPPERCASE symbols only.

MathJax draws real outlines for all of these, so the PDF and MathJax paths are unaffected. The
registry's own MyST output is a KaTeX path, which is why this is gated here.

Two checks:
  * STATIC (always runs, needs only Python): scan the notation sources for an uppercase-only font
    applied to a lowercase letter. Deterministic, no toolchain.
  * DYNAMIC (runs only when a node KaTeX is reachable): render each expansion and flag any that comes
    back wearing the plain-italic class while having asked for a styled font. This is what would
    catch a NEW gap if KaTeX's font coverage changes under us.

Exit 0 = clean; 1 = a new violation. Known violations are waived explicitly below so the gate can
land green while the debt stays visible in code rather than in a review comment.
"""
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
NOTATION = os.path.dirname(HERE)
REPO = os.path.dirname(os.path.dirname(NOTATION))

UPPERCASE_ONLY = ("mathcal", "mathscr", "mathbb")
BOTH_CASES = ("mathrm", "mathit", "mathbf", "mathsf", "mathtt", "mathfrak")

SCAN = [
    os.path.join(NOTATION, "notation.yml"),
    os.path.join(NOTATION, "econark-notation.sty"),
    os.path.join(REPO, "@resources", "texlive", "texmf-local", "tex", "latex",
                 "econark-shortcuts.sty"),
]

# Pre-existing violations, waived so this gate can land without bundling a notational ruling.
# Each needs a decision about the SYMBOL, not just the font -- see the note.
KNOWN = {
    r"\mathscr{g}": (
        "\\PtyGroRte. Already documented inline in econark-shortcuts.sty. Its partner "
        "\\PtyGroFac = \\mathscr{G} renders correctly, so substituting only the lowercase would "
        "leave the factor/rate pair visually unlinked -- the PAIR should move to a both-cases "
        "font (mathfrak or mathsf). That is a ruling, not a fix."),
    r"\mathcal{f}": (
        "\\fDist, found 2026-08-30. Partner \\FDist = \\mathcal{F} renders correctly, so the "
        "density silently reads as an ordinary variable f while the distribution reads as special. "
        "Candidate: \\mathrm{f} -- upright, which NARK's own function convention already prescribes "
        "for a function whose letter also names a quantity, so \\mathcal{f} was the anomaly."),
}


def static_check():
    pat = re.compile(r"\\(" + "|".join(UPPERCASE_ONLY) + r")\{([a-z])\}")
    new, waived = [], []
    seen = set()   # a line may name the same token twice (macro + its own comment)
    for path in SCAN:
        if not os.path.exists(path):
            continue
        for n, line in enumerate(open(path, encoding="utf-8", errors="replace"), 1):
            for m in pat.finditer(line):
                token = "\\%s{%s}" % (m.group(1), m.group(2))
                rel = os.path.relpath(path, REPO)
                if (rel, n, token) in seen:
                    continue
                seen.add((rel, n, token))
                (waived if token in KNOWN else new).append((rel, n, token, line.strip()[:90]))
    return new, waived


def dynamic_check():
    """Render every expansion through a node KaTeX, if one is reachable, and report any styled
    request that comes back wearing the plain-italic class. Returns None when unavailable."""
    script = r"""
const katex=require('katex');
function font(t){ try{
  const h=katex.renderToString(t,{throwOnError:true,output:'html'});
  const s=[...h.matchAll(/<span class="mord([^"]*)"[^>]*>([^<>]+)<\/span>/g)].filter(x=>x[2].trim().length===1);
  return s.length ? (s[0][1].trim()||'(plain)') : '(none)';
} catch(e){ return 'ERROR'; } }
const out={};
for (const f of process.argv.slice(1)) for (const c of 'abcdefghijklmnopqrstuvwxyz')
  out[`\\${f}{${c}}`]=font(`\\${f}{${c}}`);
out['__baseline__']=font('g');
console.log(JSON.stringify(out));
"""
    try:
        r = subprocess.run(["node", "-e", script, *UPPERCASE_ONLY, *BOTH_CASES],
                           capture_output=True, text=True, timeout=120,
                           cwd=os.environ.get("KATEX_NODE_DIR", HERE))
        if r.returncode != 0:
            return None
        import json
        d = json.loads(r.stdout)
    except Exception:
        return None
    base = d.pop("__baseline__", "(plain)")
    return sorted(k for k, v in d.items() if v == base)


def main():
    new, waived = static_check()
    print(f"check_katex: rule = uppercase-only fonts {UPPERCASE_ONLY} may not take a lowercase "
          f"argument; both-cases fonts are {BOTH_CASES}")
    for rel, n, tok, line in waived:
        print(f"  waived  {rel}:{n}  {tok}\n            {KNOWN[tok]}")
    dyn = dynamic_check()
    if dyn is None:
        print("  (dynamic KaTeX probe skipped -- no reachable node katex; static check still ran)")
    else:
        unexpected = [t for t in dyn
                      if not any(t.startswith("\\" + f + "{") for f in UPPERCASE_ONLY)]
        print(f"  dynamic probe: {len(dyn)} styled forms fall back to plain italic in this KaTeX")
        if unexpected:
            print("  NEW GAP -- a font outside the known uppercase-only set now degrades:")
            for t in unexpected:
                print(f"    {t}")
            new.append(("(dynamic)", 0, ",".join(unexpected), "KaTeX font coverage changed"))
    if new:
        print("\ncheck_katex: FAIL -- these render as ordinary math italic, silently:")
        for rel, n, tok, line in new:
            print(f"  {rel}:{n}  {tok}   {line}")
        print("\nUse a both-cases font, or assign the symbol an uppercase letter, or add an explicit "
              "waiver to KNOWN with the reasoning.")
        return 1
    print("check_katex: clean.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
