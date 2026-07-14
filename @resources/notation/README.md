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

**Dependency:** the generators require Python 3 + `PyYAML`.

## How to consume

- **Vendoring:** these files ride the existing `@resources/` mechanism. Running a
  consuming repo's `@resources-update-from-remote_private.sh` rsyncs
  `econ-ark-tools/@resources/` onto the repo's `@resources/`, so
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
already defined. So when a document loads BOTH files, the already-loaded
definition wins for every shared name. Consequences:

- **Load `econark-notation.sty` alone (or first)** to get the registry's *base
  dialect*.
- Of the 14 macro names shared with `econark-shortcuts.sty`, 7 render identically
  (`\CRRA \MPCmin \MPCmax \bNrm \hNrm \pZero \permShk` — pure no-op) and **6
  render differently**, where shortcuts wins when both load:
  `\PermGroFac` (Γ vs 𝒢), `\RNrmByG` (`\mathcal{R}` vs `\mathscr{R}`),
  `\tranShkAll` (ξ vs bold ξ), `\APFac` / `\RPFac` / `\GPFacRaw` (the registry's
  Þ-symbol forms vs shortcuts' `\pmb{\Thorn}` / ratio forms). These are the
  declared **MIGRATION-PENDING** dialects (see the `dialects:` entries in
  `notation.yml`); reconciling them is owner-gated (single-dialect ruling), not
  something loading order should silently decide. The other 10 registry macros
  are unique and always contributed.

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
    python:  '<HARKishName>'                          # optional; PROPOSED if not in use
    aliases: ["<sanctioned alternates + where>"]      # optional
    dialects: {<key>: {expansion, home, note, status}}   # optional; DECLARED divergences
    conflicts_checked: "<what was verified against what>"  # optional
    ruling:  {date, source, rationale}
```

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
