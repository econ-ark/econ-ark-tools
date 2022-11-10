#!/bin/bash

# Install Chrome browser 
wget --quiet -O /var/local/status/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt -y install /var/local/status/google-chrome-stable_current_amd64.deb

