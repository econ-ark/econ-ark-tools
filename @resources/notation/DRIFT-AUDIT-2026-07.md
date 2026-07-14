# Drift audit — `econark-shortcuts.sty` vs `econark-shortcuts.md`

**Date:** 2026-07-14 · **Branch:** `notation-registry-v0` · **Mission:** plan 33
(notation registry). **Status:** REPORT — the only change applied in this branch
is the owner-ruled `*Lvl` fix (Category A below); every other finding is a
recommendation for the owner to rule on in the registry PR.

## Method

A best-effort LaTeX-macro parser extracted `(\name → expansion)` pairs from both
files, normalized whitespace, and diffed. Definition forms handled:
`\newcommand`, `\renewcommand`, `\providecommand`, `\ARKcommand`,
`\ARKcommandParam`. Brace balance was tracked per line to catch stray/missing
braces. Raw counts:

| | value |
|---|---|
| macros in `.sty` | 386 |
| macros in `.md` | 307 |
| both, expansion differs | 80 |
| only in `.sty` | 82 |
| only in `.md` | 3 |
| `.md` lines with a brace/syntax anomaly | 60 |

The two files are BOTH hand-maintained; neither is generated from the other. The
`.md` mirror is what the MyST pipelines (BST-Latest, MoM, powerlaw) consume, so
its defects are the load-bearing ones.

## Category A — the `*Lvl` family (RULED; FIXED in this branch)

Owner ruling 2: canonical rendering is `\boldsymbol{\mathit{x}}` (the `.sty`
form), NOT `\pmb{x}` (the `.md` form). The `.md` additionally carries a **stray
trailing `}`** on every one of these lines (`\newcommand{\aLvl}{\pmb{a}}}` — note
the double close), which the current MyST build tolerates only because the extra
brace lands between definitions.

Applied fix (this branch, `@resources/markdown/econark-shortcuts.md`): the 52
single-letter `*Lvl` macros — `\aLvl … \zLvl` and `\ALvl … \ZLvl` — rewritten to
`\newcommand{\xLvl}{\boldsymbol{\mathit{x}}}` (single close brace). Nothing else
in the file was touched.

## Category B — genuine rendering divergences (REPORT; recommend reconcile to `.sty`)

These render as **different glyphs**, not cosmetic brace noise. Recommendation:
adopt the `.sty` form (it is the LaTeX source of truth and what PDF builds use)
unless the owner rules otherwise.

