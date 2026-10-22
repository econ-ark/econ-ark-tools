#!/usr/bin/env bash
#
# bibtex_wrapper.sh
#
# PURPOSE:
#   This script acts as a wrapper around the real `bibtex` command. It is
#   designed to solve a specific, notorious problem with `latexmk`: `latexmk`
#   will often halt compilation if it sees "Repeated entry" warnings in
#   BibTeX's output, even if these warnings are harmless.
#
#   This wrapper intercepts the output from BibTeX. If the *only* issues are
#   "Repeated entry" warnings, it completely suppresses them and reports a
#   clean success (exit code 0) to `latexmk`. It does this by filtering the
#   console output and rewriting the .blg log file to remove all traces of
#   the duplicate entry warnings.
#
#   If any other, more serious errors are detected (e.g., missing database
#   files, undefined citations), it passes them through, ensuring that
#   genuine problems are still reported.
#
# USAGE:
#   Called automatically by a latexmkrc file configured to use it as the
#   `$bibtex` command.
# ---

# --- CONFIGURATION ---
# Find the full path to the bibtex executable.
# Using `command -v` is a robust, POSIX-compliant way to find an executable in the PATH.
REAL_BIBTEX_CMD=$(command -v bibtex)

# Check if bibtex was found. If not, exit with an informative error.
if [ -z "$REAL_BIBTEX_CMD" ]; then
    echo "FATAL ERROR: 'bibtex' command not found in your system's PATH." >&2
    echo "Please ensure a TeX distribution is installed and its 'bin' directory is in your PATH." >&2
    exit 1
fi

# --- EXECUTION ---

# The last argument passed to this script is the basename of the .aux file.
# Portable "last argument": the wrapper is invoked as `sh <wrapper> %O %B` (latexmkrc_using_bibtex_wrapper),
# and on Debian/Ubuntu `sh` is dash, where the bash-only indirect expansion "${!#}" expands to NOTHING (no
# error). BASENAME_ARG was then empty, so the .blg sanitization below never ran and latexmk's own .blg scan
# ("There were N error messages") failed the build on every "Repeated entry". macOS `sh` is bash in POSIX
# mode, which is why it never bit there. Fixed 2026-09-09 (found in llorracc/HAFiscal-Latest on Linux).
for BASENAME_ARG in "$@"; do :; done

# Run the real bibtex command, capturing all stdout and stderr into a variable.
BIBTEX_OUTPUT="$("$REAL_BIBTEX_CMD" "$@" 2>&1)"
BIBTEX_EXIT_CODE=$?

# --- ANALYSIS ---

# Count the number of "Repeated entry" warnings.
# The `grep -c` command counts matching lines.
REPEATED_ENTRY_COUNT=$(echo "$BIBTEX_OUTPUT" | grep -c "^Repeated entry" || true)

# Count critical errors that should always halt the build.
MISSING_ENTRY_COUNT=$(echo "$BIBTEX_OUTPUT" | grep -c "^I didn't find a database entry" || true)
FILE_NOT_FOUND_COUNT=$(echo "$BIBTEX_OUTPUT" | grep -c "^I couldn't open file" || true)

# Sum up the critical errors.
CRITICAL_ERROR_COUNT=$((MISSING_ENTRY_COUNT + FILE_NOT_FOUND_COUNT))

# --- DECISION ---

# If we only have repeated entries and no critical errors, we will simulate success.
# POSIX test, not bash's [[ ]]: latexmk runs this as `sh <wrapper>`, and dash (Debian/Ubuntu's sh) fails on
# "[[" ("not found"), so the condition was false and every "Repeated entry" still failed the build there.
if [ "$REPEATED_ENTRY_COUNT" -gt 0 ] && [ "$CRITICAL_ERROR_COUNT" -eq 0 ]; then

    # 1. Filter the console output to remove the repeated entry warnings.
    #    The `sed` command deletes the entire block of a repeated entry warning.
    #    Also remove the "(There was X error message)" line that appears at the end.
    echo "$BIBTEX_OUTPUT" | sed -E '/^Repeated entry/,/^I.m skipping/ d; s/^\((There (was [0-9]+ error message|were [0-9]+ error messages))\)$//'

    # 2. Rewrite the .blg file to remove any trace of the warnings for latexmk.
    BLG_FILE="${BASENAME_ARG}.blg"
    if [ -f "$BLG_FILE" ]; then
        # Create a temporary file for the cleaned content.
        TEMP_BLG_FILE="${BLG_FILE}.tmp"
        # Use sed to filter the original .blg file.
        # Remove repeated entry warnings and the error message count line.
        sed -E '/^Repeated entry/,/^I.m skipping/ d; s/^\((There (was [0-9]+ error message|were [0-9]+ error messages))\)$//' "$BLG_FILE" > "$TEMP_BLG_FILE"
        # Replace the original with the cleaned version.
        mv "$TEMP_BLG_FILE" "$BLG_FILE"
    fi

    # 3. Exit with success code 0, telling latexmk to proceed.
    exit 0

else
    # Otherwise, real errors occurred. Pass through the original output and exit code.
    echo "$BIBTEX_OUTPUT"
    exit $BIBTEX_EXIT_CODE
fi 