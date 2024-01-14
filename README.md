# ROS 2 Dockerfiles for Raspberry Pi
1. Creates a 64-bit bootable disk image and corresponding docker cross-compiling environment for the Raspberry Pi.
2. Takes a minimal and layered approach: various intermediate steps can be used and customized.
3. The primary example is a disk image suitable for use on the Turtlebot3 and a docker environment that enables cross-compilation.
4. In the latest example ROS 2 Iron and Ubuntu 22.04 is used.

# Pre-requisites
The host system needs `qemu-user-static-binfmt` to run arm64 binaries, and docker:

Ubuntu: `apt install qemu-user-static binfmt-support docker.io`
Arch Linux: `pacman -S qemu-user-static-binfmt docker`

# rosberrypi-ros
1. A multi-stage docker container that sets up the Linux system to be used on the raspberry Pi
2. It can be built from the rosberrypi-ros directory with `docker build --target <target> . -t <tag>`
   - `<target>` is the layer in the multi-stage build used for the image, allowing intermediate steps to be used
   - If `<target>` is ommitted, the top-level target is used
   - `<tag>` is a name for the image

From top-to-bottom, the possible values for `<target>` are:
- `rosberrypi-ros`  - A Full ROS 2 installation (in the future we may have a minimal ROS 2 installation as a target as well).
- `rosberrypi-base` - A minimal Ubuntu image from debootstrap
- `rosberrypi-bootstrap` - Ubuntu has been bootstrapped into a sub-directory


# disk-image
The scripts and containers here are used to create and write the SD Card image.
