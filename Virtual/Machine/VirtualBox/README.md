# VirtualBox XUBUNTARK Linux machine.

An advantage of a VirtualBox VM is that it can be used on any computer that can run the VirtualBox software (which is almost all computers today). The SAME image can be run on a Win, Mac, or Linux machine.

We recommend a machine with at least 8GB of RAM and 4 CPU cores.

*  Install VirtualBox on your computer (Google it)
*  Decide upon a place to store the virtual XUBUNTARK machine(s) you create
   * This space should reliably have at least 64 GB available
      * This should probably be an external USB stick or drive
   * If you (unwisely) plan to keep it on your computer's main filesystem:
      * `~/VMs/EconARK` would be a reasonable choice

* Next you must create a "New" empty virtual machine
   * You must choose an operating system for the VM; choose Ubuntu 64-bit
   * This creates a VM that can simulate all of the hardware
   * But the machine is empty -- it's like a PC without any software installed

1. [Download an installer ISO installer image](https://github.com/econ-ark/econ-ark-tools/master/Software/Size.md)
   * Your VirtualBox virtual machine will boot from this as a virtual CD-ROM
1. Run VirtualBox, then:
   * New -> (Choose "expert mode" at botom of New dialog box)
      * Name: XUBARK
	  * Machine Folder: Where you want it stored (your USB stick; your computer; ...)
	  * Type: Linux
	  * Version: Ubuntu (64-bit)
	  * Memory size: 
	      * It is conventional to give your VM half of your RAM
	      * But if you have a 4GB machine, 2GB is not really enough
		  * In this case, you should probably use the [Brain Transplant (Metal)](https://github.com/econ-ark/econ-ark-tools/tree/master/Virtual/Machine/Metal) strategy
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

Eventually, you should see a window [like this](https://github.com/econ-ark/econ-ark-tools/tree/master/Software/XUBUNTARK-At-Startup.png) which is your XUBUNTARK VM running.

* It can take a couple of hours
   * Flaky internet connections can stall the process
      * If this happens, choose the 'try again' option

* See next steps [at the bottom here](https://github.com/econ-ark/econ-ark-tools/tree/master/Software/Size.md)
