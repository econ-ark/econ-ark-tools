#!/bin/bash
# pull the latest @resources and replace local files
# with the same names.  Leave alone any existing files
# that do not have a counterpart in in the upstream

# written by CDC with help of Claude

# Function to print usage information
usage() {
    echo "Usage: $0 [destination_path] [dryrun]"
    echo "  destination_path: Path to update @resources"
    echo "  dryrun: Optional. If set to 'dryrun', perform a dry run without making changes"
    echo
    echo "Example:"
    echo "$0 /Volumes/Data/Papers/BufferStockTheory/BufferStockTheory-Latest [dryrun]"
    exit 1
}

# Portable realpath function
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

# Script initialization
bash_src="$(realpath "$(dirname "$0")")"
root_src="$(dirname "$bash_src")"
dest_path="$(dirname "$root_src")"
base_name="$(basename "$dest_path")"

# An explicitly-passed destination ALWAYS wins. It used to be honoured only when
# the script's grandparent directory happened to be named econ-ark-tools or bin;
# called from anywhere else, an explicit destination argument was silently
# ignored and the script synced its OWN checkout instead -- a no-op that reads
# as success ("No file(s) changed").
if [ $# -gt 0 ]; then
    dest_path="$1"
elif [[ "$base_name" == "econ-ark-tools" ]] || [[ "$base_name" == "bin" ]]; then
    echo
    echo "Script executed directly from econ-ark-tools/"
    echo "or from an interactive shell"
    echo "requires a destination directory as an argument."
    echo
    usage
fi

echo "dest_path=$dest_path"

# GitHub repository URL
repo_url="https://github.com/econ-ark/econ-ark-tools"

# Create and manage temporary directory
tmpdir=$(mktemp -d) || { echo "Failed to create temp dir"; exit 1; }
trap 'rm -rf -- "$tmpdir"' EXIT

# Clone the repository
pushd "$tmpdir" > /dev/null || { echo "Failed to change to temp directory"; exit 1; }
orig_path="$tmpdir/econ-ark-tools"
[[ -d "$orig_path" ]] && rm -rf "$orig_path"
echo "Cloning repository..."
git clone --depth 1 "$repo_url" || { echo "Failed to clone repository"; exit 1; }
popd > /dev/null || { echo "Failed to return to original directory"; exit 1; }

# Prepare destination
[[ ! -d "$dest_path/@resources" ]] && mkdir  "$dest_path/@resources" 
chmod -Rf u+w "$dest_path/@resources" || { echo "Failed to set write permissions"; exit 1; }

# Handle dry run mode
dryrun=''
if [[ $# == 2 ]]; then # second argument
    if [[ $2 == "dryrun" ]]; then
        dryrun='--dry-run' && echo "Running in '--dry-run' mode - no changes will be made" && echo
    fi
fi

# rsync options
opts=(
    --copy-links --recursive --owner --group --human-readable --verbose
    --exclude="'old'" --exclude="'.DS_Store'" --exclude="'auto'" --exclude="'*~'"
    --exclude="*.tmp" 
    --checksum --delete --itemize-changes --out-format="'%i %n%L'"
)

# Check for deletions
cmd_dryrun="rsync --dry-run ${opts[*]} $orig_path/@resources/ $dest_path/@resources/"
echo 'cmd_dryrun='"$cmd_dryrun"

# Capture rsync's own exit status: a failure here (e.g. a dangling symlink under
# --copy-links, which rsync reports as code 23) must not be swallowed by the
# pipeline, or the run reports success having transferred nothing.
dryrun_out="$(eval "$cmd_dryrun")" || {
    echo "ERROR: rsync dry-run failed (exit $?). Aborting without touching $dest_path." >&2
    exit 1
}
deletions="$(printf '%s\n' "$dryrun_out" | grep -i deleting)"

if [[ -n "$deletions" ]]; then
    echo -e "\nThe following files would be deleted:\n$deletions\n"
    if [[ -z "$dryrun" ]]; then
        read -p "Hit return to continue, Ctrl-C to abort" -r
    fi
fi

# Perform rsync
cmd="rsync $dryrun ${opts[*]} $orig_path/@resources/ $dest_path/@resources/"
echo "$cmd"
eval "$cmd" | grep '^>f.*c' | tee >(awk 'BEGIN {printf "\n"}; END { if (NR == 0) printf "\nNo file(s) changed\n\n"; else printf "\nSome file(s) changed\n\n"}')
# PIPESTATUS[0] is rsync's status; the pipeline's own status is grep's, which is
# 1 whenever no file changed and would mask a genuine rsync failure.
rsync_rc=${PIPESTATUS[0]}

# Change target to read-only to remind self that edits should be done upstream
chmod -Rf u-w "$dest_path/@resources"

# Report the failure only after the destination has been left in a sane state.
if [[ $rsync_rc -ne 0 ]]; then
    echo >&2
    echo "ERROR: rsync exited $rsync_rc -- $dest_path/@resources may be incompletely updated." >&2
    echo "       (code 23 = some files/attrs not transferred; a dangling symlink" >&2
    echo "        under --copy-links is the usual cause.)" >&2
    exit "$rsync_rc"
fi

# Ensure temporary directory is removed on script exit
trap 'rm -rf -- "$tmpdir"' EXIT
