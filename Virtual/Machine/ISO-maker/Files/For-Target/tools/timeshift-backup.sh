#!/bin/bash

sudo apt -y install timeshift
sudo timeshift --create --comments "Backup before installing econ-ark-tools" --tags O
