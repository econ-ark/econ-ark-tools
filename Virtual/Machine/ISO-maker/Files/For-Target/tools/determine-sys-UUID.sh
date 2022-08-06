#!/bin/bash

sys_part="$(/var/local/tools/determine-sys-partition.sh)"
eval "$(blkid | grep "$sys_part": | rev | cut -d ' ' -f1 | rev)"
echo $PARTUUID


