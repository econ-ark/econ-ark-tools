# 
Contains the scripts and configuration files used to create the ISO installer

To create the [size] version invoke 

	`create-unattended-iso_Econ-ARK-by-size.sh [size]`
	
e.g., to create XUBUNTARK-MIN installer:

'''
	./create-unattended-iso_Econ-ARK-by-size.sh MIN
'''	

PS. The scripts assume that there are shared folders:

	/media/sf_VirtualBox/ISO-made/econ-ark-tools/{MAX,MIN}
	
attached to the creator VM; this is where the ISO will be put in the end.

* `Files` is where the various resource files live
   * For-ISO: resources for creating the ISO installer
   * For-Target: resources for constructing the Econ-ARK machine
