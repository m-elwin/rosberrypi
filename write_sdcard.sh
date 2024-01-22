#!/bin/sh
script_name=$0
usage=\
"Usage: $script_name <sdcard> <hostname>

Writes the disk image to the sdcard, and sets the hostname

<sdcard> the sdcard device (e.g., /dev/mmcblk0)
<hostname> the hostname to set on the sd card

"""
set -e

if [ $# != "2" ]; then
    printf "$usage"
    exit 1
fi
sdcard=$1
hostname=$2

# determine if we need to use sudo when calling docker
if groups $USER | grep -q docker;
then
    DOCKER=docker
else
    DOCKER="sudo docker"
fi

echo "Checking that $sdcard is not mounted"
if grep -q $sdcard /proc/mounts
then
    echo "The $sdcard has a mounted partition, cannot write."
    exit 1
else
    read -p "Copying /disk/disk.img to $sdcard: this will overwrite data. continue (Y/n)? " -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        $DOCKER run -it --rm --privileged \
                -v raspi_disk:/disk \
                --mount type=bind,src=/dev,target=/dev \
                rosberry-writer /40-write-to-sdcard.sh $sdcard $hostname
    fi
fi
