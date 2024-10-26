#!/bin/bash

# Process the file:
# 1. Remove lines starting with %
# 2. Replace \providecommand with \newcommand
# 3. Write to new file
sed '/^%/d' ../texlive/texmf-local/tex/latex/econark-shortcuts.sty | \
    sed 's/\\providecommand/\\newcommand/g' | \
    sed 's/\\boldsymbol{\\mathit{/\\pmb{/g' > ../markdown/econark-shortcuts.md

