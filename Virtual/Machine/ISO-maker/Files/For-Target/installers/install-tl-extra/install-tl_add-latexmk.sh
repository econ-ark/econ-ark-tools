#!/bin/bash

# github.com/dhnza/latex_slim_docker/blob/master/Dockerfile

# texliveonfly is not relocatable so cannot install in user mode
cmd="sudo tlmgr install latexmk"
echo '' ; echo '' ; echo $cmd ; echo '' ; echo ''
eval "$cmd"



