#!/bin/sh
# writes the image on the vlume to the sdcard
set -e
if [ $# != "2" ]
then
    echo "Requires two arguments: <sdcard> and <hostname>"
    exit 1
fi
sdcard=$1
hostname=$2

echo "Writing host $hostname to $sdcard"
pv /disk/disk.img > $sdcard
echo "Image written. Waiting for sync.."
# get the name of the last partition of the disk
sdpart=$(fdisk -l $sdcard | tail -1 | awk '{print $1 }')
echo "Mounting $sdpart"
mount $sdpart /mnt
echo $hostname > /mnt/etc/hostname
umount $sdpart
