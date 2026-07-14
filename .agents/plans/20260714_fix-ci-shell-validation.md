# Plan — fix the chronically-red "Econ-ARK Tools CI" (shell-validation jobs)

**Status:** DONE (created 2026-07-14, implemented 2026-07-14). Implemented via
`.agents/prompts/20260714_fix-ci-shell-validation.md` on branch
`ci-shell-validation-fix`.

## Problem

`.github/workflows/ci.yml` (workflow "Econ-ARK Tools CI") has failed on
**every `master` run for months** (verified back to 2026-03). Five jobs:

| job | what it does | state |
|---|---|---|
| Shell Script Validation | `shellcheck --shell=bash --enable=all --severity=warning` on **every** `*.sh` in the repo | **FAIL** |
| Test on Ubuntu | `bash -n` on every `*.sh` | fails/incomplete |
| Test on macOS | `bash -n` **and** `zsh -n` on every `*.sh` (runner ships bash 3.2) | **FAIL** |
| LaTeX Configuration Validation | installs `texlive-full`, compiles `econark-shortcuts.sty` | out of scope here (see §Non-goals) |
| BibTeX Wrapper Functionality Test | installs `texlive-full`, exercises `bibtex_wrapper.sh` | out of scope here |

The failure is **repo-wide pre-existing script debt**, not any single recent
change. Measured 2026-07-14 with shellcheck 0.10.0 (the version CI installs):

- **83** `*.sh` files total; **40** fail `--enable=all --severity=warning`.
- **3** have HARD shellcheck errors (these are real bugs):
  - `@resources/texlive/texmf-local/scripts/make4ht/bounding-boxes-missing-add.sh`
    — `SC1105` (ambiguous `((` at :52) and `SC2071` (`>` used as numeric
    comparison, needs `-gt`, at :59).
  - `@resources/texlive/texmf-local/scripts/make4ht/makeWeb_on_gh-pages_then-move-to-docs-dir-on-head.sh`
    — `SC2077` (missing spaces around a comparison operator at :63) and `SC2140`
    (ambiguous quoting).
  - `Virtual/Machine/ISO-maker/Files/For-Target/installers/install-texlive-latest.sh`
    — `SC1121` (heredoc terminator on the wrong line at :30).
- The remaining ~37 are warnings, dominated by the noisy *optional* checks that
  `--enable=all` turns on: `SC2164` (`cd … || exit`), `SC2034` (unused vars —
  many are false positives in `source`-d config files), `SC2155` (declare+assign
  masking), `SC2046`/`SC2027`/`SC2140` (quoting), `SC2024` (`sudo` + redirect).

The bulk of the offenders are **vendored / environment-specific**: the entire
`Virtual/Machine/ISO-maker/**` VM-provisioning tree and the `make4ht`/`de-macro`
scripts under `@resources/texlive/texmf-local/scripts/**` are adapted upstream
tooling, not code this repo actively authors.

## Goals

1. Get **Shell Script Validation**, **Test on Ubuntu**, **Test on macOS** GREEN.
2. **Do not change the behavior** of any load-bearing script (VM provisioning,
   make4ht build pipeline, `@resources/**` scripts vendored into consumer repos).
3. Leave the CI **meaningful, not muted** — a standard the repo can hold new
   scripts to, documented so it does not rot again.

## The decision to make and record (do this first)

`--enable=all --severity=warning` is an unusually strict bar — it enables *every*
optional shellcheck check, which almost no real repo passes. Pick an end state
and record it in the PR body:

- **(A) Pragmatic baseline (RECOMMENDED).** Drop `--enable=all`; keep shellcheck's
  default check set; gate on `--severity=error` (hard bugs fail CI, style is
  advisory) **or** `--severity=warning` with a repo `.shellcheckrc` that
  `disable=`s the handful of noisy optional checks. Fix the 3 real errors. Scope
  the scan to first-party scripts (see §Scope). Green fast, low risk, still
  catches real bugs.
- **(B) Strict + burndown.** Keep `--enable=all` but add a `.shellcheckrc`
  `disable=` list + per-file `# shellcheck disable=SCxxxx` directives, and fix or
  waive all 40. Stricter, much more work, higher chance of behavior-touching edits.

Recommend **(A)**. Whichever you choose, the 3 hard errors get fixed regardless.

## Scope — first-party vs vendored

Classify, and make the CI scan scope explicit (a `find … -not -path` filter, an
allow-list, or a `.shellcheckrc`-honored layout):

- **First-party (hold to the standard, fix genuinely):**
  `@resources/bash/**`, `@resources/scripts/**`, `@resources/shell/**`,
  `@resources/git/**`, `@resources/econ-ark/**`, `@resources/latexmk/**/tools/**`,
  `@resources/notation/notation-lint.sh` (already clean), `create_deprecation_wrappers.sh`.
