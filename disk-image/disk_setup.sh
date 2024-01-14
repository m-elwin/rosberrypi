#!/bin/sh
usage=\
"Usage: $0 SIZE NAME

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

# We run the unprivileged parts as the original user

if [ -z $SUDO_USER ]; then
    echo "This script must be run with sudo"
    exit 1
fi

if [ "$EUID" != "0" ]; then
    echo "This script must be run as root with sudo"
    exit 1
fi

# Run as non-root for this sub-script
su $SUDO_USER -c "./disk_partition.sh $size $name"

device=$(losetup --show -Pf $name)
chown $SUDO_USER:$SUDO_USER "${device}p1"
chown $SUDO_USER:$SUDO_USER "${device}p2"

su $SUDO_USER -c "./disk_format.sh $device"

mountpoint=$(su $SUDO_USER -c "mktemp -d /tmp/raspiXXXXXX")

mount "${device}p2" "$mountpoint"
mkdir "$mountpoint/boot"
mount "${device}p1" "$mountpoint/boot"

