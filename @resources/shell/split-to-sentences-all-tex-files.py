# This was generated by Claude 3.5 Sonnett as a result of the prompt:
# 'please convert split-to-sentences-all-tex-files.sh to python'
# It has not been tested and may not work
import os
import sys
import subprocess

def process_file(input_file):
    script_dir = os.path.dirname(os.path.abspath(__file__))
    split_to_sentences_script = os.path.join(script_dir, "split-to-sentences.py")
    subprocess.run(["python", split_to_sentences_script, input_file])

def main():
    # Parse command-line options
    all_files = False
    replace_original = False
    args = sys.argv[1:]
    while args:
        if args[0] == "--all":
            all_files = True
            args = args[1:]
        elif args[0] == "--replace":
            replace_original = True
            args = args[1:]
        else:
            break

    # Check if the directory path is provided
    if not args:
        print("Error: Directory path not provided.")
        print("Usage: python split-to-sentences-all-tex-files.py [--all] [--replace] <dir_path> [filename.tex]")
        sys.exit(1)

    # Get the directory path and filename (if provided)
    dir_path = args[0]
    filename = args[1] if len(args) > 1 else None

    # Check if the directory path exists
    if not os.path.isdir(dir_path):
        print(f"Error: Directory path '{dir_path}' does not exist.")
        sys.exit(1)

    # Change to the directory
    os.chdir(dir_path)

    if all_files:
        # Process all .tex files in the directory
        tex_files = [file for file in os.listdir() if file.endswith(".tex")]
        if not tex_files:
            print("No .tex files found in the directory.")
            sys.exit(0)
        for file in tex_files:
            print(f"Processing file: {file}")
            process_file(file)
            if replace_original:
                os.rename(file, f"{os.path.splitext(file)[0]}-unsentenced.tex")
                os.rename(f"{os.path.splitext(file)[0]}-sentenced.tex", file)
            print(f"Processed file saved as: {os.path.splitext(file)[0]}-sentenced.tex")
            print("------------------------")
        print("All .tex files in the directory have been processed.")
    else:
        # Check if the filename is provided
        if not filename:
            print("Error: Filename not provided.")
            print("Usage: python split-to-sentences-all-tex-files.py [--all] [--replace] <dir_path> [filename.tex]")
            sys.exit(1)

        # Check if the file exists
        if not os.path.isfile(filename):
            print(f"Error: File '{filename}' does not exist in the directory.")
            sys.exit(1)

        # Process the specified file
        print(f"Processing file: {filename}")
        process_file(filename)
        if replace_original:
            os.rename(filename, f"{os.path.splitext(filename)[0]}-unsentenced.tex")
            os.rename(f"{os.path.splitext(filename)[0]}-sentenced.tex", filename)
        print(f"Processed file saved as: {os.path.splitext(filename)[0]}-sentenced.tex")

if __name__ == "__main__":
    main()
    