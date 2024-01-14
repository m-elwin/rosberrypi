#!/bin/sh
usage=\
"Usage: $0 SIZE NAME

Create and partition disk image of the given SIZE (in GB) with the given NAME,
in a manner suitable for booting on a Raspberry Pi 3:

The disk image will have:
An MBR partition table.
A 268MB fat32 boot partition (starting 1MB into the disk).
The rest of the disk is for the system partition.

"

if [ $# != "2" ]; then
    printf "$usage"
    exit 1
fi

size=$1
name=$2

# Make the disk image
truncate -s "${size}GB" $name

# Create the MBR Partition table
parted -s $name mklabel msdos

# Create the boot partition
parted -s $name mkpart primary fat32 1049kB 269MB
parted -s $name toggle 1 boot
parted -s $name mkpart primary ext4 269MB 270MB
parted -s $name resizepart 2 100%
