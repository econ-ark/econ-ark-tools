# Brief description of automated backup

When installation of the software finishes, the last thing the install scripts do is to initiate a backup of the pristine newly configured system.

This is done using [timeshift](https://teejeetech.com/timeshift/). 

The default location for the backup is the directory `/timeshift` at the root of the filesystem. 

This is not a great choice because, for example, if the device on which all your work has been done is lost or destroyed or fails, your backup disappears too.

But since there is no universally applicable alternative, this is the default.

The machine will make hourly, daily, and monthly backups of the root filesystem; 
configuration is done either using the GUI app or by modifying the configuration 
file at 

`/etc/timeshift.json`

