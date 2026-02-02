# Use multi-stage builds: https://docs.docker.com/build/building/multi-stage/
# docker build --target <stage> -t <tag>
# --target is optional and allows running to an intermediate step
# syntax=docker/dockerfile:1

# Get debootstrap and download minimal Ubuntu for arm64
FROM ubuntu:noble AS rosberrypi-bootstrap
COPY flash-kernel.equivs /

RUN apt-get update && \
    apt-get install -yq \
    debootstrap \
    equivs

RUN debootstrap --arch=arm64 \
                --foreign \
                --variant=minbase \
                noble \
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
RUN apt-get update \
    && apt-get upgrade -yq \
    && apt-get install -yq \
           iputils-ping \
           linux-image-raspi \
           linux-headers-raspi \
           locales \
           vim

RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    software-properties-common

# Generate and setup the locale
RUN locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

# Add additional repositories
RUN add-apt-repository universe restricted multiverse

# Fstab for the raspberry pi
COPY fstab /etc/fstab

# The next layer does a full ROS 2 install
FROM rosberrypi-base AS rosberrypi-ros
RUN apt-get update && \
    apt-get install -yq \
            curl \
            dh-make \
            dh-python \
            libarmadillo-dev \
            openssh-server \
            rsync

RUN echo "AcceptEnv ROS*" > /etc/ssh/sshd_config
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" > /etc/apt/sources.list.d/ros2.list

RUN apt-get update && \
    apt-get install -yq \
    ros-dev-tools \
    ros-kilted-desktop \
    && apt-get purge -yq unattended-upgrades \
    && apt-get autoremove -yq

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
       ros-kilted-hls-lfcd-lds-driver \
       ros-kilted-turtlebot3-msgs \
       ros-kilted-dynamixel-sdk \
       ros-kilted-catch-ros2

RUN git clone -b jazzy \
       https://github.com/ROBOTIS-GIT/turtlebot3.git

COPY turtlebot3_etc /etc

# Setup rosdep rules and the ability to build ros debian packages
RUN rosdep update && rosdep fix-permissions


# generate turtlebot3 debian packages with bloom and install them
RUN cd /turtlebot3/turtlebot3_description \
    && bloom-generate rosdebian --ros-distro kilted \
    && ./debian/rules binary
RUN cd /turtlebot3/turtlebot3_node \
    && bloom-generate rosdebian --ros-distro kilted \
    && ./debian/rules binary
RUN cd /turtlebot3/turtlebot3_bringup \
    && bloom-generate rosdebian --ros-distro kilted \
    && ./debian/rules binary
RUN cd /turtlebot3/turtlebot3_teleop \
    && bloom-generate rosdebian --ros-distro kilted \
    && ./debian/rules binary
RUN cd /turtlebot3 \
    && apt-get install -yq ./*.deb \
    && cd / \
    && rm -rf /turtlebot3

RUN cp /opt/ros/kilted/share/turtlebot3_bringup/script/99-turtlebot3-cdc.rules /etc/udev/rules.d

COPY opencr_install_numsr_firmware \
     opencr_install_robotis_firmware \
     /usr/local/bin

COPY --from=opencr \
     /nuburger.opencr \
     /burger.opencr \
     /opencr_ld_shell_arm64 \
     /usr/local/bin

RUN git clone https://github.com/NU-MSR/nuturtlebot_msgs \
    && cd nuturtlebot_msgs \
    && bloom-generate rosdebian --ros-distro kilted \
    && ./debian/rules binary \
    && apt-get install ../*.deb \
    && rm ../*.deb \
    && cd .. \
    && rm -rf nuturtlebot_msgs

RUN git clone https://github.com/NU-MSR/numsr_turtlebot \
    && cd numsr_turtlebot \
    && bloom-generate rosdebian --ros-distro kilted \
    && ./debian/rules binary \
    && apt-get install ../*.deb \
    && rm ../*.deb \
    && cd .. \
    && rm -rf numsr_turtlebot

# For Ubuntu Noble, and kilted we want a more up-dated GCC so we
# Can use C++23
RUN apt-get update && \
    apt-get install -yq g++-14 gcc-14 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-14 100