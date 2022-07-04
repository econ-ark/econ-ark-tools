# This Volume Has Two Purposes

## Allow Easy Exchange of Files Between Mac and Linux

Macs cannot natively read the Linux filesystem, nor can Linux machines
natively read the MacOS filesystem. 

But both of them can read an HFS+ formatted filesystem (this requires
installation of the hfsplus utility on Linux, but that is automatically
installed by the Econ-ARK installer).

This volume therefore can be used to easily move files between your Mac
and the Linux machine. 

On the Linux VM, you will need to "mount" the drive before you can see it:

`mkdir /media/reFind-HFS; sudo mount -t hfsplus /dev/[device] /media/reFind-HFS`

where `[device]` will be something like `sda2`.

To find the device name, try a commad like 

'''
	sudo sfdisk --list --output Device,Sectors,Size,Type,Name | grep HFS
'''	

## Installing ReFind Boot Manager for MacOS

To boot a Mac machine into Linux, the Mac has to be able to 
"see" the Linux filesystem on a boot drive. 

If you hold the "option" key on your Mac and there is a 
properly formatted EFI System Partition (ESP) on the boot
drive, the Mac will show you something (probably a mysterious
option labeled "EFI Boot") when you boot. 

The ReFind bootloader replaces the MacOS bootloader and shows you
all your booting options when you boot, automatically.

To install ReFind, in a terminal window, just type 

`sudo /Volumes/reFindHFS/refind-install-MacOS.sh` and type your password.

