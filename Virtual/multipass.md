# About the multipass option

[canonical multipass](https://multipass.run/docs) is a tool to generate cloud-style Ubuntu VMs quickly on Linux, macOS, and Windows.

These notes will assume that you have installed multipass and have managed to create the default virtual machine (called "primary").

When you have done so, you will have a software daemon running on your computer named `multipassd`. The multipass installer will also have created a default directory somewhere on your computer to store all the virtual machines it creates. Where, exactly, it will put that directory varies depending on what kind of machine you have, and how you configure multipass.

Multipass works by controlling a `hypervisor` on your computer, which is a software tool that lets you create and run virtual machines. One widely available (and free) hypervisor that works on Mac, Windows, and Linux machines is called `VirtualBox.` (Another free cross-platform hypervisor is `qemu`). The remaining instructions will assume you have installed VirtualBox on your computer.

Currently, on MacOS Catalina, the multipass resoruces for VMs created by VirtualBox are in the directory:

	`/private/root/Library/Application Support/multipassd/virtualbox/vault/instances`
	
The component of the path beginning with `multipassd` should be similar on other machines.

The directory `multipassd` in this repo has an identical file structure, at the end of which are `cloud-init` configuration files that instruct multipass how to create the Econ-ARK virtual machine.

There is also a unix script that will produce the right command to create such a VM:

	`./make-instance.sh xub-20p04-MIN` 
	
will produce a command like 

	`multipass launch -vvvv --cpus 2 --disk 64G --mem 4G --name xub-20p04-MIN-cpus2disk64gmem4G --cloud-init ./xub-20p04-MIN.txt --network en0 20.04`
	
Briefly, these options are:

* how many of your computer's cores are allocated to the VM
  * Allocate half of your cores to the VM for adequate performance on both
  * If you want either the VM or the main computer to be faster, allocate more cores to it
* how much of your system RAM to allocate to the VM
  * Again, half is a middling choice 
  * It is probably not wise to attempt running multipass on a machine with less thatn 4G
* how large a 'virtual' filesystem you want to allocate
  * The actual space the VM takes on your computer's drive depends on how much you install on it
  * The `MIN` installation of Econ-ARK takes about 16GB
  * The `MAX` installation takes about 32GB
* the `network` option tells the VM which of your computer's internet devices it can share
  * `en0` usually works for Macs; for other machines, you will need to do your own research
  * You can create the VM without a network option
  * In that case it may not be able to connect to the internet to download the installation stuff
* 20.04 indicates that the system will be be based on Ubuntu release 20.04

	It will take a LONG time for this command to finish creating the machine. Even for the `MIN` machine it might take an hour or more (depending partly on the speed of your internet connection). For the `MAX` machine with a slow internet connection, it might take 6-8 hours (so do it before you go to bed and let it run overnight).
	
	While the software installation continues, you can connect to a unix shell on the machine with the command 
	
	`multipass shell [machine name]`
	
	After a few minutes of preliminary setup, you can monitor the progress of the installation with the command:
	
	`tail --follow /var/local/start-and-finish.log` 

n.b. If you have installed virtualbox on your machine and configured it to be the default hypervisor via the command like (on the Mac):

	`sudo multipass set local.driver=virtualbox` 
	
then you can also connect to the machine by running VirtualBox as the root user:

	`sudo VirtualBox`
