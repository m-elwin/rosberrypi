#!/bin/sh
# Create, partition, and format a disk image for the Raspberry Pi 3
# Then mount the image on a loop device, printing the name of the device used.
set -e

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

# Setup the loopback device
device=$(losetup --show -Pf /disk/disk.img)

# Format the disk
echo "Formatting the disk"
mkfs.vfat "${device}p1"
mkfs.ext4 -F "${device}p2"

# Mount the disk
echo "Mounting on ${device}"
mount "${device}p2" /mnt
mkdir /mnt/boot
mount "${device}p1" /mnt/boot

echo "Copying the root filesystem"
# Copy the system filesystem to disk
cp -ar /disk/raspi/* /mnt

echo "Copying the firmware"
# Copy the firmware to the boot partition
cp -far firmware/boot/* /mnt/boot

echo "Unmounting"
# Unmount
umount /mnt/boot
umount /mnt

# Delete the loop device
losetup -d "${device}"

