#!/bin/bash
# Pull down the latest @resources and replace local files
# with the same names.  Leave alone any existing files
# that do not have a counterpart in in the upstream
# written by Claude, edited by CDC

# script should live in the bash dir of the @resources dir

# directory of this script
here="$(realpath $(dirname $0))" # here=/Volumes/Data/Papers/HAFiscal/HAFiscal-Latest

# Set the GitHub repository URL and the desired subdirectory
repo_url="https://github.com/econ-ark/econ-ark-tools.git"

# subdirectory path
repo_subdir="@resources"

repo_url_root="https://github.com/econ-ark/econ-ark-tools"
resources="@resources"
repo_dirpath="$repo_url_root/$resources"

# Set the destination directory on your macOS computer
dest_dir="$here/@resources"

# Change its permissions to allow writing
chmod -Rf u+w "$dest_dir"

# Clone the GitHub repository into the temporary directory
[[ -e /tmp/econ-ark-tools ]] && rm -rf /tmp/econ-ark-tools
git clone --depth 1 "$repo_url" /tmp/econ-ark-tools

# Navigate to the desired subdirectory within the cloned repository
src_dir="/tmp/econ-ark-tools/$repo_subdir" 

# Copy the contents of the subdirectory to the destination directory,
# printing a list of the files that were changed 
#echo rsync -avh --delete --checksum --itemize-changes --out-format='"%i %n%L"' "$(realpath .)" "$dest_dir"
#src_dir="$temp_dir/$repo_subdir"

echo '' ; echo rsync "$src_dir/" "$dest_dir"
echo 'rsync -avh --delete --checksum --itemize-changes --out-format="%i %n%L" "$src_dir/" "$dest_dir"'
rsync --dry-run -avh --delete --exclude='.DS_Store' --exclude='auto' --checksum --itemize-changes --out-format="%i %n%L" "$src_dir/" "$dest_dir"  | grep '^>f.*c' 
say stop
read answer

rsync -avh --delete --checksum --itemize-changes --out-format="%i %n%L" "$src_dir/" "$dest_dir" | grep '^>f.*c' | tee >(awk 'BEGIN {printf "\n"}; END { if (NR == 0) printf "no files were changed\n\n"; else printf "files were changed\n\n"}')

# # Remove the temporary directory
# rm -rf "$temp_dir"

# # Return to the source directory
# popd 

# Change to read-only; edits should be done upstream
chmod u-w "$dest_dir"
