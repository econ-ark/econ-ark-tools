# Changelog — econark notation registry

Versioning: SemVer on `notation.yml`'s `meta.version`. MAJOR = change to an
existing rendering or meaning; MINOR = additions; PATCH = gloss/typo fixes.
## v1.0.0 — 2026-07-16

Owner rulings from the powerlaw editorial pass (reactions round, 2026-07-16):

- **MAJOR — `precautionary-saving` re-ruled:** `\pcsNrm`/'s' → **`\psav`/'x'**
  ("the eXtra saving induced by precaution"); replaces BOTH former symbols
  s(m) and g(w̄) — one object, one symbol, the coordinate shows in the argument.
- `\GPRte` (þ_g = ln Þ_Γ, NEGATIVE under GIC) adopted corpus-wide; the missing
  lowercase `\thorn` glyph is provisioned (`\text{þ}`, KaTeX/LaTeX-safe); the
  powerlaw corpus' positive alias Λ := ln(1/Þ_Γ) is RETIRED (Λ = −þ_g).
- `\trvTime` (τ(w̄), the log-clock travel time) frees T for the terminal date.
- `\etaL`/`\etaR` (η_L, η_R) replace the Lemma-5.1 remainders r_L/r_R.
- `\KimPrem` (J) names the Kimball precautionary premium.
- Time-pair convention: bare symbol = current period; `*Nxt` macros render
  `_{t+1}` (`\cNrmNxt`, `\mNrmNxt`, `\aNrmNxt`, `\wbarNxt`, `\psavNxt`,
  `\tranShkNxt`, `\permShkNxt`, via `\prdNxt`); flip the corpus back to
  primes by renewing only the `*Nxt` macros.

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

**Amended in-PR 2026-07-17 (ruling 9 v2 — guise + the \Now/\Nxt dating layer):**
- **`\Now`/`\Nxt` suffix macros** (owner-proposed): the dialect flip point is the
  two suffix definitions; `\*Now`/`\*Nxt` families defined THROUGH them (the old
  per-macro `_{\prdNxt}` hardcoding removed — flip was seven edits, now two).
  Verified trap warnings recorded: `\Now` must be `'{}'` in the prime dialect
  (never the empty string — mystmd drops empty macros) and `\Nxt` the literal
  apostrophe (never `'^{\prime}'` — double superscript on `\cNrmNxt^{-\rho}`).
- **Guise convention** (ruling 9 v2): values italic (bare letters = `*Nrm`),
  functions upright (`*Func`, matching econark-shortcuts `\cFunc = \mathrm{c}`);
  Greek carve-out; primes = differentiation only. New first-class rows:
  `consumption-function`, `utility-function`, `precautionary-saving-function`,
  `buffer-adjustment-function`, `guise-convention`, the `*-now` family, and the
  previously missing `bank-balances-next`.
- **buffer-adjustment ruling corrected**: the buffer stock is END-OF-PERIOD
  ASSETS `a` (a level, not a wealth-cushion deviation; target `â = m̂ − c(m̂)`);
  "financing" retired as x's narrative name (owner, 2026-07-17).
