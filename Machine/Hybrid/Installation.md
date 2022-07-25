# How to Convert an Existing Linux Machine

The instructions below should work for converting an existing Ubuntu Linux machine to the Econ-ARK machine.

The instructions are the same whether the machine being converted is a VM or a Metal machine.

The word _converting_ is used delibertely: After this procedure, the machine will have been substantially reconfigured. While an attempt is made to preserve most prior configuration settings (rather than just wiping them out), there is no guarantee that anything installed before will continue to work.

The safest approach is therefore to start with a `clean' installation of Ubuntu (version 20.04 or higher) and upgrade it as below. 

<script type="module" src="./node_modules/@github/clipboard-copy-element/dist/index.js">

Steps:

0. If your machine does not have `git` on it, then install that first:
   `sudo apt -y install git`
0. Clone the `econ-ark-tools` repository to the appropriate location:
``` 
mkdir /usr/local/share/data/GitHub/econ-ark
sudo git clone --depth 1 --branch Make-Installer-ISO-WORKS https://github.com/econ-ark/econ-ark-tools /usr/local/share/data/GitHub/econ-ark/econ-ark-tools
```
0. Change to the installed directory and run `late_command.sh`:
```
	cd /usr/local/share/data/GitHub/econ-ark/econ-ark-tools
	cd ./Virtual/Machine/ISO-Maker/Files/For-Target/
	sudo ./late_command.sh
```

The installation should proceed automatically from there.

