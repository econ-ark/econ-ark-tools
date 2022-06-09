#!/bin/bash

cd /Users/Shared/multipassd-virtualbox-vault-instances

instance="$1"

if [ ! -z "$(multipass list | cut -d' ' -f1 | grep $instance$)" ]; then # at least partial match
    if [ $(multipass list | cut -d' ' -f1 | grep "$instance$") == "$instance" ]; then
        echo '' ; echo An instance named $instance already exists
        echo '' ; echo Delete it by: ; echo ''
        cmd="multipass stop $instance ; multipass delete $instance ; multipass purge"
        echo "$cmd" | pbcopy
        echo "$cmd"
        echo '' ; echo '(on the clipboard), then run again'; echo ''
        exit 1
    fi
fi

longtime="$(bc <<< 60*60*2)" # 2 hours in seconds
# Try to execute null command ":" on remote
keep_trying="(multipass start "$instance" &);fails=1;until [[ \$fails == 0 ]]; do echo '.. waiting for up status' ; fails=\$(bash -c '(timeout 10 multipass exec "$instance" : ; echo \$?)')  ; done ; multipass shell "$instance
echo "$keep_trying"
echo "$keep_trying" | pbcopy

echo "echo '' ; echo Run ; echo '' ; echo "multipass shell $instance" ; echo '' ; echo ' (should be on clipboard) in another window to connect before install finishes' ; echo ''" > /tmp/multipass_launch.sh
cmd="multipass launch -vvvv --cpus 4 --disk 64G --mem 16G --name $instance --cloud-init ./$instance.txt --network en0 --timeout $longtime 20.04" 
echo '' >>/tmp/multipass_launch.sh
echo "echo 'now running' ; echo ''" >>/tmp/multipass_launch.sh
echo "echo "$cmd >> /tmp/multipass_launch.sh
echo "$cmd" >> /tmp/multipass_launch.sh
sudo chmod a+rwx /tmp/multipass_launch.sh
sudo cp ./$instance.txt /tmp/$instance.txt
sudo chmod a+rw /tmp/$instance.txt
echo '' ; echo ''
echo "$cmd"
echo '' ; echo 'is in /tmp/multipass_launch.sh' ; echo ''
# eval "$cmd"

