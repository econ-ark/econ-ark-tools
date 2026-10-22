# econark notation registry (`@resources/notation/`)

**Single source of truth** for the mathematical notation and terminology shared
by the econ-ark papers and code (NARK, HARK, HAFiscal-Latest, BufferStockTheory-Latest,
SolvingMicroDSOPs, TractableBufferStock, MethodOfModeration). Together with the hand-edited
`../texlive/texmf-local/tex/latex/econark-shortcuts.sty` (owner ruling 2026-10-22: it stays
hand-edited, and its copies are generated, with drift tests), this is where rulings live;
the generators fan them out to LaTeX, MyST/KaTeX, a human-readable table, the Markdown
mirror and a prose lint. This ends the two failure modes that motivated it: rulings
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
| `gen/gen_shortcuts.py` → `econark-math.yml`, `../markdown/econark-shortcuts.md` | the KaTeX-safe map of **every** shared macro (shortcuts + registry) for MyST, and the Markdown mirror BufferStockTheory-make reads |
| `tests/check_sync.py` | regenerates every artifact in a tempdir, byte-compares, nonzero on drift |
| `tests/check_shortcuts_agree.py` | every name in both `econark-shortcuts.sty` and the registry prints the same (pdflatex box sizes) |
| `tests/latex_noclash_test.tex` | G0-2 compile fixture (loads shortcuts + notation, no clash) |
| `CHANGELOG.md`, `RULING_TEMPLATE.md`, `DRIFT-AUDIT-2026-07.md` | history / PR template / initial drift report |

**Generated files are committed AND checked** — never hand-edit `econark-notation.sty`,
`notation-math.yml`, `econark-math.yml`, `NOTATION.md`, `notation-lint.sh` or
`../markdown/econark-shortcuts.md`. Edit the YAML (or `econark-shortcuts.sty`), run the
generators, run `python tests/check_sync.py` and `python tests/check_shortcuts_agree.py`, commit.

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
variable (fixed in v0.5.0: `\fDist` = `\mathrm{f}`). The PDF path is no refuge: Computer Modern's
`\mathcal{g}` prints a right brace and mathrsfs's `\mathscr{g}` prints nothing ("There is no g in font
rsfs10"), measured on jhu-dell 2026-10-22.

Enforced by `tests/check_katex.py` (static scan, Python only; plus a deeper render probe when a node
KaTeX is reachable, which is what would catch a NEW gap if KaTeX's coverage changes). Its one waiver,
`\PtyGroRte` = `\mathscr{g}`, ended in v5.0.0: productivity growth is sans-serif, 𝖦 and 𝗀.

**Dependency:** the generators require Python 3 + `PyYAML`.

## How to consume

- **Vendoring:** these files ride the existing `@resources/` mechanism. Running a
  consuming repo's `@resources-update-from-remote_private.sh` (a wrapper that calls
  the vendored `@resources/bash/@resources-update-from-remote.sh`; a wrapper pointing
  at an absolute path to the old upstream `_private` script, removed in 9b55a274, no
  longer works) rsyncs `econ-ark-tools/@resources/` onto the repo's `@resources/`, so
  `@resources/notation/` appears there verbatim. (That pull is interactive and
  belongs to each repo's own session — do not run it from here.)
- **LaTeX:** `\usepackage{econark-shortcuts}` and, for the registry's own rows,
  `\usepackage{econark-notation}`. TeX finds both through `@resources/texlive/texmf-local/tex/latex/`
  (a symlink there points at this directory's `econark-notation.sty`). The registry is all
  `\providecommand`, so it loads alongside the shortcuts without clash — see precedence below.
  The shortcuts now declare what they need (amsmath, amssymb, cancel, graphicx, and eucal's
  `\mathscr` if nothing has defined it), and their thorns work in any font encoding.
- **MyST:** add the generated map to your `myst.yml` **top-level** `extends:` list
  (verified with mystmd 1.10.1 — `extends:` is a sibling of `version:`/`project:`,
  NOT under `project:`; a relative path resolves against the `myst.yml`'s dir):
  ```yaml
  extends:
    - <relative-or-abs>/econark-math.yml
  ```
  `econark-math.yml` carries every shared macro (the shortcuts and the registry), KaTeX-tested;
  `notation-math.yml` carries the registry's rows alone.
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
- Every macro name in both files prints the same thing: 61 of them at v5.0.0, checked by
  `tests/check_shortcuts_agree.py`, which typesets each name with either file alone. So no shared
  name is a dialect: a document that loads both files gets the registry's notation, and NARK needs
  no overrides. The `dialects:` entries left in `notation.yml` record individual documents'
  divergences: HARK's code names (`hNrm`, `BoroCnstNat`, `PermShk`), the BST paper's γ (to move to `\CRRA`, ϱ),
  and the powerlaw pages'.

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

**Registry scope (owner ruling 2026-10-22, 08:36:22 and 08:39:09).** Definitions unique to the powerlaw
pages are not shared notation, so they left this registry for the pages' own definitions in v5.0.0:
q̃, η_L, η_R, the buffer adjustment J (and the Kimball premium), the return-region edge ō, the travel
time n, and the gap g. q_∞ and q_0 stay (HAFiscal and MethodOfModeration use them). Precautionary
saving c̄(m) − c(m) stays a shared object, but not as the powerlaw draft's x; its shared symbol is still
to be chosen, so its row defines no macro.

## Governance — proposing a ruling

1. Open a PR editing `notation.yml` / `terminology.yml`, using
   `RULING_TEMPLATE.md` (motivation / decision / conflict-sweep / dialects /
   migration notes).
2. Bump `meta.version` (SemVer: MAJOR = change an existing rendering or meaning;
   MINOR = additions; PATCH = gloss/typo). Add a `CHANGELOG.md` entry.
3. Regenerate (`for g in gen/gen_*.py; do python $g; done`), run `python tests/check_sync.py`,
   `python tests/check_shortcuts_agree.py` and `python tests/check_katex.py`, and commit the
   regenerated artifacts in the same PR. Owner merges.
4. Consumers pick it up on their next `@resources` pull and bump deliberately.
5. Frozen / append-only artifacts (grafted proof lineage, refuter-reviewed
   proofs, committed `*_out.txt` run logs, THEOREM-REF-pinned files) never
   retro-conform; `--waive` them in the lint. Exception (owner ruling 2026-10-22 08:00:19):
   frozen pages that a site SERVES to readers (the powerlaw pages' alt_proof_compactified) are
   conformed like live pages.

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
