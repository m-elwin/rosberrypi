# ROS 2 Dockerfiles for Raspberry Pi
1. Creates a 64-bit bootable disk image and corresponding docker cross-compiling environment for the Raspberry Pi.
2. Takes a minimal and layered approach: various intermediate steps can be used and customized.
3. The primary example is a disk image suitable for use on the Turtlebot3 and a docker environment that enables cross-compilation.
4. In the latest example ROS 2 Iron and Ubuntu 22.04 is used.

# Cross-compiling environment

# Setup
1. Install `docker` and `qemu-user-static-binfmt`
   - Ubuntu: `apt install qemu-user-static binfmt-support docker.io`
   - Arch Linux: `pacman -S qemu-user-static-binfmt docker`
2. Build the rosberrypi docker containers `./build_docker_images.sh [<target>]`
   - `<target>` (optional): which base docker image to create
      - `rosberrypi-turtlebot3` (default) A Full turtlebot3 environment with custom NU-MSR firmware available
      - `rosberrypi-ros`  A Full ROS 2 installation.
      - `rosberrypi-base` A minimal Ubuntu image from debootstrap.
3. Images can be built on top of the `rosberrypi-turtlebot3`.
   - `numsr_image.sh` will build a custom (example) image `rosberrypi-numsr` that sets up an msr user and connects to a wifi network

# Writing an Image
1. `./create_disk_image.sh <docker_img> <file>`
   - Creates a bootable raspberry pi disk image from `<docker_img>` and writes it to `<file>`
   - This works with any compatible docker image. Compatible images can be built by extending
     one of the built-in images
2. `./write_sd <disk_file> <sdcard> <hostname>`
   - Writes the `<disk_file>` (the disk iamge) to the sdcard at `<sdcard>`.
   - The `<hostname>` will be the hostname of the machine
   - The system partition will be expanded to fit the whole card
