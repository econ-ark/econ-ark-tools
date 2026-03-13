# CI Drift Detection for `@resources/`

This guide describes how to set up automated detection of drift between
a project's local `@resources/` and the SST in `econ-ark-tools`.

## Strategy

A GitHub Actions workflow (or local pre-commit hook) clones
`econ-ark-tools`, diffs the two `@resources/` trees, and reports any
differences. This catches both unintentional local edits and upstream
SST updates that haven't been pulled in.

## Sample GitHub Actions Workflow

Add this as `.github/workflows/resources-drift-check.yml` in your
project repository:

```yaml
name: "@resources drift check"

on:
  push:
    paths:
      - "@resources/**"
  pull_request:
    paths:
      - "@resources/**"
  schedule:
    # Run weekly to catch upstream SST changes
    - cron: "0 9 * * 1"

jobs:
  check-drift:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout project
        uses: actions/checkout@v4

      - name: Clone econ-ark-tools (SST)
        run: |
          git clone --depth 1 https://github.com/econ-ark/econ-ark-tools.git /tmp/econ-ark-tools

      - name: Compare @resources trees
        run: |
          diff_output=$(diff -rq \
            --exclude='.DS_Store' \
            --exclude='auto' \
            --exclude='*~' \
            --exclude='*.tmp' \
            "@resources/" \
            "/tmp/econ-ark-tools/@resources/" \
          2>&1) || true

          if [ -n "$diff_output" ]; then
            echo "::warning::@resources/ has diverged from the SST"
            echo "$diff_output"
            echo ""
            echo "To resolve:"
            echo "  - Revert local: run @resources/scripts/@resources-update-from-remote.sh"
            echo "  - Push upstream: apply changes in econ-ark-tools, push, then re-sync"
            exit 1
          else
            echo "@resources/ is in sync with the SST."
          fi
```

## Local Pre-Commit Hook (Alternative)

For faster feedback, add a git pre-commit hook that runs the same diff
locally before each commit:

```bash
#!/bin/bash
# .git/hooks/pre-commit (or via pre-commit framework)

sst_clone="/path/to/local/econ-ark-tools"

if [ ! -d "$sst_clone/@resources" ]; then
  echo "Warning: econ-ark-tools clone not found at $sst_clone"
  exit 0  # don't block commit, just warn
fi

drift=$(diff -rq \
  --exclude='.DS_Store' --exclude='auto' --exclude='*~' --exclude='*.tmp' \
  "@resources/" "$sst_clone/@resources/" 2>&1) || true

if [ -n "$drift" ]; then
  echo ""
  echo "WARNING: local @resources/ differs from SST at $sst_clone"
  echo "$drift"
  echo ""
  echo "Consider running: @resources/scripts/@resources-update-from-remote.sh"
  echo "Or propagate your changes to econ-ark-tools and push."
  echo ""
fi
```

## Resolving Detected Drift

When drift is detected, choose one of:

1. **Revert local to SST**: run
   `@resources/scripts/@resources-update-from-remote.sh`
2. **Push local changes to SST**: make the same edits in your local
   clone of `econ-ark-tools/@resources/`, then `git add && git commit
   && git push` in that repo. Finally re-sync with the update script.
