#!/bin/bash

pathToScript=`realpath $(dirname $0)`

cd ~/GitHub/econ-ark/DemARK

set -x ; set -v ; pytest --nbval-lax --ignore=Chinese-Growth.ipynb > "$pathToScript/test_DemARK.log"

