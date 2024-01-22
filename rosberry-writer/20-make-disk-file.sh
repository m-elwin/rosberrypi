#!/bin/sh
# Creates a disk file that holds the SD card content
# The disk file is partitioned and formatted and
# prepared for mounting

# Untar the root filesystem to the main partition
echo "Untarring rootfs"
mkdir /disk/raspi
tar xf /disk/raspi.tar -C /disk/raspi && rm /disk/raspi.tar

# In the docker container, the raspi filesystem is mounted at /raspi. Get it's size
size=$(du -s -m /disk/raspi | awk '{ print $1 }')
echo "Need at least ${size}MB for rootfs in disk image"

echo "Creating the disk image"
# Make the boot partition (with a little room to spare)
truncate -s "1G" /boot.img
truncate -s "${size}M" /sys.img
cat /boot.img /sys.img > /disk/disk.img
rm /boot.img /sys.img

echo "Partitioning the disk"
# Create the MBR Partition table
parted -s /disk/disk.img mklabel msdos

# Create the boot partition
parted -s /disk/disk.img mkpart primary fat32 1049kB 269MB
parted -s /disk/disk.img toggle 1 boot
parted -s /disk/disk.img mkpart primary ext4 269MB 270MB
parted -s /disk/disk.img resizepart 2 100%
