# How to Transform an Existing Linux Machine

The instructions below should work for transforming an existing Ubuntu Linux installation to the Econ-ARK machine.

The instructions are the same whether the machine being converted is a VM or a Metal machine.

The word _transforming_ is used delibertely: After this procedure, the machine will have been substantially reconfigured. While an attempt is made to preserve most prior configuration settings (rather than just wiping them out), there is no guarantee that anything installed before will continue to work (or even exist). So, if you need to be sure you preserve anything on the machine, you should make a [Backup](https://github.com/econ-ark/econ-ark-tools/blob/master/Software/Backup/README.md).

The safest approach is therefore to start with a 'clean' installation of Ubuntu (version 20.04 or higher) and upgrade it as below. 


## Steps:

* If your machine does not have `git` on it, then install that first:
   ```
   sudo apt -y install git
   ```
* Create a path on which to store the tools:
```
sudo mkdir -p /usr/local/share/data/GitHub/econ-ark
```
* Clone the `econ-ark-tools` repository to the appropriate location:
```
sudo git clone --depth 1 --branch master https://github.com/econ-ark/econ-ark-tools /usr/local/share/data/GitHub/econ-ark/econ-ark-tools
```
* Change to the installed directory and run `late_command.sh`:
```
cd /usr/local/share/data/GitHub/econ-ark/econ-ark-tools
cd ./Virtual/Machine/ISO-maker/Files/For-Target/
sudo ./late_command.sh
```	

The installation should proceed automatically from there.

