# Creating an Econ-ARK Virtual Machine

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

## [ISO-Installers](https://github.com/econ-ark/econ-ark-tools/blob/master/Software/Size.md)

### Physically connect your computer to the internet

Installation is easiest if your computer is directly plugged into a wired ethernet connection. If your only choice is wifi, you will have to manually configure the wifi setup when the installer fails to autoconfigure its internet connections. If it tries to autoconfigure without asking you for WiFi info, a wired internet connection may be required.
		  
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
