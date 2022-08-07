# Detailed Info About This Installation

This machine (virtual or real) was built using 

https://github.com/econ-ark/econ-ark-tools.git

using scripts in commit d8a087c2 
with commit message "add_timestamp_to_initial_backup"
on date "20220806-1720"

Starting at the root of a cloned version of that repo,
you should be able to reproduce the installer with:

    git checkout d8a087c2
    cd Virtual/Machine/ISO-maker ; ./create-unattended-iso_Econ-ARK-by-size.sh [ MIN | MAX ]

A copy of the ISO installer that generated this machine should be in the

    /installers

directory.

