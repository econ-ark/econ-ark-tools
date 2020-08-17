#!/bin/bash

pathToScript=$(dirname `realpath "$0"`)

echo ''
echo "/tmp/rclone-to-Google-Drive_Last-ISO-Made-MIN.sh:"
[[ -e /tmp/rclone-to-Google-Drive_Last-ISO-Made-MIN.sh ]] && sudo /tmp/rclone-to-Google-Drive_Last-ISO-Made-MIN.sh

echo ''
echo "/tmp/rclone-to-Google-Drive_Last-ISO-Made-MAX.sh:"
[[ -e /tmp/rclone-to-Google-Drive_Last-ISO-Made-MAX.sh ]] && sudo /tmp/rclone-to-Google-Drive_Last-ISO-Made-MAX.sh
