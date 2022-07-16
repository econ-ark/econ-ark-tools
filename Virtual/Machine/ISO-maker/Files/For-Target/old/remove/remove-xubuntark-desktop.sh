#!/bin/bash

sudo apt -y --autoremove purge xfce4-goodies xubuntu-desktop lightdm-gtk-greeter lightdm

# Removing all traces of gdm3 helps prevent the question of
# whether to use lightdm or gdm3
## Purge all packages that depend on gdm3
sudo apt -y purge gnome-shell
sudo apt -y purge gnome-settings-daemon
sudo apt -y purge at-spi2-core
sudo apt -y purge libgdm1
sudo apt -y purge gnome-session-bin
sudo apt -y purge lightdm
sudo apt -y autoremove

# Print everything that requires gdm3
sudo /var/local/check-dependencies.sh gdm3
