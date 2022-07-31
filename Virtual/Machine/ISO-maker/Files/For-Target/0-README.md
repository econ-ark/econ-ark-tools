# Create Econ-ARK Machine Using Scripts

The scripts herein are designed to be run on a standard
Ubuntu/Debian Linux machine. They will add to that machine
all the components necessary to turn it into an Econ-ARK
machine.

This may wipe out some of the existing configuration settings
of the machine, so if you want to preserve your existing settings
you should do a backup before running these scripts. 

A script that makes a ['timeshift'](https://teejeetech.com/timeshift/) backup is

```
./tools/timeshift-backup.sh
```

and if you run it using `sudo /var/local/tools/timeshift-backup.sh` it will create
a system backup in the root directory at `/timeshift`

After that, you should be able to do the conversion by running:

```
sudo ./late_command.sh
```

from the the directory in which this README is located.

