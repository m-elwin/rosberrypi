FROM ubuntu:noble AS ubuntu_amd64
# Get a list of of all recursive dependencies from a working ubuntu system of the
# amd64 utlities that we need to replace
# The grep -v removes some malformed dependencies
RUN apt-get update \
    && apt-get install -yq \
    apt-rdepends \
    && apt-rdepends \
              gcc-aarch64-linux-gnu g++-aarch64-linux-gnu\
              python3 lsb-release perm passwd coreutils bash dash gawk grep sed findutils | grep -v "^ "\
              | grep -v "^awk$" | grep -v "debconf-2.0" | grep -v dpkg > /dependencies.txt

FROM rosberrypi-turtlebot3

COPY sources.list /etc/apt/sources.list
COPY --from=ubuntu_amd64 /dependencies.txt /dependencies.txt


# Remove packages that aren't useful for cross-compiling
# And that can cause problems since there is no kernel
RUN apt-get purge -yq \
    initramfs-tools \
    linux-image* \
    linux-modules* \
    man-db \
    u-boot-rpi && \
    apt-get -yq autoremove

# install amd64 packages that install smoothly
RUN dpkg --add-architecture amd64 \
    && apt-get update \
    && apt-get install -yq \
           cmake:amd64 \
           libapt-pkg6.0:amd64 \
           libseccomp2:amd64 \
           libsystemd0:amd64 \
           make:amd64

# Download amd64 apt, and remove arm64 apt, then install amd64 apt
# amd64 apt runs faster but it also by default downloads amd64 packages
# and, for some reason, when doing this, it is able to download amd64 packages
# that the arm version cannot do
RUN apt-get download apt:amd64 && \
    apt-get remove -yq --allow-remove-essential apt && \
    dpkg -i ./*.deb && \
    rm ./*.deb


# Manually download and install all the amd64 packages we need while ignoring dependencies.
# The binaries will overwrite the arm binaries but the
# amd64 and armhf libraries will remain installed side by side
# Ideally, all uses of the docker container after this point
# including during the build process, will not require qemu-arm-static
RUN apt-get update && apt-get download $(xargs -a dependencies.txt)
RUN dpkg --unpack --force-all *.deb

# We now have most of our build tools running native
# Bring in the cmake toolchain file
COPY raspi-toolchain.cmake /toolchain.cmake
RUN mkdir /ros_ws
VOLUME /ros_ws

COPY colcon_aarch64 /usr/bin/colcon_aarch64
COPY aarch64 /aarch64
WORKDIR /ros_ws

# replace the container with the container id
# which the hostname is set to
CMD ["cat", "/aarch64"]