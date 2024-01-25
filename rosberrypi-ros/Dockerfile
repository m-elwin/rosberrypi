# Use multi-stage builds: https://docs.docker.com/build/building/multi-stage/
# docker build --target <stage> -t <tag>
# --target is optional and allows running to an intermediate step
# syntax=docker/dockerfile:1

# Get debootstrap and download minimal Ubuntu for arm64
FROM ubuntu:jammy AS rosberrypi-bootstrap
COPY flash-kernel.equivs /

RUN apt-get update && \
    apt-get install -yq \
    debootstrap \
    equivs

RUN debootstrap --arch=arm64 \
                --foreign \
                --variant=minbase \
                jammy \
                /mnt \
                http://ports.ubuntu.com/ubuntu-ports
RUN equivs-build /flash-kernel.equivs \
    && mv flash-kernel_99_all.deb /mnt

# The next image is the most basic Ubuntu container
# But with locale and basic repositories enabled
FROM scratch AS rosberrypi-base
COPY --from=rosberrypi-bootstrap /mnt /

# Debootstrap everything
RUN /debootstrap/debootstrap --second-stage

# Install fake flash kernel
RUN dpkg -i /flash-kernel_99_all.deb && rm /flash-kernel_99_all.deb

# Install some additional needed packages
RUN apt-get update && \
    apt-get install -yq \
    linux-image-raspi \
    linux-headers-raspi \
    locales

RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    software-properties-common

# Generate and setup the locale
RUN locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

# Add additional repositories
RUN add-apt-repository universe restricted multiverse


# The next layer does a full ROS 2 install
FROM rosberrypi-base AS rosberrypi-ros
RUN apt-get update && \
    apt-get install -yq \
            curl \
            dh-make \
            dh-python

RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" > /etc/apt/sources.list.d/ros2.list

RUN apt-get update && \
    apt-get install -yq \
    ros-dev-tools \
    ros-iron-desktop \
    && apt-get purge unattended-upgrades

RUN rosdep init

# Setup turtlebot 3
# Follow advanced instructions from
# https://emanual.robotis.com/docs/en/platform/turtlebot3/sbc_setup/#sbc-setup
FROM rosberrypi-ros as rosberrypi-turtlebot3

RUN systemctl mask \
              hibernate.target \
              hybrid-sleep.target \
              sleep.target \
              suspend.target \
              systemd-networkd-wait-online.service

RUN apt-get update \
    && apt-get install -yq \
       network-manager \
       ros-iron-hls-lfcd-lds-driver \
       ros-iron-turtlebot3-msgs \
       ros-iron-dynamixel-sdk

RUN git clone -b humble-devel \
       https://github.com/ROBOTIS-GIT/turtlebot3.git

COPY turtlebot3_etc /etc

# Setup rosdep rules and the ability to build ros debian packages
RUN rosdep update && rosdep fix-permissions


# generate turtlebot3 debian packages with bloom and install them
RUN cd /turtlebot3/turtlebot3_description \
    && bloom-generate rosdebian --ros-distro iron \
    && ./debian/rules binary \
    && cd /turtlebot3/turtlebot3_node \
    && bloom-generate rosdebian --ros-distro iron \
    && ./debian/rules binary \
    && cd /turtlebot3/turtlebot3_bringup \
    && bloom-generate rosdebian --ros-distro iron \
    && ./debian/rules binary \
    && cd /turtlebot3/turtlebot3_teleop \
    && bloom-generate rosdebian --ros-distro iron \
    && ./debian/rules binary \
    && cd /turtlebot3 \
    && apt-get install ./*.deb \
    && cd / \
    && rm -rf /turtlebot3


