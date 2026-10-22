# Changelog — econark notation registry

Versioning: SemVer on `notation.yml`'s `meta.version`. MAJOR = change to an
existing rendering or meaning; MINOR = additions; PATCH = gloss/typo fixes.

## v6.0.0 — 2026-10-22

**Risk aversion is ϱ (10:58:30).** The owner, in the econ-ark-tools session: "I think we ought to designate
\CRRA as \varrho not as regular \rho so we can avoid conflicts". MAJOR: `\CRRA` changes rendering, from ρ to
ϱ, in both `econark-shortcuts.sty` and the registry. Every formula built on it follows (Þ = (Rβ)^{1/ϱ},
κ̄ = 1 − ℘^{1/ϱ}Þ_R, q_0 = ϱ). The registry gives plain ρ no meaning, so each paper may use it for its own
persistence or correlation parameters, declared locally. ϱ had no meaning in the shared files. The retired
econtexShortcuts' `\corr` = ϱ (correlation) is used by no paper's source.

Migration: a paper that types `\rho` (or ρ) for risk aversion, instead of `\CRRA`, now prints ρ beside the
shared ϱ until it switches. Today's rulings that move the BST paper and HAFiscal from γ "to ρ" mean to `\CRRA`,
which now prints ϱ. Those rulings are otherwise unchanged: HAFiscal's replacement rates still become ξ_{U,b}
and ξ_{U,nb}, and its Taylor-rule ρ_r still becomes φ_i. Ruling quotations elsewhere in the registry keep the
owner's words as typed.

