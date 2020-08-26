# Welcome to the Econ-ARK Xubuntu Virtual Machine

## (='XUBUNTARK-MIN')

This VM contains all the software necessary to use all parts of the Econ-ARK toolkit.

Configuration details:

1. The screensaver and lock-screen features are turned off by default
   * Fix this, if desired, using the control panel at the upper left
   
Several tools for communicating with the VM are installed

1. An ssh server is installed and operating
   * You should be able to connect via a command like:
      * `ssh econ-ark@[your-VM-IP-Address]` using the usual password
1. There is a [vnc](https://en.wikipedia.org/Virtual\_Network\_Computing) server installed and operating 
   * This enables viewing the VM's screen from another computer 
   * You will need VNC viewer client software to do so 
   * You can disable the VNC viewer (for security):
      * Comment out the first couple of lines of `/home/econ-ark/.bash_aliases`
1. The `avahi` networking software is also installed
   * This makes it easy to start an ssh shell from a Mac on the network

The ISO installer file that creates this machine is in the /media directory.
To install to another drive/USB-stick:
   1. "Burn" the ISO image to an installer location 
   1. Boot your computer from the "burned" installer
   1. Choose the new medium on which you want to install XUBUNTARK

For further information, see [econ-ark-tools](https://github.com/econ-ark/econ-ark-tools/tree/master/Virtual#most-powerful)
