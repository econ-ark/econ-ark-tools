#!/bin/bash
# pull the latest @resources and replace local files
# with the same names.  Leave alone any existing files
# that do not have a counterpart in in the upstream

# written by Claude, edited by CDC

# realpath is not built-in for all distos; substitute this
# (thanks Claude!)
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

# script lives in the bash dir of the @resources dir
bash_src="$(realpath $(dirname $0))"
echo bash_src="$bash_src"

root_src="$(dirname $bash_src)"
echo root_src="$root_src"

# if this is being run from $targ/@resources/bash:
dest_path="$(dirname $root_src)" 
echo 'dest_path='$dest_path

base_name="$(basename $dest_path)"

# Test if directory of $root_src is 'econ-ark-tools'
if ([[ "$base_name"  == "econ-ark-tools" ]] || [[ "$base_name" == "bin" ]]); then
    # Check if an argument is provided
    if [ $# -eq 0 ]; then
	echo 
	echo "Script executed directly from econ-ark-tools/"
	echo "or from an interactive shell"
	echo "requires a destination directory as an argument."
	echo
	echo 'example:'
	echo "$0" /Volumes/Data/Papers/BufferStockTheory/BufferStockTheory-Latest [dryrun]
	echo 
	exit 1
    else
	dest_path="$1"
	echo 'argument was provided:dest_path='"$dest_path"
    fi
fi

echo dest_path="$dest_path"

# dest_path=/Volumes/Data/Papers/BufferStockTheory/BufferStockTheory-Latest
# Set the GitHub repository URL and the desired subdirectory
repo_url="https://github.com/econ-ark/econ-ark-tools"

# Clone the GitHub repository into the temporary directory

## Create a temporary directory
tmpdir=$(mktemp -d)
if [[ ! "$tmpdir" || ! -d "$tmpdir" ]]; then
    echo "Could not create temp dir"
    exit 1
fi

## Clone the repo in tmpdir then restore path
pushd . ; cd $tmpdir
orig_path=$tmpdir/econ-ark-tools
[[ -d $orig_path ]] && rm -Rf $orig_path
cmd='git clone --depth 1 '"$repo_url"
echo
echo "$cmd"
eval "$cmd"
echo 
popd > /dev/null

# Change dest permissions to allow writing
echo chmod -Rf u+w "$dest_path/@resources"
chmod -Rf u+w "$dest_path/@resources"

# Copy the contents of the subdirectory to the destination directory,
# printing a list of the files that were changed 

# Allow running in dryrun mode 
dryrun=''
if [[ $# == 2 ]]; then # second argument
    if [[ $2 == "dryrun" ]]; then
	dryrun='--dry-run' && echo "Running in '--dry-run' mode - no changes will be made" && echo
    fi
fi


if [[ "$dryrun" != "dryrun" ]]; then # they did not ask for a dry run
    echo nodryrun
fi

cmd='rsync '"$dryrun"' --copy-links --recursive --perms --owner --group --human-readable --verbose --delete --exclude="'"old"'" --exclude='".DS_Store"' --exclude='"auto"' --exclude="'"*~"'" --checksum --itemize-changes --out-format='"'%i %n%L'"' '"$orig_path/@resources/"' '"$dest_path/@resources/"''
opts='--copy-links --recursive --perms --owner --group --human-readable --verbose --delete --exclude="'"old"'" --exclude='".DS_Store"' --exclude='"auto"' --exclude="'"*~"'" --checksum --itemize-changes --out-format='"'%i %n%L'"''
dirs='"$orig_path/@resources/"' '"$dest_path/@resources/"'
comb='rsync '"$dryrun"' '"$opts"' '"$dirs"

echo "$cmd"
#eval "$cmd"

# Change to read-only; edits should be done upstream
chmod -Rf u-w "$dest_path/@resources"

# Ensure temporary directory is removed on script exit
trap 'rm -rf -- "$tmpdir"' EXIT


