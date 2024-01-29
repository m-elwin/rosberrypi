#!/bin/sh
script_name=$0
usage=\
"Usage: $script_name <ssid> <ssid_password> <msr_password>

Build the rosberrypi docker images

<ssid> - SSID of wifi network to connect to
<ssid_password> - password for the wifi network
<msr_password> - password for the msr user on the system
"""
set -e

if [ $# != "3" ]; then
    printf "$usage"
    exit 1
fi

# determine if we need to use sudo when calling docker
if groups $USER | grep -q docker;
then
    DOCKER=docker
else
    DOCKER="sudo docker"
fi

msr_ssid=$1
msr_psk=$2
msr_password=$3

# TODO: use build secrets instead of build-args
$DOCKER build --tag rosberrypi-numsr \
        --build-arg="msr_password=$msr_password" \
        --build-arg="msr_ssid=$msr_ssid" \
        --build-arg="msr_psk=$msr_psk" \
        ./custom
