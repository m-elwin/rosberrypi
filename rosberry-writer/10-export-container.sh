#!/bin/sh
# Export a docker image to the /disk volume
set -e

docker_img=$1

if [ $# != "1" ]
then
    echo "Must specify the docker image, but no arguments given"
    exit 1
fi

echo "Exporting $docker_img."
# Create the first docker container so it can be exported
container=$(docker create $docker_img /bin/bash)
docker export $container -o /disk/raspi.tar
docker rm $container
