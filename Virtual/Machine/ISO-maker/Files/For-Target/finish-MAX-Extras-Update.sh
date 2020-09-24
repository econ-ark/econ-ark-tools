#!/bin/bash
# This script updates a machine made by the ARKINSTALL installer
# to incorporate changes to the "master" install made since the
# local machine's install
# Date of install: 2020-09-08
# Date of updater: 2020-09-24

cd /usr/local/share/data/GitHub/econ-ark/HARK          ; pip install -r requirements.txt

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh



