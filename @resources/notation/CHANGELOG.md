# Changelog — econark notation registry

Versioning: SemVer on `notation.yml`'s `meta.version`. MAJOR = change to an
existing rendering or meaning; MINOR = additions; PATCH = gloss/typo fixes.

## v0.6.0 — 2026-08-30

- **The matching block's five parameters (owner rulings, 2026-08-30):** four
  words and one letter. `\matchEff` = eff (was χ), `\vacFillPrb` = fill (was φ),
  `\jobFindPrb` = find (was η), `\tightness` = tgt (was Θ), and `\matchElas` =
  `z` (was α). The elasticity keeps a single letter because it is an exponent,
  where a word crowds (e^{els}, tgt^{1−els}); `\mathrm{els}`, `\varkappa`,
  `\upsilon` and `\iota` were each rejected before z, which is unclaimed in both
  registry lineages.
- **`ad-elasticity` row added (2026-10-21)** for `\ADElas` = Ω, ruled in
  v0.5.0 but recorded then only in `econark-shortcuts.sty`, so the registry
  showed Ω as free.
- **Corrections to the SAM rows (2026-10-21):** the matching formulas write the
  exponent as z, not the rejected els; the separation rate's law of motion adds
  filled vacancies, `fill_t · v_t` (it read `jobFind · v_t`); the tightness key
  is `labor-market-tightness` (American spelling; no released version carried
  the old key).

## v0.5.0 — 2026-08-30

- **Words for the search-and-matching block (owner rulings, 2026-08-30).**
  Convention (1): the SAM model's own quantities are upright words. Convention
  (2), a fallback no current parameter uses: a SAM parameter with a genuine claim
  on a taken Greek letter takes a tilde. `\sepRte` = sep, `\vacCost` = cst (not κ,
  the MPC), `\ADElas` = Ω (a capital, because the AD elasticity governs an
  economy-wide externality).
- **`\fDist` = `\mathrm{f}`** in `econark-shortcuts.sty`: the density is a
  function, and `\mathcal{f}` rendered as a plain f in KaTeX.
- **KaTeX font gate:** `tests/check_katex.py` rejects a lowercase argument to
  KaTeX's uppercase-only fonts (`\mathcal`, `\mathscr`, `\mathbb`), which KaTeX
  silently renders as ordinary italic. `\PtyGroRte` = `\mathscr{g}` is waived
  pending a ruling on its pair.

## v0.4.0 — 2026-08-30

- **`\splurge` = ℷ (gimel)** (owner ruling, 2026-08-30): HAFiscal's paper wrote
  the splurge as ς, which is NARK's `\riskyshare`; ς stays with the risky share.

## v0.3.0 — 2026-08-30

- **`weight` row: `\weight` = ω** (owner ruling, 2026-08-30). Not a new
  assignment: `econark-shortcuts.sty` already defined it, and the registry's
  silence led a downstream consumer to believe ω was free.

## v0.2.0 — 2026-07-16

- **Exponent notation (owner ruling, 2026-07-16):** the two decay exponents move
  from arrows to subscript-limit notation — `\qHi` = `q_{\infty}` (high-wealth,
  m→∞) and `\qLo` = `q_{0}` (constraint end, mᵉ→0). This **supersedes** the
  2026-07-14 arrow forms `q↑`/`q↓` (kept as aliases). Rationale: name each
  exponent by the limit it governs and avoid the vector-notation reading of
  arrow accents. **Macro names `\qHi`/`\qLo` are unchanged**, so downstream prose
  that uses the macros needs no edits — only each consumer's vendored
  `@resources` (regenerated `notation-math.yml`, `econark-notation.sty`, …) is
  refreshed via `@resources-update-from-remote.sh`.

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
