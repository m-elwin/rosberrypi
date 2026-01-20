# This image contains all the tools used to write the disk image
FROM ubuntu:noble

RUN apt-get update \
    && apt-get install -yq \
    curl \
    docker.io \
    dosfstools \
    fdisk \
    udev \
    parted \
    pv


# Get the raspberry pi firmware
RUN curl -L "https://github.com/raspberrypi/firmware/archive/refs/tags/1.20230405.tar.gz" > firmware-1.20230405.tar.gz \
    && tar xf firmware-1.20230405.tar.gz \
    && rm firmware-1.20230405.tar.gz \
    && mv firmware-1.20230405 firmware

VOLUME /disk

COPY config.txt cmdline.txt /
COPY --chmod=755 \
     10-export-container.sh \
     20-make-disk-file.sh \
     30-copy-fs.sh \
     40-write-to-sdcard.sh \
     /