#!/bin/bash

pathToScript=`realpath $(dirname $0)`

cd ~/GitHub/econ-ark/HARK

set -x ; set -v ; pytest > "$pathToScript/test_HARK.log"

