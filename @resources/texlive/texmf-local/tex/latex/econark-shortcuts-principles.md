# econark-shortcuts principles

Canonical list of typographical and naming conventions for ARK notation. Implemented in `econark-shortcuts-raw.sty`; brief reminders appear in context there.

---

## 1. Variable roles: Level, Normalized, Function, Log

- **Level (Lvl)** — Boldface italic: `\boldsymbol{#1}`, bold in KaTeX too (owner ruling 2026-11-15; was `\boldsymbol{\mathit{#1}}`, which KaTeX prints unbolded). Levels (e.g. consumption level, asset level): bold marks a level that can be or will be divided by a normalizer; a normalizer itself, such as labor-augmenting productivity Z, is never bold (owner ruling 2026-11-16).
- **Normalized (Nrm)** — Plain (default math italic). Ratios to permanent income.
- **Function (Func)** — Upright roman: `\mathrm{#1}`. Policy/value functions; roman is reserved for functions.
- **Log** — The natural log, printed ℓ: `\l<macro>` = `\logOp` (= `\ell`) followed by the macro, so `\lcNrm` = ℓc and `\lcLvl` = ℓ𝒄, for every letter's Nrm and Lvl macro (owner rulings 2026-11-15 and 2026-11-17; printed log c until v11.0.0, when labor moved from ℓ to l). Never a lower-case letter for a log. This replaces the sans-serif italic `\mathsfit{#1}` (`\CLog`, `\KLog`, `\YLog`) described here from 2026-03-12, whose macros were never defined.

Summary: **Lvl = bold italic**, **Nrm = plain**, **Func = roman**, **Log = ℓ** (`\lcNrm`).

---

## 2. Aggregate vs individual vs “All”

- **Aggregate (Agg)** — Uppercase (e.g. Ψ, Θ). Individual (Ind): lowercase (e.g. ψ, ξ).
- **All (Ind + Agg combined)** — Use **`\pmb`** for all “All” quantities. Supported in MathJax and KaTeX.

---

## 3. Greek: factor vs rate

- **Greek letters:** Uppercase = factor, lowercase = rate (e.g. Ξ vs ξ).
- **Roman exceptions:** G/g = growth factor/rate; R/r = return factor/rate (riskless uses `\mathsf`).

---

## 4. Returns

- **Riskless** — Sans-serif: `\mathsf{R}`, `\mathsf{r}`.
- **Risky** — Bold italic: `\boldsymbol{R}`, `\boldsymbol{r}` (roman reserved for functions).
- **Portfolio / composite** — Fraktur: `\mathfrak{R}`, `\mathfrak{r}`. Other portfolio or weighted-combination quantities use fraktur; currently only `\Rport`/`\rport` are defined.

---

## 5. Operators and end-of-period

- **Expectations, maps** — Blackboard bold: `\mathbb{E}`, `\mathbb{T}`, etc.
- **End-of-period** — Fraktur for all end-of-period objects: `\mathfrak{E}`, `\mathfrak{C}`/`\mathfrak{c}`.

---

## 6. Growth and special symbols

- **Permanent growth (aggregate)** — Script: `\mathscr{G}`. Generic/oddity: calligraphic `\mathcal{G}`.
- **Normalized riskless return** — Calligraphic factor, italic rate.
- **Oddities** — `\mathcal`, `\mathfrak`, `\mathbb` for things outside the main scheme (e.g. CDF, reals).

---

## 7. Modifiers and function + modifier

- **Accents:** `\bar` (avg), `\overline` (max), `\underline` (min), `\tilde` (random), `\breve` (optimal), `\grave` (constrained), `\hat` (target).
- **Function + modifier:** Always **modifier(base function)**, e.g. `\cFuncAbove` = `\Max{\cFunc}`, `\mTrgNrm` = `\TargetNrm{\mNrm}`.

---

## 8. Level functions (value, consumption)

- **Level function** — Bold + roman (not bold italic): `\boldsymbol{\mathrm{v}}`, `\boldsymbol{\mathrm{c}}`.

---

## 9. Verbal, documentation, and code

- **Verbal / name identifiers** — Typewriter: `\texttt` (e.g. stage/perch names, `\nxt`, `\lst`).
- **Documentation / URL macros** — Grouped; use **`\texttt`** inside links.
- **Computational instantiation / builders** — Typewriter: `\mathtt` (e.g. `\CnctrComp`, `\BkBldr`). Connector (abstract) uses `\mathcal{C}`; builders use `\mathtt{B}`.

---

## 10. Renderer compatibility

Conventions use only commands that render **natively in both KaTeX and MathJax** (e.g. `\pmb`, `\mathsfit`). Bold script/fraktur/calligraphic and stacking are not used for semantic categories because they are not supported in KaTeX.
