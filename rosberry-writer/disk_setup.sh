#!/bin/sh
usage=\
"Usage: $0 SIZE DISK_IMAGE

Create, partition, and format a disk image of the given SIZE (in GB) with the given NAME,
in a manner suitable for booting a Raspberry PI 3.

Then mount the image on a loop device, printing the name of the device used.
"
set -e
if [ $# != "2" ]; then
    printf "$usage"
    exit 1
fi

size=$1
name=$2

if [ "$EUID" != "0" ]; then
    echo "This script must be run as root."
    exit 1
fi

# Make the disk image
truncate -s "${size}GB" $name

# Create the MBR Partition table
parted -s $name mklabel msdos

# Create the boot partition
parted -s $name mkpart primary fat32 1049kB 269MB
parted -s $name toggle 1 boot
parted -s $name mkpart primary ext4 269MB 270MB
parted -s $name resizepart 2 100%

# Setup the loopback device
device=$(losetup --show -Pf $name)
chown $SUDO_USER:$SUDO_USER "${device}p1"
chown $SUDO_USER:$SUDO_USER "${device}p2"

# Format the disk
mkfs.vfat "${device}p1"
mkfs.ext4 -F "${device}p2"

# Mount the disk
mountpoint="/mnt"

mount "${device}p2" "$mountpoint"
mkdir "$mountpoint/boot"
mount "${device}p1" "$mountpoint/boot"

# Copy the root filesystem to the main partition
cp -ar /raspi/* "$mountpoint"

# Copy the firmware to the boot partition
cp -ar firmware/* "$mountpoint/boot"
