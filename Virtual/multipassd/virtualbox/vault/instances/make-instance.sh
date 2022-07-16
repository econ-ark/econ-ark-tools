#!/bin/bash

cd /Users/Shared/multipassd-virtualbox-vault-instances

instance="$1"

instance=xub-20p04-MIN
cpus=2
disk="64G"
mem="6G"
network="en0"

instance_specs="$instance""-cpus$cpus""disk$disk""mem$mem"

if [ ! -z "$(multipass list | cut -d' ' -f1 | grep $instance)" ]; then # at least partial match
    if [ $(multipass list | cut -d' ' -f1 | grep "$instance") == "$instance_specs" ]; then # exact match
        echo '' ; echo An instance named $instance_specs already exists
        echo '' ; echo Delete it by: ; echo ''
        cmd="multipass stop $instance_specs ; multipass delete $instance_specs ; multipass purge"
        [[ "$(uname -s)" == "Darwin" ]] && echo "$cmd" | pbcopy
        [[ "$(uname -s)" == "darwin" ]] && echo "$cmd" | pbcopy
        echo "$cmd"
        echo '' ; echo '(on the clipboard), then run again'; echo ''
        exit 1
    fi
fi

longtime="$(bc <<< 60*60*8)" # 8 hours in seconds
# Try to execute null command ":" on remote
keep_trying="fails=1;until [[ \$fails == 0 ]]; do echo '.. waiting for up status' ; fails=\$(bash -c '(timeout 10 multipass exec "$instance_specs" : ; echo \$?)')  ; done ; multipass shell "$instance_specs
echo "$keep_trying"

[[ "$(uname -s)" == "darwin" ]] && echo "$keep_trying" | pbcopy
[[ "$(uname -s)" == "Darwin" ]] && echo "$keep_trying" | pbcopy

echo "echo '' ; echo Run ; echo '' ; echo "multipass shell $instance_specs" ; echo '' ; echo ' (should be on clipboard) in another window to connect before install finishes' ; echo ''" > /tmp/multipass_launch.sh
cmd="multipass launch -vvvv --cpus "$cpus" --disk "$disk" --mem "$mem" --name $instance_specs --cloud-init ./$instance.txt --network $network  20.04" 
echo '' >>/tmp/multipass_launch.sh
echo "echo 'now running' ; echo ''" >>/tmp/multipass_launch.sh
echo "echo "$cmd >> /tmp/multipass_launch.sh
echo "$cmd" >> /tmp/multipass_launch.sh
sudo chmod a+rwx /tmp/multipass_launch.sh
echo cp ./$instance.txt /tmp/$instance.txt
sudo cp ./$instance.txt /tmp/$instance.txt
sudo chmod a+r /tmp/$instance.txt
echo '' ; echo ''
echo "$cmd"
echo '' ; echo 'is in /tmp/multipass_launch.sh' ; echo ''
# eval "$cmd"

