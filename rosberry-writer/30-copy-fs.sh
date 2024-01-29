#!/bin/sh
# Mount the disk image and copy the fs

# Setup the loopback device
device=$(losetup --show -Pf /disk/disk.img)

# Format the disk
echo "Formatting the disk"
mkfs.vfat "${device}p1"
mkfs.ext4 -F "${device}p2"
fatlabel "${device}p1" system-boot
e2label "${device}p2" writable

# Mount the disk
echo "Mounting on ${device}"
mount "${device}p2" /mnt
mkdir /mnt/boot
mount "${device}p1" /mnt/boot

echo "Copying the root filesystem"
# Copy the system filesystem to disk.
# It will fail to copy symlinks to /boot, ignore that error
cp -far /disk/raspi/* /mnt || :

# Get the linux version
version=$(readlink /disk/raspi/boot/vmlinuz | cut -c 9-)
# adjust all boot files to versionless names
mv /mnt/boot/initrd.img-$version /mnt/boot/initrd.img
mv /mnt/boot/System.map-$version /mnt/boot/System.map
mv /mnt/boot/vmlinuz-$version /mnt/boot/vmlinuz

cp /cmdline.txt /mnt/boot/cmdline.txt
cp /config.txt /mnt/boot/config.txt

echo "Copying the firmware"
# Copy the firmware to the boot partition
cp -far firmware/boot/* /mnt/boot

echo "Unmounting"
# Unmount
umount /mnt/boot
umount /mnt

rm -rf /disk/raspi

# Delete the loop device
losetup -d "${device}"

