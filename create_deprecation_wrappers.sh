#!/usr/bin/env bash

# This script generates deprecation wrappers for scripts.
# It ensures that any call to a script via a deprecated path
# ('bash' or 'shell') will issue a warning and then execute the real script.

set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
# The canonical directory where your scripts actually live.
REAL_SCRIPTS_DIR="@resources/scripts"

# A list of the deprecated directories that should point to the real one.
DEPRECATED_DIRS=("@resources/bash" "@resources/shell")

# --- Logic ---
echo "Starting deprecation wrapper generation..."

# Loop through each of the deprecated directory paths.
for DEP_DIR in "${DEPRECATED_DIRS[@]}"; do
  echo "Processing deprecated directory: $DEP_DIR"

  # Ensure the deprecated directory exists and is empty.
  # This is safe now because the real scripts have been moved.
  rm -rf "$DEP_DIR"
  mkdir -p "$DEP_DIR"

  # Find every file in the real scripts directory.
  for REAL_SCRIPT_PATH in "$REAL_SCRIPTS_DIR"/*; do
    
    # Get just the filename of the script.
    SCRIPT_NAME=$(basename "$REAL_SCRIPT_PATH")
    
    # The full path for the new wrapper script we're creating.
    WRAPPER_PATH="$DEP_DIR/$SCRIPT_NAME"

    echo "  -> Creating wrapper for $SCRIPT_NAME in $DEP_DIR"

    # Create the wrapper file.
    cat > "$WRAPPER_PATH" <<EOF
#!/bin/sh
# DEPRECATION WRAPPER - DO NOT EDIT

# This is an auto-generated wrapper. Its purpose is to warn that the path
# used to call this script is deprecated and will be removed in the future.

# The real location of the scripts.
CANONICAL_PATH="\$(dirname "\$0")/../scripts/$SCRIPT_NAME"

# Print a warning message to standard error.
echo "
********************************************************************************
*** DEPRECATION WARNING ***
* You have accessed a script via the path: '$DEP_DIR'
* This path is deprecated and will be removed in a future version.
* Please update your code/configuration to use the canonical path: '$REAL_SCRIPTS_DIR'
********************************************************************************
" >&2

# Execute the *real* script, passing along all command-line arguments.
exec "\$CANONICAL_PATH" "\$@"
EOF

    # Make the newly created wrapper script executable.
    chmod +x "$WRAPPER_PATH"
  done
done

echo "Wrapper generation complete."
