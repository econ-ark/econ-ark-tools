# Notation / terminology ruling — PR template

Copy this into the PR description. A ruling is a PR against `notation.yml` and/or
`terminology.yml`; the owner merges. Fill every section (write "n/a" where a
section does not apply).

## 1. Motivation

What is ambiguous, drifting, or contested today? Cite where it bites (file:line,
a build warning, two docs disagreeing).

## 2. Decision

The exact new/changed entry, in registry terms:

- **semantic key(s):** `<kebab-case-object-name>`
- **symbol / macro / expansion:** `\Macro` → `<latex>` (unicode `<glyph>`)
- for terminology: the banned/preferred/defined term and its replacement/definition
- **SemVer bump:** MAJOR (changes an existing rendering or meaning) / MINOR
  (addition) / PATCH (gloss or typo)

## 3. Conflict sweep (evidence)

Prove the symbol/term is free (or reclaim it deliberately):

- searched the consuming corpora for the letter/term and for the object under
  other names — result:
- collides with an existing macro? (`econark-shortcuts.sty`, other registry
  entries) — if so, which, and how is precedence handled?
- KaTeX-renderable? (the MyST generator output must build `--strict` clean)

## 4. Dialects

Does any of the four projects (HARK, HAFiscal-Latest, BufferStockTheory-Latest,
MethodOfModeration) — or a frozen/historical corpus outside them — write this
differently? List each as a `dialects:` entry. Per the single-dialect ruling, an
intra-four dialect must be tagged `status: MIGRATION-PENDING` with the migration
owner-gated; only corpora OUTSIDE the four may be a steady-state dialect.

## 5. Migration notes

What has to change downstream, and is it owner-gated? (e.g. a rename across a
codebase, a re-derivation, a waiver for frozen artifacts). Nothing here executes
until the owner rules.

## 6. Checklist

- [ ] edited `notation.yml` / `terminology.yml` only (not the generated files)
- [ ] bumped `meta.version` and added a `CHANGELOG.md` entry
- [ ] ran the generators and committed the regenerated artifacts in this PR
- [ ] `python tests/check_sync.py` exits 0
- [ ] MyST `--strict` render still clean; LaTeX no-clash fixture still valid
- [ ] `ruling:` provenance (date, source, rationale) recorded verbatim
