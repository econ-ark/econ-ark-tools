#!/bin/bash

pathToScript=`realpath $(dirname $0)`

cd ~/GitHub/econ-ark/DemARK

set -x ; set -v ; pytest > "$pathToScript/test_DemARK.log"

