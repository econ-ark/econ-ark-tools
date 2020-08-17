# VirtualBox Xubuntu Econ-ARK Virtual Machines

This directory explains how to construct a VirtualBox virtual Linux machine.  That VM can then be used on any computer that can run the VirtualBox software (which is almost all computers today.  In practice, we recommend a machine with at least 8GB of RAM and 2 CPU cores in order for the VM to exhibit decent performance.

Because this installer is based on the Xubuntu distribution of Linux, and also installs the Econ-ARK software, we will call it the 'XUBUNTARK' system.

*  Install VirtualBox on your computer
*  Decide upon a place to store the virtual XUBUNTARK machine(s) you create
   * This space should reliably have at least 64 GB available
   * It can be an external USB stick (this is what I would recommend)
   * If you plan to keep it on your computer's main filesystem:
      * `~/VMs/EconARK` would be a reasonable choice

* Next you must create a "New" empty virtual machine
   * You must choose an operating system for the VM; choose Ubuntu 64-bit
   * This creates a VM that can simulate all of the hardware
   * But the machine is empty -- it's like a PC without any software installed
  
*  Now you have two choices:
   * [XUBUNTARK-MIN.ova](https://drive.google.com/file/d/1FfcQQIAHxlm38ark6GhSfVJfRL2lF4tt/view?usp=sharing): Minimal working system with no extra stuff
   * [XUBUNTARK-MAX.ova](https://drive.google.com/file/d/1HGZbrlamgjOcrQcPjmUyUju97Gm5mHIZ/view?usp=sharing): Richly endowed system with extras
      * (An 'ova' file is a preconfigured virtual machine)
	  * (These two are configured as installers for -MIN and -MAX)
	  
   * The ova files set your VM to boot from an incorprated 'virtual DVD'
      * When the VM is 'booted' from this (attached) DVD, everything is installed
	  * Installation happens mostly by downloading -- it takes a long time!
	  * The 'installer' virtual DVD was created using scripts in [ISO-maker](./ISO-maker)
1. Run VirtualBox, then:
   * New -> (Choose "expert mode" at botom of New dialog box)
      * Name: XUBARK-MIN or XUBARK-MAX
	  * Machine Folder: Where you want it stored (your USB stick; your computer ...)
	  * Type: Linux
	  * Version: Ubuntu (64-bit)
	  * Memory size: 
	      * It is conventional to give your VM half of your RAM
	      * But if you have a 4GB machine, 2GB is not really enough
		  * In this case, you should probably use the [Brain Transplant]() strategy
	  * Choose "Create a virtual hard disk now"
	  * Hit "Create"
   * Disk Configuration
      * Choose VMDK, 
	  * "dynamically allocated" means that the drive is "virtual"
	  * It actually USES only the amount of disk space it needs
	  * So go ahead and give it a virtual "500gb"
   * Under "Settings" you can configure the virtual machine in a few ways
   * I recommend the following:
      * Give it half your system's RAM
	  * Give it half your system's cores (like, on a 4-core machine it gets 2)
	  * Give it 64 MB of video memory
   * Next, from the 'File' menu, choose to [import appliance](./Import-Appliance.png)
   * Choose the `XUBUNTARK-[MIN or MAX].ova` file to import (links above)
   * Click the big green "Start" button in the upper right
   * In a couple of minutes, you will reach a dialog labeled "Partition disks"
       * choose: "Guided - use entire disk"
	   * don't worry, this means the encapsulated "virtual disk" inside the VM
	   * It won't touch your computer's real disk
   * You'll have to confirm this decision in several ways. Do so.

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
   * Navigate to `GitHub/econ-ark/DemARK/Gentle-Intro-To-HARK.ipynb`
   * Open it and start learning!

## Details

The "MAX" machine contains a full installation of Anaconda3, LaTeX,
and other useful tools. The econ-ark toolkit is installed using the
conda installer that comes with Anaconda.  Local copies, that you can
modify, of several repos are installed:

1. DemARK
1. REMARK
1. HARK
