#!/bin/bash

sudo conda install -c conda-forge anaconda-clean
anaconda-clean --yes
rm -Rf /usr/local/anaconda3
