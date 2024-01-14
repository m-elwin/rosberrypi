# Use multi-stage builds: https://docs.docker.com/build/building/multi-stage/
# docker build --target <stage> -t <tag>
# --target is optional and allows running to an intermediate step
# syntax=docker/dockerfile:1

# Get debootstrap and download minimal Ubuntu for arm64
FROM ubuntu:jammy AS rosberrypi-bootstrap

RUN apt-get update && \
    apt-get install -yq debootstrap

RUN debootstrap --arch=arm64 \
                --variant=minbase \
                jammy \
                /mnt \
                http://ports.ubuntu.com/ubuntu-ports

# The next image is the most basic Ubuntu container
# But with locale and basic repositories enabled
FROM scratch AS rosberrypi-base
COPY --from=rosberrypi-bootstrap /mnt /

# Install some additional needed packages
RUN apt-get update && \
    apt-get install -yq \
    locales \
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
    apt-get install curl -yq

RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" > /etc/apt/sources.list.d/ros2.list

RUN apt-get update && \
    apt-get install -yq \
    ros-dev-tools \
    ros-iron-desktop

# The next layer is for the turtlebot3