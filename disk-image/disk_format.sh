#!/bin/sh
set -e
usage=\
"Usage: $0 DEVICE

Format the raspberry pi device with the appropriate filesystems
"

if [ $# != "1" ]; then
    printf "$usage"
    exit 1
fi

device=$1

mkfs.vfat "${device}p1"
mkfs.ext4 -F "${device}p2"
