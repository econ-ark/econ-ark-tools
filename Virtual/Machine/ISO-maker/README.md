Contains the scripts and configuration files used to create the ISO

To create the [size] version, copy the finish-[size].sh file to finish.sh and invoke 

	`create-unattended-iso_Econ-ARK-by-size.sh [size]`
	
e.g., to create XUBUNTARK-MIN installer:

'''
	./create-unattended-iso_Econ-ARK-by-size.sh MIN
'''	

PS. The scripts assume that there is a shared folder

	/media/sf_VirtualBox/MIN
	/media/sf_VirtualBox/MAX
	
attached to the creator VM; this is where the ISO will be put in the end.

Other files:

1. ./send-both-To-Google.sh - Constructs both ISOs and sends to Google Drive
1. `Disk` contains resources like icon files for the installer 
1. `Files` is where the various resource files live 
