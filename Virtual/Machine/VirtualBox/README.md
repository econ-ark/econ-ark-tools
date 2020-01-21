# VirtualBox Econ-ARK Virtual Machine

This directory contains the code used to create an installer that
creates a richly configured linux virtual machine (VM) that can be run
on any computer that runs the VirtualBox software.  In practice, we
recommend a machine with at least 8GB of RAM and 2 CPU cores in order
for the VM to exhibit decent performance.

Because it is based on the Xubuntu distribution of Linux, we will call
our VM 'XUBUNTARK'

1. Install VirtualBox
1. Create a place on your real computer to host the virtual XUBUNTAR machine
   * ~/VMs/EconARK would be a reasonable choice
1. Download [this]() folder, which contains:
   1. An 'ova' file which is an encapsulated VM machine primed to self-construct
   1. An ISO file that contains the key setup info required to install self-constructing VM
1. Install VirtualBox software on host machine, and run VirtualBox
1. From the 'File' menu, choose to 'import appliance'
   * Choose the XUBUNTARK.ova file to import
1. Set your virtual machine to boot from the virtual CD-ROM ISO file you downloaded earlier
   * [](()
1. Click the big green "Start" button
   * Wait a few hours while the machine sets itself up

Eventually, you should see a window [like this]() which is your XUBUNTARK VM running.

The machine is set to autologin to a user named econ-ark with a password kra-noce

In the `terminal` in the machine, you should be able to type `jupyter notebook`
   * Navigate to `GitHub/DemARK/A-Gentle-Introduction-To-HARK`
   * Open it and start learning!

## Details

The machine contains a full installation of Anaconda3, LaTeX, and other useful tools
The econ-ark toolkit is installed using the conda installer that comes with Anaconda.
Local copies, that you can modify, of several repos are installed

1. DemARK
1. REMARK
1. HARK

