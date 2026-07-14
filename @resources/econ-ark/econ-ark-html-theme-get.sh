#!/bin/bash

theme=econ-ark-html-theme
# shellcheck disable=SC2046  # this only builds a printed suggestion string, not an executed command
echo curl "https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Web/Styling/REMARKs-HTML/$theme.css" -o "'"$(dirname "$0")/$theme.css"'"