- **Vendored / environment-specific (exclude from the scan, or scan at
  `--severity=error` only; do NOT restyle):**
  `Virtual/**` (VM ISO-maker provisioning), `@resources/texlive/texmf-local/scripts/**`
  (make4ht, de-macro — upstream-derived).

Excluding vendored trees is legitimate: CI should gate the code this repo
maintains, not third-party tooling carried for convenience. State the exclusion
and its rationale in `.shellcheckrc`/workflow comments so it is a deliberate,
reviewable choice.

## Steps

1. **Reproduce locally with the exact tools** (do not trust memory):
   - shellcheck 0.10.0 static binary (no apt needed):
     `curl -fsSL https://github.com/koalaman/shellcheck/releases/download/v0.10.0/shellcheck-v0.10.0.linux.x86_64.tar.xz | tar -xJ` then use `./shellcheck-v0.10.0/shellcheck`.
   - `bash -n` (local bash is 5.x; the macOS runner is 3.2 — watch for bash-4+ only
     syntax: `declare -A`, `${var,,}`/`${var^^}`, `mapfile`/`readarray`, `&>>`).
   - `zsh -n` if available; otherwise reason about zsh-parse compatibility for any
     script you touch.
2. **Fix the 3 hard errors** (real bugs). For each: make the minimal correct fix
   (`SC2071` → `-gt`; `SC2077` → add spaces; `SC1121` → move the heredoc
   terminator/`;`), then confirm the script still `bash -n`-parses AND behaves the
   same. These live in vendored trees — if you would rather exclude those trees
   wholesale (Scope above), you may still fix the errors since they are genuine,
   but keep the diff minimal.
3. **Rework `.github/workflows/ci.yml`:**
   - Apply the chosen standard (A or B) to the `shellcheck` job's `SHELLCHECK_OPTS`.
   - Apply the chosen **scan scope** consistently to all three shell jobs
     (shellcheck, test-ubuntu, test-macos) so they agree on which files matter.
   - Make each job **enumerate all offenders** before failing (accumulate results
     rather than `exit 1` on the first file) so future burndown is easy.
   - Consider adding a repo-root `.shellcheckrc` (shellcheck reads it
     automatically) to hold the `disable=`/severity config in one versioned place.
4. **macOS/zsh job:** for each first-party script that fails `bash -n` (3.2) or
   `zsh -n`, fix the genuine portability issue; for vendored trees, rely on the
   scope exclusion. Keep scopes identical across jobs.
5. **Verify locally** over the scoped set: shellcheck clean at the chosen
   severity, `bash -n` clean, `zsh -n` clean (or reasoned). 
6. **Branch → PR → confirm real CI green.** Push, open a PR against `master`,
   watch the Actions run, and only call it done when the three shell jobs are
   green on GitHub (local repro is necessary but not sufficient — the runner's
   bash 3.2 / ubuntu-20.04 differ from local).

## Non-goals (do not expand scope)

- The **LaTeX Configuration** and **BibTeX Wrapper** jobs (they install
  `texlive-full`, are slow, and may be independently red). If they are also
  failing, note it in the PR but fix them in a **separate** PR — this one is the
  shell-validation trio only.
- The notation-registry PR (`econ-ark-tools#35`, branch `notation-registry-v0`)
  is unrelated — do not touch it; its `notation-lint.sh` already passes every one
  of these checks.

## Guardrails

- `@resources/**` is the **SST** vendored into every consumer repo (see
  `@resources/.agents/AGENTS.md`). Editing it here is correct, but a behavior
  change ships to all consumers — so for `@resources/**` scripts, prefer
  linter-satisfying-but-behavior-preserving edits and shellcheck directives over
  logic changes; never restyle a vendored script in a way that alters what it does.
- **Never change a script's behavior to satisfy a style check.** Use
  `# shellcheck disable=` (with a one-line reason) or scope exclusion for
  style-only findings; change code only for genuine bugs.
- Respect the read-only handling protocol in `@resources/.agents/AGENTS.md` when
  editing `@resources/**` files.

## Success criteria

- "Shell Script Validation", "Test on Ubuntu", "Test on macOS" all **green** on
  the PR's Actions run.
- Zero behavior change to load-bearing scripts (spot-check the ones you edited).
- The standard is documented (`.shellcheckrc` and/or workflow comments) and the
  scan scope is an explicit, reviewable choice.
- The PR body records: which standard (A/B) was chosen and why; the scope
  decision; the 3 error fixes; anything waived and why.
