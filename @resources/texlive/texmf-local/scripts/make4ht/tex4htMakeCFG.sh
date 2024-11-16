#!/bin/sh

if [ $# -eq 0 ]
then
  echo "usage: ${0##*/} <handoutName>"
  exit 1
fi

handoutName=$1

# cd "$(dirname "$0")" # http://stackoverflow.com/questions/3349105/how-to-set-current
if [[ "$(kpsewhich make4ht.cfg)" == "" ]]; then
    echo 'Unable to find $(kpsewhich make4ht.cfg) - aborting'
    exit
fi

cmd="cp `kpsewhich make4ht.cfg` $handoutName.cfg"
echo "$cmd" ; eval "$cmd"
cmd="cp `kpsewhich svg-set-size-to-1p0.mk4` $handoutName.mk4"
echo "$cmd" ; eval "$cmd"


