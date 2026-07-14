# PROMPT — fix the red "Econ-ARK Tools CI" (shell-validation jobs)

You are working in the local clone of **econ-ark/econ-ark-tools**
(`~econ-ark/github/econ-ark/econ-ark-tools`, i.e.
`/home/shared/github/econ-ark/econ-ark-tools`). The repo's GitHub Actions
workflow "Econ-ARK Tools CI" has been **red on `master` for months**. Your job is
to make its shell-validation jobs green.

## Do this

1. **Read the plan in full:** `.agents/plans/20260714_fix-ci-shell-validation.md`.
   It contains the diagnosis (which jobs, which 40/83 files, the 3 hard errors),
   the standard-and-scope decision you must make and record, the step-by-step
   fix, guardrails, and success criteria. Follow it.
2. **Work on a dedicated branch** off `master` (e.g. `fix-ci-shell-validation`).
   Do NOT use `notation-registry-v0` (that is the unrelated notation-registry PR
   `#35`; leave it alone). Confirm your starting point with
   `git status` / `git log --oneline -3` before editing.
3. **Reproduce before you fix, and verify after** — with the *exact* tools CI
   uses (shellcheck 0.10.0 static binary; `bash -n`; `zsh -n`). The plan gives the
   download one-liner. Local repro is necessary but not sufficient: the runner is
   ubuntu-20.04 / macOS bash 3.2.
4. **Open a PR against `master`** and do not consider the task done until the
   three shell jobs ("Shell Script Validation", "Test on Ubuntu", "Test on
   macOS") are **green on the actual Actions run** (`gh pr checks <n>`). Iterate
   if the runner disagrees with local.
5. In the **PR body**, record the decisions the plan asks for: the chosen
   standard (pragmatic-baseline A vs strict-burndown B) and why; the first-party
   vs vendored scan scope; the 3 error fixes; anything waived and why.

## Hard constraints

- **Do not change the behavior of any load-bearing script** (the `Virtual/**` VM
  provisioning tree, the `make4ht`/`de-macro` scripts, or any `@resources/**`
  script). For style-only findings use `# shellcheck disable=` (with a reason) or
  a scoped exclusion / `.shellcheckrc` — change code only for genuine bugs.
- `@resources/**` is the **SST** vendored into every consumer repo (see
  `@resources/.agents/AGENTS.md` for the read-only handling protocol and the SST
  push workflow). A behavior change there ships everywhere — be conservative.
- **Scope stays the shell-validation trio.** If the LaTeX / BibTeX jobs are also
  red, note it but fix them in a separate PR — not here.
- **Push / open-PR is owner-facing.** Confirm with the owner before pushing to
  the public econ-ark org repo, as usual.

## Definition of done

Shell Script Validation + Test on Ubuntu + Test on macOS green on the PR; no
behavior change to maintained scripts; the CI standard and scan scope are
documented and deliberate; the PR body records the standard/scope/fix decisions.
