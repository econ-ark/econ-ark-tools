# econark notation registry (`@resources/notation/`)

**Single source of truth** for the mathematical notation and terminology shared
by the econ-ark theory/implementation thread (HARK, HAFiscal-Latest,
BufferStockTheory-Latest, MethodOfModeration). One place rulings live; four
generators fan them out to LaTeX, MyST/KaTeX, a human-readable table, and a
prose lint. This ends the two failure modes that motivated it: rulings
propagated by hand to every repo, and shared macro files drifting apart
(see `DRIFT-AUDIT-2026-07.md`).

## Files

| File | Role |
|---|---|
| `notation.yml` | **the registry** — symbols (schema below). Edit this. |
| `terminology.yml` | banned / preferred / defined terms + prose conventions. Edit this. |
| `gen/gen_latex.py` → `econark-notation.sty` | `\providecommand` macros for LaTeX/PDF |
| `gen/gen_myst.py` → `notation-math.yml` | a MyST `project.math` map, consumed via `extends:` |
| `gen/gen_markdown.py` → `NOTATION.md` | the human/agent-readable table (read this before writing math/prose) |
| `gen/gen_lint.py` → `notation-lint.sh` | word-boundary grep gate for banned terms |
| `tests/check_sync.py` | regenerates all four in a tempdir, byte-compares, nonzero on drift |
| `tests/latex_noclash_test.tex` | G0-2 compile fixture (loads shortcuts + notation, no clash) |
| `CHANGELOG.md`, `RULING_TEMPLATE.md`, `DRIFT-AUDIT-2026-07.md` | history / PR template / initial drift report |

**Generated files are committed AND checked** — never hand-edit `.sty`,
`notation-math.yml`, `NOTATION.md`, `notation-lint.sh`. Edit the YAML, run the
generators, run `python tests/check_sync.py`, commit.

## Font availability (KaTeX)

**A symbol that needs both cases must use a font KaTeX has in both cases.**

| available in both cases | **uppercase only** |
|---|---|
| `\mathrm` `\mathit` `\mathbf` `\mathsf` `\mathtt` `\mathfrak` | `\mathcal` `\mathscr` `\mathbb` |

KaTeX ships its Caligraphic, Script and AMS-blackboard fonts in uppercase only. Asked for a lowercase
one it does not error and does not draw a box — it renders **ordinary math italic**, indistinguishable
from an unstyled variable. Measured with KaTeX 0.18.4: `\mathscr{g}` emits the glyph class
`mathnormal`, byte-identical to plain `g`.

That is the worst shape of rendering bug for a registry, and it is *asymmetric* when it hits one half
of a pair: `\FDist` = `\mathcal{F}` rendered as a caligraphic F while `\fDist` = `\mathcal{f}`
rendered as a plain f, so the distribution looked special and its density looked like any other
variable (fixed in v0.5.0: `\fDist` = `\mathrm{f}`). MathJax draws real outlines for all of these, so
the PDF and MathJax paths are unaffected — but the MyST output this directory generates is a KaTeX
path.

