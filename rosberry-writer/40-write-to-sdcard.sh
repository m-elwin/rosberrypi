#!/bin/sh
# writes the image on the volume to the sdcard
set -e
if [ $# != "2" ]
then
    echo "Requires one arguments: <sdcard>"
    exit 1
fi
sdcard=$1
raspi_hostname=$2

echo "Writing host $hostname to $sdcard"
pv /disk/disk.img > $sdcard
echo "Image written. Waiting for sync.."

sdpart=$(fdisk -l $sdcard | tail -1 | awk '{print $1 }')
echo "Mounting $sdpart"
mount $sdpart /mnt
echo $raspi_hostname > /mnt/etc/hostname
cat <<EOF > /mnt/etc/hosts
127.0.0.1 localhost
::1       localhost
127.0.0.1 ${raspi_hostname}.lan ${raspi_hostname}
EOF
rm /mnt/etc/resolv.conf
ln -s /run/systemd/resolv.conf /mnt/etc/resolv.conf
umount $sdpart
echo "Resizing partition"
parted $sdcard resizepart 2 100%