| macro | `.sty` | `.md` | note / recommendation |
|---|---|---|---|
| `\PermLvlAll` | `\pmb{P}` | `\mathfrak{P}` | different letterform; `.sty` is consistent with the other `*All` = `\pmb` convention → adopt `.sty` |
| `\PermShkAll` | `\pmb{\Psi}` | `\mathbf{\Psi}` | `\pmb` (true poor-man-bold) vs `\mathbf`; `.sty` matches the stated "All uses `\pmb`" principle → adopt `.sty` |
| `\RNrm` | `R` | `\cancel{\mathbf{R}}` | **semantic conflict.** `.sty` defines `\RNrm` as plain `R` (part of the R Lvl/Nrm/Func block) yet its comment says missed `\RNrm` should "stick out like a sore thumb"; `.md` implements the sore-thumb intent (`\cancel{\mathbf R}`). Owner must decide which is canonical — they contradict. |
| `\PermLvlAgg` | `\boldsymbol{\mathit{P}}` | `\pmb{P}` | same `\pmb`→`\boldsymbol{\mathit{}}` drift as Category A but on a *named* macro (not a single letter, so outside ruling 2's literal scope); recommend the same fix + it also has a stray `}` (Category C) |
| `\permLvlInd` | `\boldsymbol{\mathit{p}}` | `\pmb{p}` | ditto |

### Tax-family NAME divergence (report)

The two files use **different macro names** for the tax concepts:

| concept | `.sty` | `.md` |
|---|---|---|
| tax amount/level | `\TaxAmt` (= `T`) | `\TaxLev` (= `T`) |
| tax rate | `\TaxRte`, `\tax` (= `\tau`) | `\Tax` (= `\tau`) |
| tax-free marker | `\taxFree` | `\TaxFree` |

A document written against one file will emit "Undefined control sequence"
against the other. Recommendation: pick one set (the `.sty`'s `\TaxAmt`/`\TaxRte`
follow the Fac/Rte casing convention) and alias the other for back-compat.

## Category C — broken `.md` syntax (REPORT; recommend fix)

Genuine defects in the consumed `.md` mirror, beyond the ruled `*Lvl` block:

- **`\Wage` / `\wage` — MISSING closing brace** (`.md:230-231`):
  `\newcommand{\Wage}{\mathsf{W}` (no final `}`). This swallows the following
  token(s) in a strict parse. `.sty` is correct (`{\mathsf{W}}`). **Recommend fix.**
- **`\cncl` — corrupted** (`.md:318-320`):
  ```
  \newcommand{\cncl}{} \renewcommand\cncl[1]{\
  \newcomm}}
  ```
  garbage tail (`\newcomm}}`), and the `\renewcommand` omits braces around the
  name. `.sty` is correct (`\ARKcommandParam{\cncl}{1}{{\cancel{#1}}}`).
  **Recommend fix** (this is the kind of thing that silently breaks a build).
- **`\PermLvlAgg` / `\permLvlInd` — stray trailing `}`** (`.md:125-126`), same
  defect class as Category A but on named macros. Recommend the same single-brace fix.

## Category D — cosmetic brace-wrapping (REPORT; harmless, optional normalize)

~19 macros differ ONLY by a redundant outer `{ }` in the `.sty` (e.g. `\Ex`:
`{\mathbb{E}}` vs `\mathbb{E}`; also `\Mean \PDV \FDist \fDist \Rnorm \rnorm
\Chi \EEndMap \cEndFunc \CEndFunc \aMin \erate \urate \unins \riskyshare
\muFuncInv \wage \Wage`). Renders identically. No action required; if a generator
ever emits these, normalize by dropping the redundant wrapper.

## Category E — coverage gap (REPORT)

**82 macros defined in `.sty` are ABSENT from the `.md` mirror.** The large blocks:

- **Stage / perch / period notation** (~35): `\prdt \prd \prdT \prdNxt \prdLst
  \prdNxT \prdLsT`, `\prch \Prch \prchs \Prchs \interval \Interval \intervals
  \Intervals \stg \Stg \stgs \Stgs`, `\Arrival \arvl \Continuation \cntn
  \Decision \dcsn \Arvl \ArvlNxt \Cntn \Dcsn \DcsnNxt`, `\vArvl \vArvlNxt \vDcsn
  \vCntn \cCntn \ExArvl \ExCntn \ExDcsn`, builders `\Cnct \Cncts \Cnctr
  \CnctrComp \BkBldr \FwBldr \BkBldrPrd`, `\StgName`.
- **Single-letter `*Nrm` / `*Func` gaps** (~23): `\gNrm \lNrm \nNrm \qNrm \rNrm
  \tNrm \uNrm \wNrm \xNrm \GNrm \LNrm \ONrm \QNrm \TNrm \UNrm \WNrm \XNrm \lLvl
  \lFunc \oFunc \qFunc \tFunc` (the `.md` defines the alphabet inconsistently —
  some letters have all three of Lvl/Nrm/Func, others are missing one or two).
- **Misc**: `\kapShare \ARKcommand \ARKcommandParam \mNrmTrg \ShrBar \VInv \vInv
  \aVecMin \tax \taxFree \PermGroFacAdjV \PermGroFacAdjMu`.

Consequence: any BST/MoM/powerlaw page that uses a stage-notation or a
missing-letter macro must define it locally (via `@local`) or fail the build.
This is exactly the fragmentation the registry is meant to end. **Recommendation:
regenerate the `.md` mirror from the `.sty` (or, longer-term, from a superset
registry) so the two cannot diverge (see Phase 4).** 3 macros are only in `.md`:
`\Tax \TaxFree \TaxLev` (the Tax-family rename above).

## Category F — `.md` internal issues (REPORT; cosmetic)

- **Double definitions** (13): `\PermGroRte` is defined twice identically
  (`.md:148-149` — a real duplicate); the rest are the `\newcommand{X}{}` then
  `\renewcommand{X}{…}` two-step idiom (`\Alive \DiscAlt \Nrml \Opt \cov
  \cFuncAbove \cFuncBelow \PopGroFac \popGroRte \PtyGroFac \PtyGroRte \ptyGroFac
  \ptyGroRte \Reals \TMap \vFuncLvl \cFuncLvl`). Harmless but noisy; a
  regenerated mirror would emit each once.
- The four "syntax anomalies" flagged in the `.sty` (`\ARKcommand`,
  `\ARKcommandParam`, `\cncl`, `\StgName`) are **parser artifacts** of
  multi-argument / multi-line macro bodies — the `.sty` is well-formed on
  inspection. No action.

## Bottom line

The ruled `*Lvl` fix is applied. Everything else is reported for the registry PR.
The structural finding: two hand-maintained shared files (`.sty`, `.md`) have
diverged in rendering (Cat A/B), correctness (Cat C), naming (Tax), and coverage
(Cat E). A single source with generators (this mission) removes the divergence
for the notation the theory/MoM/HARK thread actively rules on; extending
generation to cover the full `.sty`↔`.md` mirror (Phase 4) would close the rest.
