#!/bin/bash
# This script updates a machine made by the ARKINSTALL installer
# to incorporate changes to the "master" install made since the
# local machine's install
# Date of install: 2021-02-02
# Date of updater: 

# Put updates below



sudo conda install anaconda=2021.05
sudo env --name base_2021_05_fresh --clone base

sudo apt-get install ripgrep fd-find

# cd ~/.emacs.d/
# git clone https://github.com/hlissner/doom-emacs
# ~/.emacs.d/bin/doom/install
