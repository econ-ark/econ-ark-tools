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
- `\trvTime` (n(w̄), the log-clock travel time) frees T for the terminal date.
  Ruled τ on 2026-07-16; changed to n on 2026-10-21 (below).
- `\etaL`/`\etaR` (η_L, η_R) replace the Lemma-5.1 remainders r_L/r_R.
- `\KimPrem` (J) names the Kimball precautionary premium.
- Time-pair convention: bare symbol = current period; `*Nxt` macros render
  `_{t+1}` (`\cNrmNxt`, `\mNrmNxt`, `\aNrmNxt`, `\wbarNxt`, `\psavNxt`,
  `\tranShkNxt`, `\permShkNxt`, via `\prdNxt`); flip the corpus back to
  primes by renewing only the `*Nxt` macros.

- **Merged with v0.6.0 on 2026-10-21.** Version order is not ruling order: these rulings
  date from July, the v0.3.0–v0.6.0 rulings from August, and v1.0.0 is numbered after them
  because it merges after them. The q_∞/q_0 subscripts in the KPP / q-subscripts / kapital
  amendment had already reached master as v0.2.0 (#37), so the `\qHi`/`\qLo` rows keep
  v0.2.0's wording.
- **`period-now` row added (2026-10-21): `\prdt` = t.** `\Now` expands to `_{\prdt}`, but
  `\prdt` was defined only in `econark-shortcuts.sty`, so `\Now` and every `*Now` macro were
  undefined with `econark-notation.sty` loaded alone and on every MyST/KaTeX page using
  `notation-math.yml` (KaTeX 0.16.11: 8 of 54 macros failed; all 65 render now).
- **`\trvTime` = n, not τ (owner ruling, 2026-10-21).** τ is econark-shortcuts' `\TaxRte` /
  `\tax` and HAFiscal's tax rate; the July case for reusing it (disjoint corpora) ended when
  HAFiscal took its notation from this registry. n is free in both specs and stays italic,
  since it names only a function. BufferStockTheory also writes n for the periods before T
  (`\cFunc_{T-n}`), an overlap accepted with the ruling.
- **Total wealth is o, not w̄ (owner ruling, 2026-10-21):** "I've reconsidered and think total
  wealth (human + nonhuman) should be just the roman letter o, not \omicron." That reverses his
  omicron ruling of minutes earlier. `\wbar` keeps its name and now expands to `o`;
  `\wbarNow`/`\wbarNxt` follow. Every gloss and formula that wrote w̄ now writes o.
- **`\tranShkAll` and `\tranShkInd` are one shock (owner ruling, 2026-10-21):** "identical,
  not distinct". econark-shortcuts.sty now defines `\tranShkAll` as `\tranShkInd` (it was
  bold ξ), and marks ξ for population growth (`\PopnGroRte`, `\popGroRte`) DEPRECATED, with
  no replacement ruled yet.
- **The growth factor is 𝒢 and its rate g ≈ ln 𝒢 (owner rulings, 2026-10-21).** "The registry
  defines g = ln Γ": "It shouldn't do that; at best it should be either g \approx ln G or \gamma
  \approx ln \Gamma." He chose the first: the rate keeps g, as in econark-shortcuts and the BST
  paper, and the factor becomes their calligraphic 𝒢, not Γ (Roman G is shortcuts' productivity
  growth factor). γ was passed over because both published papers write it for risk aversion.
  The relation is approximate because the rate is arithmetic: 𝒢 = 1 + g, as R = 1 + r.
  `\GPFacRaw` is now Þ_𝒢, and every formula that wrote Γ writes 𝒢; Γ stays as the powerlaw
  pages' declared dialect.
- **`\tranShkNxt` is ξ_{t+1}, not θ_{t+1}.** #38 had carried the powerlaw pages' θ into the base
  form; θ is econark-shortcuts' employed-state shock, and the shock is ξ.

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
- **`\wbarFunc` + w̄-is-a-function caution (owner, 2026-07-17):** bars tempt a
  constant/mean reading; w̄(m) := b + h = m − 1 + h is a function of the state
  (the bar is MoM's optimist mark). New row `wealth-total-pf-function`
  (`\wbarFunc` = `\bar{\mathrm{w}}`, guise convention); `wealth-total-pf` gloss
  and define now function-explicit.
- **The gap g revived + prohibitions (owner, 2026-07-17 PM):** the Q4 s/g→x
  merger PARTIALLY REVERTED — x takes the state m only (`\psavFunc(m)`); the
  w̄-coordinate function is again the gap `g(w̄) := κ̲w̄ − c(m(w̄))`, a bare
  italic letter (new `gap` row), with g(w̄(m)) = x(m). `\wbarFunc` retired
  same-PR (w̄(m) stays italic-explicit). `guise-convention` key renamed
  `function-vs-quantity-convention` and de-jargoned. NEW BANS in
  terminology.yml: `\mathfrak{b}` (write RβΓ^{−ρ} / Þ_Γ^ρ) and the
  "dual-guise" coinage.
- **KPP restored + q-subscripts + kapital (owner, 2026-07-17 evening):** J's
  textual name is again the Kimball Precautionary Premium (KPP) — a scoped
  exception to the premium ban ("the adjustment" survives only for the signed
  buffer-stock-motion concept). Display exponents q↑/q↓ → `q_∞`/`q_0`
  (subscript ruling; `\qHi`/`\qLo` expansions updated; HARK `q_star` API
  unchanged; frozen figures may carry arrows — bridge declared). New
  `kapital-now`/`kapital-next` rows (BST's k_{t+1} = a_t). MoM
  "optimist/pessimist" language retired from the powerlaw corpus.

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
