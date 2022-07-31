#!/bin/bash

# Restoring from a timeshift backup is tricky
# Here we assume the simplest case:
# 0. The device to be restored to has the same partitioning structure
# 0. That device can boot on its own before the restore
# 0. The target partition has enough space
# 0. There is a 'junk' partition to which unneeded stuff is restored

echo ''
echo 'This script guides you through a manual restore'
echo 'of your system partition to a different device.'
echo ''
echo 'First, launch timeshift as a GUI app'
echo '(hit return when it is up)'
echo ''
read answer
echo 'Now choose a snapshot and click Restore'
echo ''
read answer
echo 'You can restore either the system directory (/)'
echo 'Or the /home directory containing user info'
echo 'Or both.'
echo ''
echo 'First, select the device for the system restore'
echo ''
read answer
echo 'Next, set ANY option containing "boot" to your '
echo 'junk/dummy directory (so the existing boot stuff'
echo 'will not be destroyed)'
echo ''
read answer
echo 'Finally, if you want to restore user directories'
echo 'as well as system ones, leave the /home directory'
echo 'at its default setting "Keep on root path"'
echo ''
echo 'Otherwise (you do not want to resore user data)'
echo 'select your dummy directory as the target'
echo read answer
echo 'Finally, click on the [Advanced Options] button'
echo 'and choose the first partition of the restore device'
echo 'as the location for grub restore'
echo ''
echo 'For example, if your restore device is /dev/sdb'
echo 'then you probably want to choose /dev/sdb1 if that'
echo 'is set up as the boot partition (FAT32, ESP, EFI)'
echo ''
read answer
echo 'Close the advanced options tab, return to the main dialog box,'
echo 'and hit restore. Now wait a long time.'
echo ''
echo 'This script is done'

exit

# CDC setup with two identical USB sticks:
# original (to be restored) on /dev/sda
# backup (from which restore) on /dev/sdb

# Full noninteractive command should be something like:
timeshift --rsync --restore --scripted --yes --grub /dev/sdb1 --snapshot-device /dev/sdb2 --snapshot '2022-07-31 17-15-23' --target /dev/sda2

# Just running timeshift --restore from the CLI will prompt for responses


