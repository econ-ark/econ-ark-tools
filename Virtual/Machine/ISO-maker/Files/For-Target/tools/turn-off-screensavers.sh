#!/bin/bash

# Turn off ALL the possible ways the screen might get locked -- user can restore if desired later
# Need to do this because screensavers interfere with installation process


pkill xfce4-screensaver 

# xfce4-session property /shutdown/LockScreen is one of (far too many) ways to lock the screen
xfconf-query --channel xfce4-session --property /shutdown/LockScreen &> /dev/null # Querying its value gives an error if it does not exist
shutdownLockscreenCode="$?" # get exit code from last command; If it does NOT exist, the code will be NOT be zero
# If lock screen DOES exist set it to false
[[ "$shutdownLockscreenCode" == "0" ]] && xfconf-query --channel xfce4-session --property /shutdown/LockScreen --set false 

# Power manager is another way to lock 
xfce4powermanagerexists="$(xfconf-query --channel xfce4-power-manager --list &>/dev/null)" # Not sure whether it's running now or not
xfce4powermanagerexistsCode="$?" # If exit code is zero, it is running -- so quit it (because it causes crash error if reboot happens while running)
[[ "xfce4powermanagerexistsCode" == "0" ]] && xfce4-power-manager --quit

# Properties can be set even if it is not running     
xfconf-query --channel xfce4-power-manager --create --property /xfce4-power-manager/blank-on-ac --set 9999 # a lot of minutes pre-blank!
xfconf-query --channel xfce4-power-manager --create --property /xfce4-power-manager/lock-screen-suspend-hibernate --set false &>/dev/null 
xfconf-query --channel xfce4-power-manager --create --property /xfce4-power-manager/dpms-enabled                  --set false &>/dev/null 

# Screensaver is a THIRD way to lock the screen
LockScreenExists="$(xfconf-query --channel xfce4-screensaver --property /lock/enabled --set false &>/dev/null)"
lockEnabled="$?" # If it does not exist, create it 
[[ "$lockEnabled" != "0" ]] && xfconf-query --create --channel xfce4-screensaver --property /lock/enabled --type 'bool' --set false
