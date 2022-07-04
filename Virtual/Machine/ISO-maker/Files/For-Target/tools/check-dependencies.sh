#!/bin/bash

package=$1

apt-cache showpkg $package | sed '1,/Reverse Depends:/d;/Dependencies:/,$d'  > /tmp/dependencies.txt

while read line
do
    reverse_dependency=$(awk -F '[:,]' '{print $1}' <<< $line)
    if dpkg -s $reverse_dependency &> /dev/null
    then
        echo "$line is installed and depends on $package"
    fi
done < /tmp/dependencies.txt
