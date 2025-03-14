#!/usr/bin/env bash

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
# Function to process a single file
process_file() {
    input_file="$1"
    python "$script_dir/split-to-sentences.py" "$input_file"

    # Compare the contents of the original file and the 'sentenced' file
    if cmp -s "$input_file" "${input_file%.tex}-sentenced.tex"; then
        # If the files are identical, remove the 'sentenced' file
        rm "${input_file%.tex}-sentenced.tex"
        echo "No changes made to file: $input_file"
    else
        echo "Processed file saved as: ${input_file%.tex}-sentenced.tex"
    fi
}

# Get the directory of the Bash script
script_dir="$(dirname "$0")"

# Check if the split-to-sentences.py script exists in the same directory as the Bash script
if [ ! -f "$script_dir/split-to-sentences.py" ]; then
    echo "Error: split-to-sentences.py script not found in the same directory as the Bash script."
    exit 1
fi

# Make sure the split-to-sentences.py script is executable
chmod +x "$script_dir/split-to-sentences.py"

# Parse command-line options
all_files=false
replace_original=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --all)
            all_files=true
            shift
            ;;
        --replace)
            replace_original=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

# Check if the directory path is provided
if [ $# -eq 0 ]; then
    echo "Error: Directory path not provided."
    echo "Usage: $0 [--all] [--replace] <dir_path> [filename.tex]"
    exit 1
fi

# Get the directory path and filename (if provided)
dir_path="$1"
filename="$2"

# Check if the directory path exists
if [ ! -d "$dir_path" ]; then
    echo "Error: Directory path '$dir_path' does not exist."
    exit 1
fi

# Change to the directory
cd "$dir_path" || exit

# If no filename is provided, process all files in the directory (same as --all flag)
if [ -z "$filename" ]; then
    all_files=true
fi

if $all_files; then
    # Process all .tex files in the directory
    tex_files=(*.tex)
    if [ ${#tex_files[@]} -eq 0 ]; then
        echo "No .tex files found in the directory."
        exit 0
    fi
    for file in "${tex_files[@]}"; do
        echo "Processing file: $file"
        process_file "$file"
        if $replace_original && [ -f "${file%.tex}-sentenced.tex" ]; then
            mv "$file" "${file%.tex}-unsentenced.tex"
            mv "${file%.tex}-sentenced.tex" "$file"
        fi
        echo "------------------------"
    done
    echo "All .tex files in the directory have been processed."
else
    # Check if the file exists
    if [ ! -f "$filename" ]; then
        echo "Error: File '$filename' does not exist in the directory."
        exit 1
    fi

    # Process the specified file
    echo "Processing file: $filename"
    process_file "$filename"
    if $replace_original && [ -f "${filename%.tex}-sentenced.tex" ]; then
        mv "$filename" "${filename%.tex}-unsentenced.tex"
        mv "${filename%.tex}-sentenced.tex" "$filename"
    fi
fi
