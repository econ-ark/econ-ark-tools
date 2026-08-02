#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if required commands are available
if ! command_exists kpsewhich || ! command_exists bibtool; then
    echo "Error: This script requires kpsewhich and bibtool to be installed."
    exit 1
fi

# Check if the required arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory_path> <texfile>"
    exit 1
fi

dir_path="$1"
texfile="$2"
texfile_noextn="${texfile%.*}"

# Check if the directory exists
if [ ! -d "$dir_path" ]; then
    echo "Error: Directory $dir_path does not exist."
    exit 1
fi

# Change to the specified directory
cd "$dir_path" || exit 1

# Find the system.bib file
syslib=$(kpsewhich system.bib)
if [ -z "$syslib" ]; then
    echo "Warning: system.bib not found. Continuing without it."
    syslib=""
fi

# Find the additional references file
addlib=$(kpsewhich "${texfile_noextn}-Add-Refs.bib")
if [ -z "$addlib" ] || [ ! -s "$addlib" ]; then
    echo "Warning: ${texfile_noextn}-Add-Refs.bib not found or is empty. Continuing without it."
    addlib=""
fi

# Check if the .aux file exists
if [ ! -f "${texfile_noextn}.aux" ]; then
    echo "Error: ${texfile_noextn}.aux not found. Make sure you've compiled your LaTeX document."
    exit 1
fi

# Guard against self-inclusion. The .aux records the PREVIOUS bibliography in
# a \bibdata line (e.g. \bibdata{./HAFiscal}), and "bibtool -x" reads those
# files in addition to the ones named on the command line. Left alone, the old
# ${texfile_noextn}.bib is merged into its own replacement -- every entry comes
# out duplicated. Extract from a sanitized copy of the .aux instead; the
# bibliographies to draw from are passed explicitly below.
auxtmp="$(mktemp -t bibextract-aux)" || exit 1
outtmp="$(mktemp -t bibextract-out)" || exit 1
trap 'rm -f "$auxtmp" "$outtmp"' EXIT
grep -v '^\\bibdata{' "${texfile_noextn}.aux" > "$auxtmp"

# Construct the initial bibtool command
cmd="bibtool -- 'preserve.key.case={on}' -v -x $auxtmp -o $outtmp"

# Add syslib and addlib to the command if they exist and are non-empty
[ -n "$syslib" ] && cmd="$cmd $syslib"
[ -n "$addlib" ] && cmd="$cmd $addlib"

# Print the command
echo "Executing initial extraction command:"
echo "$cmd"

# Execute the command
eval "$cmd"

# Only now overwrite the bibliography, so it is never its own input
mv "$outtmp" "${texfile_noextn}.bib"

# Get the full path of the created .bib file
full_path="$(cd "$(dirname "${texfile_noextn}.bib")" && pwd)/$(basename "${texfile_noextn}.bib")"

echo "Initial bibliography extraction complete."
echo "Output saved to: $full_path"

# Additional bibtool commands
echo "Performing additional processing..."

# Remove specified fields, sort by citation keys, and remove duplicates
# bibtool_cmd="bibtool -r -- 'delete.field = {bdsk-url-1,owner,note,file}' \
#                         -- 'sort = on' \
#                         -- 'sort.format = {%s($key)}' \
#                         -- 'preserve.key.case = on' \
#                         -i $full_path -o $full_path.tmp"

# preserve.key.case MUST be repeated here. bibtool lowercases citation keys by
# default, so without it this reformatting pass silently rewrites Auclert2021
# as auclert2021 -- undoing the setting used during extraction above.
bibtool_cmd="bibtool -- 'preserve.key.case = {on}' -i $full_path -o $full_path.tmp"

echo "Executing additional processing command:"
echo "$bibtool_cmd"

eval "$bibtool_cmd"

# Replace the original file with the processed one
mv "$full_path.tmp" "$full_path"

echo "Additional processing complete."
echo "Final bibliography saved to: $full_path"
