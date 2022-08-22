# Detailed Info About This Installation

This machine (virtual or real) was built using 

https://github.com/econ-ark/econ-ark-tools.git

using scripts in commit 98fc65c4 
with commit message "isohybrid_requires_syslinux-utils"
on date "20220807-1457"

Starting at the root of a cloned version of that repo,
you should be able to reproduce the installer with:

    git checkout 98fc65c4
    cd Virtual/Machine/ISO-maker ; ./create-unattended-iso_Econ-ARK-by-size.sh [ MIN | MAX ]

A copy of the ISO installer that generated this machine should be in the

    /installers

directory.

