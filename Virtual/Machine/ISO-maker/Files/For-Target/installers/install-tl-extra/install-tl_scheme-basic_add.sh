#!/bin/bash

# tug.org/texlive/quickinstall.html

SCRIPT=$(realpath -s "$0")
SCRIPT_DIR="$(dirname "$SCRIPT")"

TEXLIVE_INSTALL_NO_CONTEXT_CACHE=1
NOPERLDOC=1

cd "$SCRIPT_DIR"
# Add the path to tlmgr
/usr/local/texlive/YYYY/bin/$ARCH-linux/tlmgr path add

./install-tl_add-latexmk.sh
./install-tl_add-texliveonfly.sh
./install-tl_add-collection-fontsrecommended.sh
./install-tl_add-ams.sh
