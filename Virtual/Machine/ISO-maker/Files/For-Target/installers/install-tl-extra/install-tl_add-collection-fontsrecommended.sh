#!/bin/bash

# github.com/dhnza/latex_slim_docker/blob/master/Dockerfile

# Add all the ams packages to the usertree
cmd="tlmgr install "$TEXMFHOME" collection-fontsrecommended"
echo '' ; echo '' ; echo $cmd ; echo '' ; echo ''
eval "$cmd"


