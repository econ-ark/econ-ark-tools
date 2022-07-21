# Options

Each of the various ways of constructing machines described elsewhere can be done with either a `MIN` or a `MAX` configuration, described below.

Both setups include the econ-ark toolkit and all its dependencies. The difference is in the supplemental resources they contain.

If you install the `MIN` version of the system, you can easily upgrade it to the `MAX` version. From the unix command line:

	`sudo /var/local/finish-MAX-Extras.sh`

## MIN

This verison contains a suite of basic tools that are widely useful. Among these are

	- miniconda
	- texlive-base
	- ssh, vnc, and xrdp

## MAX

This is a much more expansive set of tools, that should allow you to execute anything available from the Econ-ARK project. In addition to the contents of the MIN distribution, also ncluded are

	- anaconda
	- texlive-full
	- quantecon
	- scipy
	- numpy
	
and more.

This machine also executes a set of tests of whether it can run a number of examples of the use of the toolkit.


## ISO Installers

See the [installation guide](https://github.com/econ-ark/econ-ark-tools/blob/master/Virtual/README.md#Size)

# Start

The XUBUNTARK machine is set to autologin:
```
   username:econ-ark
   password:kra-noce
```
In the `terminal`in the machine, you should be able to type `jupyter notebook`
   * Navigate to `GitHub/econ-ark/DemARK/Gentle-Intro-To-HARK.ipynb`
   * Open it and start learning!
