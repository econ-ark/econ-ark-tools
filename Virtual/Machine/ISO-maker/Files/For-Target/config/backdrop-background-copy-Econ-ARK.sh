#!/bin/bash
# Put the image in the right places

backdrops=usr/share/xfce4/backdrops
backgrnds=usr/share/backgrounds/xfce

# Two DIFFERENT places for backdrops, depending on xubuntu-core versus xubuntu-desktop

[[ ! -e /$backdrops/Econ-ARK-Logo-1536x768.png ]] && cp /var/local/sys_root_dir/$backdrops/Econ-ARK-Logo-1536x768.*   /$backdrops
[[ ! -e /$backgrnds/Econ-ARK-Logo-1536x768.png ]] && cp /var/local/sys_root_dir/$backgrnds/Econ-ARK-Logo-1536x768.*   /$backgrnds

