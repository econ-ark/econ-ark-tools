# Changelog — econark notation registry

Versioning: SemVer on `notation.yml`'s `meta.version`. MAJOR = change to an
existing rendering or meaning; MINOR = additions; PATCH = gloss/typo fixes.

## v0.1.0 — 2026-07-14

Initial registry. Seeded from the 2026-07-13/14 notation & terminology rulings
of the powerlaw-decay / BufferStockTheory / MethodOfModeration thread (owner
feedback, verbatim provenance in each `ruling:` field).

- **Registry created** at `econ-ark-tools/@resources/notation/`: schema +
  `notation.yml` (25 symbols) + `terminology.yml` (3 banned, 1 defined, 3
  conventions) + four generators + `tests/check_sync.py` + governance docs.
- **Exponent notation (owner ruling, 2026-07-14):** the two decay exponents are
  written with arrows — `\qHi` = `q{\uparrow}` (high-wealth) and `\qLo` =
  `q{\downarrow}` (constraint-end). This **supersedes** the earlier `q*`
  (`\qstar`) / `q°` (`\qcirc`) notation; both are recorded as aliases. Semantic
  keys renamed to name the object: `high-wealth-exponent`,
  `constraint-end-exponent`, `compensation-exponent` (was `q-star`/`q-circ`/
  `q-tilde`). PROVEN `q↓ = ρ` (2026-07-13 constraint-end theorem).
- **`*Lvl` drift fix (owner ruling 2):** the single-letter `\aLvl … \zLvl`,
  `\ALvl … \ZLvl` family in `@resources/markdown/econark-shortcuts.md` fixed to
  `\boldsymbol{\mathit{x}}` (matching the `.sty`) with the stray trailing brace
  removed (51 macros; `\lLvl` was absent from the mirror). See
  `DRIFT-AUDIT-2026-07.md`.
- **Declared MIGRATION-PENDING dialects** (single-dialect ruling 4; all
  owner-gated): HARK `hNrm` = h − 1 (semantic); BST-paper γ/𝒢 vs registry ρ/Γ;
  powerlaw θ vs registry ξ for the atom-inclusive transitory shock.
- **Recorded aliases** mapping the powerlaw pages' macro names to the registry:
  `\Thorn`/`\ThornR`/`\ThornG`/`\kap`/`\Rcal`/`\qstar` → `\APFac`/`\RPFac`/
  `\GPFacRaw`/`\MPCmin`/`\RNrmByG`/`\qHi`.

Gates at seed time: G0-1 (check_sync + idempotent) PASS; G0-2 (LaTeX no-clash)
structurally PASS (all `\providecommand`; compile fixture committed — no TeX
engine in the build environment); G0-3 (`.md` `*Lvl` clean) PASS; G0-4
(KaTeX/MyST `--strict` render of every macro) PASS; G0-5 (lint catches planted
bans, passes clean, honors waivers) PASS.
