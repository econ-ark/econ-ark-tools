#!/bin/bash
# pull the latest @resources and replace local files
# with the same names.  Leave alone any existing files
# that do not have a counterpart in in the upstream

# written by Claude, edited by CDC

# script lives in the bash dir of the @resources dir
bash_src="$(realpath $(dirname $0))"
root_src="$(realpath $bash_src/..)"

# if this is being run from $targ/@resources/bash:
dest_path="$(dirname $(realpath "$root_src"))" 

# Test if directory of $root_src is 'econ-ark-tools'
if [[ "$(basename $dest_path)"  == "econ-ark-tools" ]]; then
    # Check if an argument is provided
    if [ $# -eq 0 ]; then
	echo 
	echo "Script executed directly from econ-ark-tools/"
	echo "requires a destination directory as an argument."
	echo
	echo 'example:'
	echo "$0" /Volumes/Data/Papers/BufferStockTheory/BufferStockTheory-Latest [dryrun]
	echo 
	exit 1
    else # argument was provided
	dest_path="$1"
    fi
fi

# dest_path=/Volumes/Data/Papers/BufferStockTheory/BufferStockTheory-Latest
# Set the GitHub repository URL and the desired subdirectory
repo_url="https://github.com/econ-ark/econ-ark-tools"

# Clone the GitHub repository into the temporary directory
tmpdir=/tmp ; pushd . ; cd $tmpdir
orig_path=$tmpdir/econ-ark-tools
[[ -d $orig_path ]] && rm -Rf $orig_path
cmd='git clone --depth 1 '"$repo_url"
echo
echo "$cmd"
eval "$cmd"
echo 
popd > /dev/null

# Change dest permissions to allow writing
chmod -Rf u+w "$dest_path"

# Copy the contents of the subdirectory to the destination directory,
# printing a list of the files that were changed 

# Allow running in dryrun mode 
dryrun=''
if [[ $# == 2 ]]; then # second argument
    if [[ $2 == "dryrun" ]]; then
	dryrun='--dry-run' && echo "Running in '--dry-run' mode - no changes will be made" && echo
    fi
fi

echo rsync "$dryrun"           -avh --delete --exclude='old' --exclude='.DS_Store' --exclude='auto' --exclude='*~' --checksum --itemize-changes --out-format="%i %n%L" "$orig_path/@resources/" "$dest_path/@resources/" 
rsync "$dryrun"           -avh --delete --exclude='old' --exclude='.DS_Store' --exclude='auto' --exclude='*~' --checksum --itemize-changes --out-format="%i %n%L" "$orig_path/@resources/" "$dest_path/@resources/" | grep '^>f.*c' | tee >(awk 'BEGIN {printf "\n"}; END { if (NR == 0) printf "\nno file(s) changed\n\n"; else printf "\nsome file(s) changed\n\n"}')

# Change to read-only; edits should be done upstream
chmod -Rf u-w "$dest_path"

exit

# Remove the temporary directory
rm -Rf $tmpdir/econ-ark-tools

