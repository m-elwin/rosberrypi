# ROS 2 Dockerfiles for Raspberry Pi and Turtlebot3
1. Creates a 64-bit bootable disk image and corresponding docker cross-compiling environment for the Raspberry Pi.
2. Takes a minimal and layered approach: various intermediate steps can be used and customized.
3. The primary example is a disk image suitable for use on the Turtlebot3 and a docker environment that enables cross-compilation.
4. It includes slightly-modified Turtlebot3 OpenCR firmware that enables low-level access to the motors and encoders from ROS
4. In the latest example ROS 2 Kilted and Ubuntu 22.04 is used.

# Cross-compiling
1. Install docker: `sudo apt install docker.io`
   - This step is done once per computer
2. In the base of a ROS workspace you wish to cross compile run `docker run reem17/rosberrypi-xcompile:kilted > aarch64 && chmod 755 aarch64`
   - This step is done once per workspace
3. Compile your code with ./aarch64 colcon_aarch64
   - This step is done whenever you wish to cross compile
   - It invokes `colcon build` (plus any additional arguments you provide) inside the cross compiling environment
   - The resulting install space is `aarch64_install` and can be transferred to the remote platform to be used

# Setup
0. These steps are for if you want to build or customize the Raspberrypi disk image or the cross compiling docker container.
   - *Most MSR students do not need to perform these steps!*
1. Install `docker` and `qemu-user-static-binfmt`
   - Ubuntu: `apt install qemu-user-static binfmt-support docker.io docker-buildx`
   - Arch Linux: `pacman -S qemu-user-static-binfmt docker`
2. Build the rosberrypi docker containers `./build_docker_images.sh [<target>]`
   - `<target>` (optional): which base docker image to create
      - `rosberrypi-turtlebot3` (default) A Full turtlebot3 environment with custom NU-MSR firmware available
      - `rosberrypi-ros`  A Full ROS 2 installation.
      - `rosberrypi-base` A minimal Ubuntu image from debootstrap.
3. Images can be built on top of the `rosberrypi-turtlebot3`.
   - `numsr_image.sh` will build a custom (example) image `rosberrypi-numsr` that sets up an `msr` user and connects to a wifi network

# Writing an Image
1. `./create_disk_image.sh <docker_img> <file>`
   - Creates a bootable raspberry pi disk image from `<docker_img>` and writes it to `<file>`
   - This works with any compatible docker image. Compatible images can be built by extending
     one of the built-in images
2. `./write_sd <disk_file> <sdcard> <hostname>`
   - Writes the `<disk_file>` (the disk iamge) to the sdcard at `<sdcard>`.
   - The `<hostname>` will be the hostname of the machine
   - The system partition will be expanded to fit the whole card

# OpenCR firmware
1. The opencr firmware is built in the `opencr/` docker container
2. On the turtlebot, with the OpenCR board plugged in, running `opencr_install_firmware` will install the firmware on the OpenCR board
