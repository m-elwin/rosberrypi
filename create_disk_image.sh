#!/bin/sh
script_name=$0
usage=\
"Usage: $script_name <docker_img>

Build the rosberrypi disk image from a raspberry pi docker image

<docker_img> - The name of the docker image we want to write to a raspi filesystem

"""
set -e

if [ $# != "1" ]; then
    printf "$usage"
    exit 1
fi
docker_img=$1

# determine if we need to use sudo when calling docker
if groups $USER | grep -q docker;
then
    DOCKER=docker
else
    DOCKER="sudo docker"
fi

# We do all the steps inside docker containers
# Data is shared using the raspi_disk volume
# We try to do as few steps as possible in privileged containers

# Export the container to the volume (requires running docker inside docker)
$DOCKER run -it --rm \
        -v raspi_disk:/disk \
        -v /var/run/docker.sock:/var/run/docker.sock \
        rosberry-writer /10-export-container.sh $docker_img

# Create the image file (no special privileges needed)
$DOCKER run -it --rm \
        -v raspi_disk:/disk \
        rosberry-writer /20-make-disk-file.sh

# copying the files to the image must be privileged because
# The image file needs to be mounted on loopback.
$DOCKER run -it --rm --privileged \
        -v raspi_disk:/disk \
        --mount type=bind,src=/dev,target=/dev \
        rosberry-writer /30-copy-fs.sh

