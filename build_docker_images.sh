#!/bin/sh
script_name=$0
usage=\
"Usage: $script_name [<target>]

Build the rosberrypi docker images

<target> - Build only the images up-to the named target
           allowing a more minimal image to be explicitly referred to and booted
           defaults to the turtlebot3 target
"""
set -e

if [ $# -gt "1" ]; then
    printf "$usage"
    exit 1
elif [ $# = "0" ]; then
    target=turtlebot3
else
    target=$1
fi

# determine if we need to use sudo when calling docker
if groups $USER | grep -q docker;
then
    DOCKER=docker
else
    DOCKER="sudo docker"
fi

$DOCKER build --target $target --tag $target ./rosberrypi-ros
$DOCKER build --tag rosberry-writer ./rosberry-writer
