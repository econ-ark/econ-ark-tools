#!/bin/bash

# Figure out what the target device is 
df -hT > /tmp/target-partition 
cat /tmp/target-partition | grep -v vfat | grep '/dev' | grep -v 'loop' | grep -v 'ude' | grep -v 'tmpf' | cut -d ' ' -f1 > /tmp/target-dev 
sys_part=$(cat /tmp/target-dev)
echo $sys_part
