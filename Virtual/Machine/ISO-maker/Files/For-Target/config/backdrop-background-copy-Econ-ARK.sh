#!/bin/bash
# Put the image in the right places

backdrops=usr/share/xfce4/backdrops
backgrounds=usr/share/backgrounds/xfce

# Two DIFFERENT places for backdrops, depending on xubuntu-core versus xubuntu-desktop

[[ ! -e   /var/local/sys_root_dir/$backdrops/Econ-ARK-Logo-1536x768.png ]] && cp /var/local/sys_root_dir/$backdrops/Econ-ARK-Logo-1536x768.*   /$backdrops
[[ ! -e /var/local/sys_root_dir/$backgrounds/Econ-ARK-Logo-1536x768.png ]] && cp /var/local/sys_root_dir/$backgrounds/Econ-ARK-Logo-1536x768.*   /$backgrounds

