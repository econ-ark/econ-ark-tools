#!/bin/bash
# Wrapper script to suppress duplicate BibTeX entries in latexmk.

REAL_BIBTEX="/Library/TeX/texbin/bibtex"  # Adjust if `which bibtex` gives something else

output="$($REAL_BIBTEX "$@" 2>&1)"
bibtex_status=$?

# Count total errors and duplicate errors
total_errors=$(echo "$output" | grep -c "^Repeated entry\|^I didn't find\|^I couldn't open" || echo "0")
duplicate_errors=$(echo "$output" | grep -c "^Repeated entry" || echo "0")
real_errors=$((total_errors - duplicate_errors))

# Remove the duplicate-entry error blocks
filtered_output=$(echo "$output" | sed -E '/^Repeated entry/,/^I'"'"'m skipping/ d')

# Fix the error count in the final summary
if [[ "$filtered_output" == *"(There were"*"error messages)"* ]]; then
    if [[ $real_errors -eq 0 ]]; then
        # No real errors - report success
        filtered_output=$(echo "$filtered_output" | sed -E 's/\(There were [0-9]+ error messages\)/(There were 0 error messages)/')
    else
        # Some real errors remain - report the corrected count
        filtered_output=$(echo "$filtered_output" | sed -E "s/\(There were [0-9]+ error messages\)/(There were $real_errors error messages)/")
    fi
fi

echo "$filtered_output"

# Also clean up the .blg file if it exists
# The .blg file has the same name as the .aux file (last argument to bibtex)
blg_file="${!#}.blg"  # Get the last argument and add .blg extension
if [[ -f "$blg_file" && $duplicate_errors -gt 0 ]]; then
    # Create a cleaned version of the .blg file
    temp_blg="${blg_file}.tmp"
    # Remove repeated entry blocks and fix error count
    sed -E '/^Repeated entry/,/^I'"'"'m skipping/ d' "$blg_file" > "$temp_blg"
    
    # Fix the error count in the .blg file if all errors were duplicates
    if [[ $real_errors -eq 0 ]]; then
        sed -E 's/\(There were [0-9]+ error messages\)/(There were 0 error messages)/' "$temp_blg" > "$blg_file"
    else
        sed -E "s/\(There were [0-9]+ error messages\)/(There were $real_errors error messages)/" "$temp_blg" > "$blg_file"
    fi
    
    rm -f "$temp_blg"
fi

# If the only errors were duplicate entries, return 0. Else return BibTeX's original status.
if [[ $bibtex_status -ne 0 ]]; then
    if [[ $duplicate_errors -gt 0 && $real_errors -eq 0 ]]; then
        # Only duplicate errors - treat as success
        exit 0
    else
        # Real errors present - return original status
        exit $bibtex_status
    fi
else
    exit 0
fi
