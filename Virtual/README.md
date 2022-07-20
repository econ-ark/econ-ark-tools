# Creating an Econ-ARK Machine (Virtual, Metal, or Hybrid)

You have several options for creating a virtual machine containing the Econ-ARK tools.

### Easiest (But Least Powerful -- For Running Existing Tools)

Install "Docker" on your computer, and follow the instructions in the [Docker](https://github.com/econ-ark/econ-ark-tools/tree/master/Virtual/Docker) directory to create a Docker "container" on your computer

* Docker shares resources with your computer
* Your computer's regular operations will sap the performance of the Docker machine
	
### Somewhat More Powerful 

#### VirtualBox

You can install [VirtualBox](https://virtualbox.org) on your computer, which will allow you to run Linux in a virtual machine encapsulated on your regular hard drive.  This has the advantage of being very safe (the virtual machine is completely contained inside a VirtualBox jail; you have to give it permissions to do anything that affects the rest of your computer). It has the disadvantage, like the Docker solution, of requiring your computer to share its resources.

It also requires a fair bit of configuration, so there is a separate [set 
of instructions](https://github.com/econ-ark/econ-ark-tools/tree/master/Virtual/Machine/VirtualBox)


#### Multipass

Install multipass on your computer, and follow [these instructions](https://github.com/econ-ark/econ-ark-tools/tree/master/Virtual/multipass.md) to create a VM on your computer.

# MIN or MAX

### [XUBUNTARK-MIN](https://drive.google.com/drive/folders/1iPyEwhhrUv1XQfRV7uSjmy5k7_TXsKmM?usp=sharing)

Installs miniconda, tex- jupyter lab, Econ-ARK, and not much else. The total size
of the software is about 12 GB, and a minimal so even if you have a fairly small USB
stick (say, 32 GB) you should be able to run Econ-ARK stuff on it.

Installation of this machine should take roughly an hour if you have reasonably
fast internet access.

Even if you plan ultimately to install the MAX version described below, you might
do a "test run" with the MIN version because it is considerably faster.

### [XUBUNTARK-MAX](https://drive.google.com/drive/folders/1FjI6ORW45gNKVpLe_-NuZxF61T4i-0kD?usp=sharing)

#### Note: The installer will not work on a Windows machine with "secure boot" enabled.  

You may need to either
1. [Disable secure-boot on your machine](https://www.google.com/search?q=how+do+i+disable+secure+boot+in+BIOS); or
1. Seek instructions on the internet for installing Ubuntu on your particular machine
    * Instructions for installing the Econ-ARK flavor of Ubuntu should be the same, except that you will be the XUBUNTARK file you download as described below instead of the file from Ubuntu

(Machines new enough to have secure boot probably are powerful enough to use the [VirtualBox](https://github.com/econ-ark/econ-ark-tools/tree/master/Virtual/Machine/VirtualBox) method)

In addition to the contents of [XUBUNTARK-MIN](#XUBUNTARK-MIN), the MAX version includes a full installation of:

1. Anaconda 3
1. LaTeX
1. QuantEcon
1. scipy

and a suite of other tools that together construct a machine that
should be adequate for a rich variety of tasks for scientific
computation. Indeed, the VM can run code (installed) that reproduces
the full results of several computational economics papers.

This machine is considerably larger, and so will take longer to install, perhaps
several hours.

### Physically connect your computer to the internet

Installation is easiest if your computer is directly plugged into a 
wired ethernet connection. If your only choice is wifi, you will have to
manually configure the wifi setup when the installer fails to autoconfigure
its internet connections

### Boot your computer from the USB stick

1. Macs:
   * Hold the "option" key when the compute is booting
   * Depending on your model, you will see one of
      * "ARKINSTALL"
	  * "EFI BOOT"
   * Pick whichever of these options you see
1. Windows:
   * The steps to boot from an external drive depend on your model
       * There are lots of tutorials on the web
	  
### Do Not Destroy Your Real Computer!

When you boot from the installer USB stick, the first question you are likely to be asked is whether you want to "unmount active partitions." The answer is yes -- the only "active partitions" should be those on the booted USB stick, and you don't want it to write over itself

The next question you will need to answer is where you want to install the system.

There are a number of options, but you should pick "entire disk"

* Don't worry, it won't wipe your computer's drive clean
* Instead it will ASK you which of the available drives you want to use
* One of them should have a name corresponding to the large USB stick. Pick that.
* You will then be asked a couple of further questions
   * Just hit "enter" or choose "yes" repeatedly
* The last question is whether you want to write the new partioning schemes 
  * It will show your USB stick's partitioning scheme
  * It will ALSO show your computer's drive partitioning scheme 
  * Don't worry, it won't actually do anything to your computer's scheme
      * So, say "yes"
		  
### Wait

The installation proceeds in two stages:

1. Constructing the basic Linux operating system and GUI
1. Adding supplemental materials
   * Like Econ-ARK
   
The machine will reboot a couple of times during this process. If necessary, you may need to coax your computer to reboot from the right drive (the new one!)

### Enjoy!

The result should be a fully functional installation of Linux from which you can boot your computer. In fact, on the first boot, it should automatically login as:



    username: econ-ark
    password: kra-noce




PS. Since this username and password are publicly available on the net, you should make sure that you do not store sensitive personal information on the virtual machine.

PPS. In case you are interested, everything needed to make the installer file is contained in the "ISO-maker" directory in Virutal/Machine
