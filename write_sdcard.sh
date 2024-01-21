#!/bin/sh
script_name=$0
usage=\
"Usage: $script_name <disk_file> <sdcard> <hostname>

Writes the disk image to the sdcard, and sets the hostname

<disk_file> the name of the file containing the disk image
<sdcard> the sdcard device (e.g., /dev/mmcblk0)
<hostname> the hostname to set on the sd card

"""
set -e

if [ $# != "3" ]; then
    printf "$usage"
    exit 1
fi
disk_file=$1
sdcard=$2
hostname=$3

echo "Checking that $sdcard is not mounted"
if grep -q $sdcard /proc/mounts
then
    echo "The $sdcard has a mounted partition, cannot write."
    exit 1
else
    read -p "Copying $disk_file to $sdcard: this will overwrite data. continue (Y/n)? " -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        sudo cp $disk_file $sdcard
        tempdir=$(mktemp -d /tmp/rasp_sdXXXXX)
        sudo mount $sdcard $tempdir
        sudo echo $hostname > $tempdir/etc/hostname
        sudo umount $sdcard
        kmdir $tempdir
    fi
fi
