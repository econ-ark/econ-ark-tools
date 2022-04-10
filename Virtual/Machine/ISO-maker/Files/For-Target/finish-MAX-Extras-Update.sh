#!/bin/bash
# This script updates a machine made by the ARKINSTALL installer
# to incorporate changes to the "master" install made since the
# local machine's install
# Date of install: 2021-02-02
# Date of updater: 

# Put updates below



sudo conda -y install anaconda=2021.05
sudo env --name base_2021_05_fresh --clone base

sudo apt -y install ripgrep fd-find
sudo apt -y install flatpak
sudo apt -y install gnome-software-plugin-flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak -y install flathub org.gnu.emacs

sudo apt -y install backintime-qt4
sudo apt -y install timeshift

# cd ~/.emacs.d/
# git clone https://github.com/hlissner/doom-emacs
# ~/.emacs.d/bin/doom/install
