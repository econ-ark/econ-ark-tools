# VirtualBox Xubuntu Econ-ARK Virtual Machines

This directory explains how to construct a VirtualBox virtual Linux machine.  (See [here](https://github.com/econ-ark/econ-ark-tools/tree/master/Virtual/Machine) for instructions to construct a bootable Econ-ARK drive that takes over all your comptuer's hardware).

That VM can then be used on any computer that can run the VirtualBox software (which is almost all computers today).  In practice, we recommend a machine with at least 8GB of RAM and 4 CPU cores in order for the VM to exhibit decent performance.

Because this installer is based on the Xubuntu distribution of Linux, and also installs the Econ-ARK software, we will call it the 'XUBUNTARK' system.

*  Install VirtualBox on your computer
*  Decide upon a place to store the virtual XUBUNTARK machine(s) you create
   * This space should reliably have at least 64 GB available
      * That may mean it should be a separate partition/volume on your drive
   * It can be an external USB stick (this is what I would recommend)
   * If you (unwisely) plan to keep it on your computer's main filesystem:
      * `~/VMs/EconARK` would be a reasonable choice

* Next you must create a "New" empty virtual machine
   * You must choose an operating system for the VM; choose Ubuntu 64-bit
   * This creates a VM that can simulate all of the hardware
   * But the machine is empty -- it's like a PC without any software installed

1. Download the installer ISO installer image per the [instructions above](https://github.com/econ-ark/econ-ark-tools/tree/master/Virtual/Machine)
   * Your VirtualBox virtual machine will boot from this as a virtual CD-ROM
1. Run VirtualBox, then:
   * New -> (Choose "expert mode" at botom of New dialog box)
      * Name: XUBARK-MIN or XUBARK-MAX
	  * Machine Folder: Where you want it stored (your USB stick; your computer ...)
	  * Type: Linux
	  * Version: Ubuntu (64-bit)
	  * Memory size: 
	      * It is conventional to give your VM half of your RAM
	      * But if you have a 4GB machine, 2GB is not really enough
		  * In this case, you should probably use the [Brain Transplant](https://github.com/econ-ark/econ-ark-tools/tree/master/Virtual/Machine) strategy
	  * Choose "Create a virtual hard disk now"
	  * Hit "Create"
   * Disk Configuration
      * Choose VMDK, 
	  * "dynamically allocated" means that the drive is "virtual"
	  * It actually USES only the amount of disk space it needs
	  * So go ahead and give it a virtual "500gb"
   * Under "Settings/System" you can configure the virtual machine in a few ways
   * I recommend the following:
      * Give it half your system's RAM
	  * Give it half your system's cores (like, on a 4-core machine it gets 2)
   * Under "Settings/Display" give it it 64 MB of video memory
   * Under "Settings/Storage/Controller:IDE" click "Empty"
      * Click the image of a CD-ROM on the right of "Optical Drive"
	  * Navigate to the ISO file you downloaded earlier and attach it
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
