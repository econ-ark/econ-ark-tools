# VirtualBox Xubuntu Econ-ARK Virtual Machine

This directory contains the code used to create an installer that creates a richly configured linux virtual machine (VM) that can be run on any computer that runs the VirtualBox software.  While almost any computer can run VirtualBox, in practice, we recommend a machine with at least 8GB of RAM and 2 CPU cores in order for the VM to exhibit decent performance.

Because it is based on the Xubuntu distribution of Linux, we will call
our VM 'XUBUNTARK'

1. Install VirtualBox
1. Create a place on your real computer to host the virtual XUBUNTAR machine
   * `~/VMs/EconARK` would be a reasonable choice
1. You have two choices:
   * [XUBUNTARK-MIN.ova](https://drive.google.com/open?id=1nU8CE1PtcIljDeaukMWC9efm-Fr3iVKm): No extra stuff
   * [XUBUNTARK-MAX.ova](https://drive.google.com/open?id=1zcur9_-DY-aS48d7onsijJQjyrJqM29B): Useful extras (incl. LaTeX)
   1. An 'ova' file is a preconfigured virtual machine (it cannot be previewed)
      * You can adjust its specs to match your machine's capacity
   1. The VM is set up to boot from an incorprated 'virtual DVD'
      * When the VM is 'booted' from this (attached) DVD, everything is installed
	  * Installation happens mostly by downloading -- it takes a long time!
	  * The ['installer' virtual DVD](https://drive.google.com/drive/folders/1TwBlrw2_bU3--ZvzDtaPQdCHcLuQdb5O?usp=sharing) was created using scripts in [ISO-maker](./ISO-maker)
1. Run VirtualBox, import the VM, and start it:
   * From the 'File' menu, choose to [import appliance](./Import-Appliance.png)
   * Choose the `XUBUNTARK.ova` file to import
   * Click the big green "Start" button

Eventually, you should see a window [like this](./XUBUNTARK-At-Startup.png) which is your XUBUNTARK VM running.
   * It can take a couple of hours
   * Flaky internet connections can stall the process
      * If this happens, choose the 'try again' option

The XUBUNTARK machine is set to autologin:
```
   username:econ-ark
	 password:kra-noce
```
In the `terminal`in the machine, you should be able to type `jupyter notebook`
   * Navigate to `GitHub/DemARK/A-Gentle-Introduction-To-HARK`
   * Open it and start learning!

## Details

The machine contains a full installation of Anaconda3, LaTeX, and other useful tools
The econ-ark toolkit is installed using the conda installer that comes with Anaconda.
Local copies, that you can modify, of several repos are installed:

1. DemARK
1. REMARK
1. HARK
