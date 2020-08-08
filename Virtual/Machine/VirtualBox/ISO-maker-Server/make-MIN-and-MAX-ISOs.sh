#!/bin/bash

sudo ./create-unattended-iso_Econ-ARK-by-size-20p04.sh MIN
sudo ./rclone-To-Google-Drive_Last-ISO-Made.sh

sudo ./create-unattended-iso_Econ-ARK-by-size-20p04.sh MAX 
sudo ./rclone-To-Google-Drive_Last-ISO-Made.sh

