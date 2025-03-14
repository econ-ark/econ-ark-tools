#!/usr/bin/env bash
# 20241002:
# - add '.} ' and '.) ' as sentencers
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

add_newlines() {
    # Read the input text
    text="$1"

    # Regular expression pattern to match any LaTeX environment or comment
    pattern='(\\begin{.*?}.*?\\end{.*?}|%.*$)'

    # Process each line
    while IFS= read -r line; do
        # Skip lines that begin with '%'
        if [[ $line =~ ^% ]]; then
            printf "%s\n" "$line"
            continue
        fi

        # Extract LaTeX environments and comments from the line
        matches=$(printf "%s" "$line" | sed -n "s/.*\($pattern\).*/\1/p")

        # Replace LaTeX environments and comments with placeholders
        placeholder_line=$(printf "%s" "$line" | sed "s/$pattern/__PLACEHOLDER__/g")

        # Replace sentence endings with newline character
        formatted_line=$(printf "%s" "$placeholder_line" | sed -E "s/([.!?][]?['\"]?[[:blank:]]+)/\1\n/g")

        # Reinsert LaTeX environments and comments back into the formatted line
        while read -r match; do
            formatted_line=${formatted_line/__PLACEHOLDER__/$match}
        done <<< "$matches"

        printf "%s\n" "$formatted_line"
    done <<< "$text"
}

# Debugging line to test the number of arguments
echo "Number of arguments: $#"

# Check if the correct number of arguments is provided
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: $0 <input_file> [output_file]"
    echo "   or: $0 <directory> <filename>"
    exit 1
fi

# Determine if we're dealing with a directory + filename or just a file path
if [ -d "$1" ] && [ $# -eq 2 ]; then
    # First argument is a directory and second is a filename
    dir_path="$1"
    filename="$2"
    
    # Remove trailing slash from directory path if present
    dir_path="${dir_path%/}"
    
    # Combine to form the full input file path
    input_file="$dir_path/$filename"
    
    # Default output file name
    output_file="${input_file%.tex}-sentenced.tex"
elif [ $# -eq 1 ]; then
    # Single argument - treat as input file
    input_file="$1"
    output_file="${input_file%.tex}-sentenced.tex"
else
    # Two arguments - treat as input and output files
    input_file="$1"
    output_file="$2"
fi

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Input file '$input_file' does not exist."
    exit 1
fi

# Read the contents of the input file
text=$(cat "$input_file")

# Process the text
formatted_text=$(add_newlines "$text")

# Write the formatted text to the output file
echo "$formatted_text" > "$output_file"

echo "Input file '$input_file' has been processed and the formatted text has been written to '$output_file'."