Enforced by `tests/check_katex.py` (static scan, Python only; plus a deeper render probe when a node
KaTeX is reachable, which is what would catch a NEW gap if KaTeX's coverage changes). One
pre-existing violation, `\PtyGroRte` = `\mathscr{g}`, is waived in that file with the reasoning and
a candidate fix, because correcting it is a notational ruling rather than a bug fix.

**Dependency:** the generators require Python 3 + `PyYAML`.

## How to consume

- **Vendoring:** these files ride the existing `@resources/` mechanism. Running a
  consuming repo's `@resources-update-from-remote_private.sh` (a wrapper that calls
  the vendored `@resources/bash/@resources-update-from-remote.sh`; a wrapper pointing
  at an absolute path to the old upstream `_private` script, removed in 9b55a274, no
  longer works) rsyncs `econ-ark-tools/@resources/` onto the repo's `@resources/`, so
  `@resources/notation/` appears there verbatim. (That pull is interactive and
  belongs to each repo's own session — do not run it from here.)
- **LaTeX:** `\usepackage{econark-notation}` (point `TEXINPUTS` at this dir). It
  is all `\providecommand`, so it loads alongside `econark-shortcuts.sty` without
  clash — see precedence below.
- **MyST:** add the generated map to your `myst.yml` **top-level** `extends:` list
  (verified with mystmd 1.10.1 — `extends:` is a sibling of `version:`/`project:`,
  NOT under `project:`; a relative path resolves against the `myst.yml`'s dir):
  ```yaml
  extends:
    - <relative-or-abs>/notation-math.yml
  ```
- **Humans / agents:** read `NOTATION.md`. A consuming repo's `AGENTS.md` should
  carry: *"Notation and terminology rulings live in
  `@resources/notation/NOTATION.md` (version pinned by the @resources snapshot).
  Read it before writing math or prose; propose changes as registry PRs, not
  per-repo edits."*
- **Lint:** `bash @resources/notation/notation-lint.sh --scope <path> [--waive <file>]`.

## Precedence vs `econark-shortcuts.sty` (important)

`econark-notation.sty` uses `\providecommand`, which **defers** to any macro
already defined. `econark-shortcuts.sty` defines through `\ARKcommand`, which is
`\providecommand` followed by `\renewcommand`, so it **overwrites**. When a
document loads BOTH files, shortcuts' definition therefore wins for every shared
name, in EITHER order (pdflatex, 2026-10-21, while the two still differed: `\RNrmByG`
took shortcuts' then-`\mathscr{R}` with the registry loaded first or second). Since
v4.0.0 every shared name prints the same symbol in both, so the order matters only
if they drift apart again.
Consequences:

- **Load `econark-notation.sty` alone** to get the registry's *base dialect*.
  Loading it first does not help.
- All 38 macro names shared with `econark-shortcuts.sty` print the same symbol in
  both (v4.0.0): `\CRRA \MPCmin \MPCmax \bNrm \hNrm \pZero \permShk \mTrgNrm`; the ten
  rows added in v0.3.0–v0.6.0 (`\weight \splurge \vacCost \sepRte \ADElas \matchEff
  \matchElas \vacFillPrb \jobFindPrb \tightness`); six from v1.0.0 (`\cFunc \uFunc
  \PermGroRte \GPRte \prdt \prdNxt`); `\tranShkAll` and `\PermGroFac` (2026-10-21);
  seven from v2.1.0 (`\tranShkEmp \IncUnemp \tranShkMin \tranShkEmpMin \permShkIndMin
  \aMin \LivPrb`); `\thorn`; `\APFac`, a single `\textbf` thorn in both since v2.1.1;
  and, since v4.0.0, `\RPFac \GPFacRaw \RNrmByG`: the bold thorn with subscripts (Þ_R
  with the sans-serif R of `\Rfree`, Þ_𝒢) and calligraphic ℛ. So no shared name is a
  dialect any more: a document that loads both files gets the registry's notation, and
  NARK needs no overrides. The `dialects:` entries left in `notation.yml` are individual
  documents' divergences (HARK's `hNrm`, the BST paper's γ for CRRA, the powerlaw
  pages'). The other 38 registry macros are unique and always contributed.

## The powerlaw draft takes its notation from `@resources`

The powerlaw pages (`theory/powerlaw-decay/` in BufferStockTheory-Latest) use the
same `@resources/` approach as the other papers. Owner, 2026-10-21: *"the powerlaw
work needs to use the same @resources/econ-ark-tools approach as the other papers;
that way it does not have many things to define, except mathematical objects absent
from the other wor[k]"*. So the shared notation comes from `@resources/` (for MyST,
`notation-math.yml` through `extends:`), and the pages define for themselves only
the objects that no other paper has. Today their `myst.yml` defines about 60 macros
itself. Where those render differently from the shared ones, the `powerlaw-pages`
entries under `dialects:` record it, marked **NOT SANCTIONED**: they go when the
pages take the shared macros, and they are not alternatives.

## Governance — proposing a ruling

1. Open a PR editing `notation.yml` / `terminology.yml`, using
   `RULING_TEMPLATE.md` (motivation / decision / conflict-sweep / dialects /
   migration notes).
2. Bump `meta.version` (SemVer: MAJOR = change an existing rendering or meaning;
   MINOR = additions; PATCH = gloss/typo). Add a `CHANGELOG.md` entry.
3. Regenerate (`python gen/gen_*.py`), run `python tests/check_sync.py`, commit
   the regenerated artifacts in the same PR. Owner merges.
4. Consumers pick it up on their next `@resources` pull and bump deliberately.
5. Frozen / append-only artifacts (grafted proof lineage, refuter-reviewed
   proofs, committed `*_out.txt` run logs, THEOREM-REF-pinned files) never
   retro-conform; `--waive` them in the lint.

## `notation.yml` schema

```yaml
meta: {version: X.Y.Z, updated: YYYY-MM-DD}
symbols:
  <semantic-key>:                    # kebab-case; names the OBJECT, never the letter
    gloss:   "<one line>"
    define:  "<defining equation, unicode>"          # optional
    latex:   {macro: '\Xyz', expansion: '<latex>'}   # optional (gloss-only objects omit it)
    unicode: '<glyph(s)>'
    plain:   '<name for terminals and code>'           # optional; see below
    python:  '<HARKishName>'                          # optional; PROPOSED if not in use
    aliases: ["<sanctioned alternates + where>"]      # optional
    dialects: {<key>: {expansion, home, note, status}}   # optional; DECLARED divergences
    conflicts_checked: "<what was verified against what>"  # optional
    ruling:  {date, source, rationale}
```

`plain` is the name to use in terminals, plain-text prose and code where `unicode` needs a
combining underline (U+0332), which many terminals draw under the next cell: `κ_min` for κ̲,
`a_Nat` for a̲_Nat. It is never pasted into LaTeX as it stands. Marks above a letter (m̂, κ̄, q̃)
draw correctly and get no `plain`.

Generators emit symbols **sorted by semantic key**, with no timestamps, so
re-running is byte-identical (that is what `check_sync` enforces). Dialects are
documentation only — the LaTeX/MyST generators emit the base expansion.

## `notation-lint.sh` default config

- **Default scope** is `.`; pass `--scope <path>` (repeatable) to narrow it.
- The script always excludes `.git` and the registry's own files (they name the
  banned terms by definition).
- **Waiver file** (`--waive <file>`): one directory-name / file-name glob per
  line (`grep --exclude` / `--exclude-dir` semantics; `#` comments allowed).
  Starter list for a theory/proof repo:
  ```
  # frozen / append-only — never retro-conform (see governance)
  inputs
  *_out.txt
  _build
  review
  ```
  Add THEOREM-REF-pinned files and refuter-reviewed proofs as needed. The lint is
  a *heuristic* (grep cannot tell the software sense of "production" from the
  economic one) — treat hits as review prompts, waive the intentional ones.
