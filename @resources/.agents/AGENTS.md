# Agent Instructions for `@resources/`

## Single Source of Truth

The contents of `@resources/` are managed from the
[econ-ark-tools](https://github.com/econ-ark/econ-ark-tools) repository.
That repo is the **Single Source of Truth (SST)**. Every project that
uses `@resources/` carries a local copy that should stay in sync with
the SST.

## Do Not Edit `@resources/` In-Place (Without the SST Workflow)

Local edits to `@resources/` are permitted for testing proposed changes.
However, any change that is meant to persist **must** be propagated to
the SST. The workflow is:

1. Make the change in the local clone of `econ-ark-tools` (see the
   project's `.agents/private/resources-sst.md` for the clone path on
   this machine).
2. In that clone: `git add`, `git commit`, `git push`.
3. Run `@resources/scripts/@resources-update-from-remote.sh` from the
   project root to re-sync the local copy.

To revert local changes without pushing upstream, simply run the same
sync script -- it will overwrite local `@resources/` with the remote
SST contents.

## Read-Only Handling Protocol

Files in `@resources/` are typically **read-only**. Before modifying any
file:

1. Record whether the file (or directory) is currently read-only.
2. Run `chmod u+w <file-or-dir>` to allow writes.
3. Make the modification.
4. Restore the original permissions:
   - If the file was read-only before, run `chmod u-w <file>`.
   - For newly created files, match the permission mode of existing
     files in the same directory (typically `r--r--r--` / `444`).

## Key Paths

| Resource | Path |
|----------|------|
| Sync script | `@resources/scripts/@resources-update-from-remote.sh` |
| SST repo (remote) | `https://github.com/econ-ark/econ-ark-tools` |
| SST local clone | See `.agents/private/resources-sst.md` in the project root |
