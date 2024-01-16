#!/bin/sh
script_name=$0
usage=\
"Usage: $script_name <docker_img> <disk_file>

Build the rosberrypi docker images

<docker_img> - The name of the docker image we want to write to a raspi filesystem
<file> - The name of the filesystem to store the filesystem in

"""
set -e

if [ $# != "2" ]; then
    printf "$usage"
    exit 1
fi
docker_img=$1
disk_file=$2

# determine if we need to use sudo when calling docker
if groups $USER | grep -q docker;
then
    DOCKER=docker
else
    DOCKER="sudo docker"
fi

# Create a temporary directory
tempdir=$(mktemp -d /tmp/raspXXXXX)

# Create the first docker container so it can be exported
container=$($DOCKER create $docker_img /bin/bash)
$DOCKER export $container -o "$tempdir/raspi.tar"

$DOCKER run -it --rm --privileged --mount type=bind,src=$tempdir,target=/disk --mount type=bind,src=/dev,target=/dev rosberry-writer

cp "$tempdir/disk.img" $disk_file
sudo rm -rf $tempdir
