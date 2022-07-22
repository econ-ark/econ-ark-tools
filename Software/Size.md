# ISO Installer Options

Each of the various ways of constructing machines described elsewhere can be done with either a `MIN` or a `MAX` configuration, described below.

Both setups include the econ-ark toolkit and all its dependencies. The difference is in the supplemental resources they contain.

If you install the `MIN` version of the system, you can easily upgrade it to the `MAX` version. From the unix command line:

	`sudo /var/local/finish-MAX-Extras.sh`

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

This machine is considerably larger, and so will take longer to install, perhaps
several hours.

This is a much more expansive set of tools, that should allow you to execute anything available from the Econ-ARK project. In addition to the contents of the MIN distribution, also ncluded are

	- anaconda
	- texlive-full
	- quantecon
	- scipy
	- numpy
	
and a suite of other tools that together construct a machine that should be adequate for a rich variety of tasks for scientific computation. Indeed, the VM can run code (installed) that reproduces the full results of several computational economics papers.

This machine also executes a set of tests of whether it can run a number of examples of the use of the toolkit.

<<<<<<< HEAD
=======

## ISO Installers

See the [installation guide](https://github.com/econ-ark/econ-ark-tools/blob/master/Virtual/README.md#Size)

# Start

>>>>>>> 6cd1bdd1699cb280302d52d0daff3248563e008e
The XUBUNTARK machine is set to autologin:
```
   username:econ-ark
   password:kra-noce
```
In the `terminal`in the machine, you should be able to type `jupyter notebook`
   * Navigate to `GitHub/econ-ark/DemARK/Gentle-Intro-To-HARK.ipynb`
   * Open it and start learning!
