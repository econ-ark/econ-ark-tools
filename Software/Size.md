# ISO Installer Options

Each of the various ways of constructing machines described elsewhere can be done with either a `MIN` or a `MAX` configuration, described below.

Both setups include the econ-ark toolkit and all its dependencies. The difference is in the supplemental resources they contain.

### [XUBUNTARK-MIN](https://drive.google.com/drive/folders/1WVs4TpsMrB8erCIykymzMYmYtxvTjtwk)

Installs miniconda, tex- jupyter lab, Econ-ARK, and not much else. The total size
of the software is about 12 GB, and a minimal so even if you have a fairly small USB
stick (say, 32 GB) you should be able to run Econ-ARK stuff on it.

Installation of this machine should take roughly an hour if you have reasonably
fast internet access.

Even if you plan ultimately to install the MAX version described below, you might
do a "test run" with the MIN version because it is considerably faster.

This verison contains a suite of basic tools that are widely useful. Among these are

	- miniconda
	- texlive-base
	- ssh, vnc, and xrdp

### [XUBUNTARK-MAX](https://drive.google.com/drive/u/5/folders/1FjI6ORW45gNKVpLe_-NuZxF61T4i-0kD)

This machine is created from the XUBUNTARK-MIN machine by executing these steps:

```
cd /var/local
mv .//setup/Size-To-Make-Is-MIN .//setup/Size-To-Make-Is-MAX
sudo finish.sh
```

The result is a machine with a much more expansive set of tools, that should allow you to execute anything available from the Econ-ARK project. In addition to the contents of the MIN distribution, also ncluded are

	- anaconda
	- texlive-full
	- quantecon
	- scipy
	- numpy
	
and a suite of other tools that together construct a machine that should be adequate for a rich variety of tasks for scientific computation. Indeed, the VM can run code (installed) that reproduces the full results of several computational economics papers.

This machine also executes a set of tests of whether it can run a number of examples of the use of the toolkit.

## ISO Installers

There are two versions of the installer ISO:
	1. Internal-Prohibited
	   * This installer should offer you ONLY the option of installing from one external device (USB stick, say, or USB drive) to another external device.
	2. Internal-Allowed
	   * This also permits you to install to a partition on the internal (probably the boot) drive of the machine you are working on.

Internal-Prohibited is safer; it aims to make it impossible for you to wipe out your computer's internal drive.

If you are using the Internal-Allowed version, you should probably repartition your internal drive first, creating a small [ESP partition](https://en.wikipedia.org/wiki/EFI_system_partition) for the boot stuff and a larger partition to contain the linux system. For guides, Google 'How Do I make a Dual Boot machine.'

Once you have created these partitions, you can boot the Install-Allowed USB stick, and make any required changes to the partitioning scheme that you are presented with after the installer has run for a few minutes.

See the [installation guide](https://github.com/econ-ark/econ-ark-tools/tree/master/Machine) for the particular kind of machine you are building.

# Start

The XUBUNTARK machine is set to autologin:
```
   username:econ-ark
   password:kra-noce
```
In the `terminal`in the machine, you should be able to type `jupyter notebook`
   * Navigate to `GitHub/econ-ark/DemARK/Gentle-Intro-To-HARK.ipynb`
   * Open it and start learning!
