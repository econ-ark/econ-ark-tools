#!/bin/bash

sudo apt-get remove docker docker-engine docker.io containerd runc
curl -fsSL https://get.docker.com -o installers/get-docker.sh
cd installers
sh get-docker.sh