**The survival-inclusive names follow HARK's (11:00:07, 11:17:23).** The owner: "GPFacLiv < 1 is the correct
version of the GIC-Liv", then "implement your recs". In v5.0.0 `\GPFacLiv` named the ring factor Þ̊_𝒢, but
HARK's GPFacLiv is ℒÞ̊_𝒢. The same name meant two numbers a factor ℒ apart, so a paper writing `\GPFacLiv < 1`
for the GIC-Liv would have printed the growth impatience condition instead. HARK's own patience factors
already include survival: its APFac is (Rfree·DiscFac·LivPrb)^(1/CRRA). So:
- The ring variants take HARK's suffix Eff, as in its DiscFacEff and the registry's `\RfreeEff`:
  - `\DiscFacEff` = β̊ (HARK's DiscFacEff). `\DiscFacLiv` stays in econark-shortcuts.sty as an alias, since
    the BST paper writes it.
  - `\APFacEff` = Þ̊ (HARK's APFac).
  - `\RPFacEff` = Þ̊_R (HARK's RPFac, and PatFac in two of its solvers).
  - `\GPFacEff` = Þ̊_𝒢 (HARK's GPFacRaw).
- `\GPFacLiv` = ℒÞ̊_𝒢, HARK's GPFacLiv, in a new row, `patience-growth-mortality-adj`. The GIC-Liv is
  `\GPFacLiv < 1`.
- `\APFacLiv` and `\RPFacLiv`, new in v5.0.0 and used by no paper, are retired.
- The survival-free rows (`\APFac`, `\RPFac`, `\GPFacRaw`, `\GPFacMod`) record in a `hark-python` dialect
  that HARK's same-named variable is the Eff form. HARK's GPFacMod is `\GPFacEff\EPermShkInv`.
- Row keys are unchanged.

## v5.0.0 — 2026-10-22

The owner's rulings of 2026-10-22, given in the econ-ark-tools session between 07:17 and 08:39 EDT
(times are of his answers), after a survey of every paper against v4.0.0. MAJOR: renderings change and
rows are removed. Both `econark-shortcuts.sty` and the registry change, and every name in both prints the
same (61 names, `tests/check_shortcuts_agree.py`).

**The single source (07:17:41: "Step 1 only").** `econark-shortcuts.sty` stays hand-edited; its copies are
generated. New `gen/gen_shortcuts.py` writes `econark-math.yml` (a KaTeX-safe MyST map of all 421 shared
macros) and `../markdown/econark-shortcuts.md` (the mirror BufferStockTheory-make reads, hand-edited and 91
macros behind until now). `check_sync` covers both; `check_shortcuts_agree.py` is new.

**Survival (07:22:54, 07:27:11).** "There should be two variants of \beta and \LivPrb, with and without an
accent. The variant without the accent should not incorporate the survival probability; the one with it
should." The accent is the ring, used nowhere before: `\DiscFacLiv` = β̊ = βℒ (was β̲); new `\APFacLiv` =
Þ̊, `\RPFacLiv` = Þ̊_R (HARK's PatFac), `\GPFacLiv` = Þ̊_𝒢. `\RfreeEff` (Blanchard, R/ℒ) is R̊ (08:13:40);
`\RBoro` keeps R̄.

**Probabilities (07:31:41).** ℘ (`\pZero`) is the probability of unemployment, HARK's UnempPrb, whatever ξ_U;
the row's key is now `unemployment-prob`. `\pWorst` maps to HARK's WorstIncPrb.

**Letters.**
- ζ stays with the leisure share (`\leiShare`); the Pareto (tail) exponent is ε, `\paretoExp` (07:35:28).
  `\unins` leaves the shared file for TractableBufferStock, which writes it λ (08:25:26, 08:26:39).
- Population growth: factor Ξ, rate ln Ξ (`\PopnGroRte`, `\popGroRte`); `\TranShkAll` retired (07:35:28).
- Productivity growth: sans-serif 𝖦 and 𝗀 (07:44:34). The script g printed nothing in PDF and KaTeX;
  `check_katex`'s only waiver goes.
- Θ is the aggregate of θ: `\TranShkAgg` canonical, `\TranShkEmp` its alias (08:06:54).
- α is the capital share; CARA is the word `\mathrm{cara}` (07:57:56, 08:18:06).
- ℓ is labor and φ the log equity premium; `\livPrb` and `\prstShk`/`\prstShkInd`, used by no paper,
  are retired (08:15:54). `\TaxAmt` is retired: T is only the terminal date (08:33:44).
- ψ̲ is ψ's minimum; `\InvEPermShkInv` is written out, (𝔼[ψ⁻¹])⁻¹ (08:15:54, 08:31:10).
- `\GPFacMod` takes BST's product form Þ_𝒢𝔼[ψ⁻¹] (08:00:19).
- ∇ for the spread of discount factors, `\DiscFacSprd` (08:33:44).

**Registry scope (08:36:22, 08:39:09).** Powerlaw-only definitions leave the registry for the powerlaw pages:
`\qtilde`, `\etaL`, `\etaR`, `\bufAdj`, `\bufAdjFunc`, `\wbarMax`, `\trvTime`, and the gap. Precautionary
saving stays a shared object without the powerlaw draft's x; its symbol is to be chosen, so the row has
no macro (and `\psavFunc`, `\psavNow`, `\psavNxt` go).

**Conventions (07:47:23; terminology.yml).** A time index joins an existing subscript, last (Þ_{R,t}); a paper
may give a claimed letter only to an object the shared files do not cover; the ring marks
survival-inclusive symbols; r and R name only returns (ruling of 2026-07-19, now recorded). Human wealth
includes this period's income (08:00:19); HARK's hNrm, BoroCnstNat and PermShk are declared code dialects.

**Rows added for shared objects** the registry had left to the shortcuts: `\Rfree`, `\DiscFac`, `\MPC`,
`\Ex`, `\EPermShkInv`, plus the rows above. `\RPFac` is now written through `\Rfree`, `\prdNxt` through
`\prdt`. HARK names: `mNrmTrg`, `mNrmStE`.

**Mechanical.** `econark-shortcuts.sty` declares itself (`\ProvidesPackage`) and what it needs; its thorns
work in any font encoding; `\shr` is defined (`\ShrBar` used it undefined); `\muFuncInv` is the inverse of
MARGINAL utility (it was drawn the same as `\uFuncInv`); `\cnstr` goes through `\ARKcommandParam`. TeX finds
`econark-notation.sty` through a symlink in `texmf-local/tex/latex/`. `@resources-update-from-remote.sh`: a
dry run no longer changes permissions, and the vendored copy is executable.

## v4.0.0 — 2026-10-21

- **MAJOR — econark-shortcuts and the registry agree on every shared name.** Owner, in an
  earlier econ-ark-tools session at about 16:48 EDT: "OK, implement your recs" (branch
  `notation-patience-factor-forms`, commit b23e5668, never merged); then, in this session at
  22:40:21 EDT: "I want to reconcile and merge all the branches on which we have been trying
  already to reconcile notation". This re-applies that branch on top of v3.0.0.
  - `\RPFac`, `\GPFacRaw`, `\GPFacMod`: econark-shortcuts writes the subscript forms
    `\APFac_{\Rfree}`, `\APFac_{\PermGroFac}`, `\APFac_{\PermGroFacAdj}`, not the ratios
    Þ/R, Þ/𝒢 that define them. `\GPFac` is now `\GPFacRaw`, not a separate copy.
  - The registry's `\RPFac` takes the sans-serif R of `\Rfree` (`\APFac_{\mathsf{R}}`; it was an
    italic R), and `\GPFacRaw` is `\APFac_{\PermGroFac}`.
  - `\RNrmByG`, `\RNrmByGRnd`: calligraphic `\mathcal{R}` in econark-shortcuts (was
    `\mathscr{R}`), as in the registry and shortcuts' own `\Rnorm`.
  - In print, documents that load econark-shortcuts change: the BST paper's 342 `\RPFac` and
    187 `\GPFacRaw` read Þ_R and Þ_𝒢, not Þ/R and Þ/𝒢, and its 77 `\RNrmByG` turn
    calligraphic. `BufferStockTheory.tex:76-89` records the coauthor (AS) objecting to a stacked
    `\frac` and accepting the inline ratio Þ/R; he has not seen the subscript forms, so this is a
    new change to his paper.

## v3.0.0 — 2026-10-21

- **MAJOR — the return region's upper edge is ō, not ζ** (owner: "OK, o-bar sounds great
  implement that", 22:07:59 EDT). The `return-region` row now has a macro, `\wbarMax` = `\bar{o}`:
  ō = C₀/(1 − Þ_𝒢), the fixed point of o ↦ Þ_𝒢 o + C₀, which anchors the travel time
  n(o) = ln(o/ō)/(−þ_g). o is the object's own letter (total wealth) and the bar is the registry's
  mark for an upper bound (κ̄, h̄, ḡ). This ends the registry's one remaining overlap with
  econark-shortcuts (ζ is its `\leiShare` and `\unins`) and leaves ζ to the powerlaw draft's ζ*,
  the Pareto exponent, for which ζ is the literature's letter. The draft's ζ is recorded as a NOT
  SANCTIONED `powerlaw-pages` dialect.
- The same row wrote the powerlaw pages' θ for the transitory shock: its gloss now says ξ has
  bounded support, and C₀'s θ_max is ξ̄ (`\tranShkMax`).

## v2.1.1 — 2026-10-21

- **econark-shortcuts' `\APFac` bolds the thorn once** (owner: "yes, it should be a single \textbf
  not double"). It was `\text{\pmb{\Thorn}}`, and with BufferStockTheory's `\Thorn` = `\pmb{\TH}`
  (and v2.1.0's copy of it here) the thorn was bolded twice and looked smeared. Now `\Thorn` is
  the plain glyph `\text{\TH}` and `\APFac` is `\textbf{\Thorn}`, the registry's rendering, so
  `\APFac` leaves the README's list of macros that render differently. BST's
  `\providecommand{\Thorn}{\pmb{\TH}}` (local.sty, the slides) becomes a no-op whichever loads
  first, since shortcuts' `\ARKcommand` overwrites; its tikz `\Pat` = `\textbf{\Thorn}` is
  single-bold too. `\RPFac` and `\GPFacRaw` keep their ratio forms.

## v2.1.0 — 2026-10-21

Requested by the buffer-stock schemas' session (llorracc/sce-wg-1-dev), item 5 of its notation
batch; the owner approved the batch there: "all five as written" (20:43:30 EDT).

- **Rows for the schemas' symbols (MINOR).** θ, the employed draw (`\tranShkEmp`); ξ_U, income
  while unemployed (`\IncUnemp`, python `IncUnemp`); the minima ξ̲, θ̲, ψ̲ (`\tranShkMin`,
  `\tranShkEmpMin`, `\permShkIndMin`); the borrowing constraints a̲_Art, a̲_Nat and the one in force,
  a̲ (`\BoroCnstArt`, `\BoroCnstNat`, `\aMin`); the lowest market resources m̲ (`\mNrmMin`); survival
  ℒ (`\LivPrb`); and the probability of the worst income, p_worst (`\pWorst`). Seven reuse
  econark-shortcuts' macros with the same rendering; `\BoroCnstArt`, `\BoroCnstNat`, `\pWorst` and
  `\mNrmMin` are new, named for HARK where HARK has a name.
- **`\IncUnemp` is ξ_U in econark-shortcuts.sty**, not μ, which is this registry's log excess
  resources. Owner, in the sce-wg-1-dev session: "fix \IncUnemp's erroneous expansion" (19:59:01
  EDT), after choosing ξ_U there at 19:25.
- **econark-shortcuts.sty defines `\Thorn` and `\thorn`** (owner: "yes", 2026-10-21, to adding
  the definition). Its `\APFac` and its rates `\APRte`, `\RPRte`, `\GPRte` used them without
  defining them, so a document that loaded the file without its own definitions failed. `\Thorn`
  is BufferStockTheory's `\pmb{\TH}` (in `\text`), so BST's output does not change; `\thorn` is a
  plain `\th`. Both need T1 encoding, as the registry's `\text{Þ}` does.
- **`mpc-min`'s define is κ̲ = max(0, 1 − Þ_R)**, so it covers a failing RIC, where the limiting
  MPC is 0. The schemas write R(1 − κ̲) for min(Þ, R), which needs that reading.
- **A `plain` field beside `unicode`**, for terminals and code where a combining underline
  misdraws: `κ_min`, `h_min` and every new underlined row. NOTATION.md's table gains a Plain column.

## v2.0.0 — 2026-10-21

- **MAJOR — the patience factors are bold (owner ruling, 2026-10-21):** "yes, factor rows
  should change to bold". `\APFac` = `\textbf{Þ}`, `\RPFac` = `\textbf{Þ}_{R}`,
  `\GPFacRaw` = `\textbf{Þ}_{\PermGroFac}`; they were plain `\text{Þ}`. This brings the
  registry into line with the owner's standing rule of 2026-10-04: a factor, a number compared
  with 1, takes a bold capital thorn; a rate, its log, a small thorn (`\thorn`, unchanged). The
  registry had contradicted that rule while nothing recorded the question as open.
  econark-shortcuts' `\APFac` was already bold, by `\pmb`. Unicode has no bold thorn, so the
  `unicode` and `define` fields still write Þ.
- **The powerlaw draft takes its notation from `@resources` (owner ruling, 2026-10-21):** "the
  powerlaw work needs to use the same @resources/econ-ark-tools approach as the other papers;
  that way it does not have many things to define, except mathematical objects absent from the
  other wor[k]". Its pages define about 60 macros in their own `myst.yml`; they are to take the
  shared ones from `@resources/` and define only objects absent from the other papers. The
  `powerlaw-pages` dialect entries (Γ for the growth factor, θ for the transitory shock, plain Þ
  for the factors) are now marked NOT SANCTIONED: they record what the pages' own macros still
  write, until they switch. Taking the shared macros settles the transitory shock's direction,
  which ruling 4 had left open (ξ, not θ), and the excess-resources unification, which had been
  "candidate, NOT ruled" (m̈, `\mNrmEx`, not mᵉ); the constraint-end exponent's definition here
  now writes m̈. The `bst-paper` (γ for ρ) and `hark-python` (h − 1) dialects are not the
  powerlaw draft and are unchanged.

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
