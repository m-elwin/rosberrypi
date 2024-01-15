#!/bin/sh
# Create, partition, and format a disk image for the Raspberry Pi 3
# Then mount the image on a loop device, printing the name of the device used.

# In the docker container, the raspi filesystem is mounted at /raspi. Get it's size
size=$(du -s -h /raspi | awk '{ print $1 }')

# Make the boot partition (with a little room to spare)
truncate -s "300M" boot.img
truncate -s "${size}" sys.img
cat boot.img sys.img > /disk/disk.img
rm boot.img sys.img

# Create the MBR Partition table
parted -s /disk/disk.img mklabel msdos

# Create the boot partition
parted -s /disk/disk.img mkpart primary fat32 1049kB 269MB
parted -s /disk/disk.img toggle 1 boot
parted -s /disk/disk.img mkpart primary ext4 269MB 270MB
parted -s /disk/disk.img resizepart 2 100%

# Setup the loopback device
device=$(losetup --show -Pf /disk/disk.img)

# Format the disk
mkfs.vfat "${device}p1"
mkfs.ext4 -F "${device}p2"

# Mount the disk
mount "${device}p2" /mnt
mkdir /mnt/boot
mount "${device}p1" /mnt/boot

# Copy the root filesystem to the main partition
tar xf /disk/raspifs.tar -C /mnt

# Copy the firmware to the boot partition
cp -ar firmware/* "/mnt/boot"

# Unmount
umount /mnt/boot
umount /mnt

# Delete the loop device
losetup -d "${device}"

