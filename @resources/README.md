# `@resources/` -- Shared Econ-ARK Resources

This directory is populated from the
[econ-ark-tools](https://github.com/econ-ark/econ-ark-tools) GitHub
repository, which serves as the **Single Source of Truth (SST)** for all
shared LaTeX style files, BibTeX databases, build scripts, and related
tooling used across Econ-ARK projects.

## Permissions

Files in this directory are intentionally kept **read-only** as a
reminder that changes here must eventually be propagated back to the SST.
Local edits are permitted for testing proposed changes, but they should
be treated as temporary:

- Before modifying a file: `chmod u+w <file>`
- After modifying: restore read-only with `chmod u-w <file>`
- New files should match the permission mode of existing siblings in the
  same directory

## Resolving Drift

When local `@resources/` diverges from the SST, there are two paths:

### Revert local to match the remote SST

```bash
@resources/scripts/@resources-update-from-remote.sh
```

This clones the latest `econ-ark-tools`, rsyncs `@resources/` from it,
and restores read-only permissions.

### Push local changes upstream to the SST

1. Locate your local clone of `econ-ark-tools`
2. Make the same changes in `econ-ark-tools/@resources/`
3. `git add`, `git commit`, and `git push` in that repo
4. Run `@resources-update-from-remote.sh` to re-sync and confirm parity

## See Also

- `.agents/AGENTS.md` -- instructions for AI coding agents
- `.agents/ci-drift-detection.md` -- guide for CI-based drift detection
