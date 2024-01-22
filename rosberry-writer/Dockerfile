# This image contains all the tools used to write the disk image
FROM ubuntu:jammy

RUN apt-get update \
    && apt-get install -yq \
    curl \
    dosfstools \
    udev \
    parted


# Get the raspberry pi firmware
RUN curl -L "https://github.com/raspberrypi/firmware/archive/refs/tags/1.20230405.tar.gz" > firmware-1.20230405.tar.gz \
    && tar xf firmware-1.20230405.tar.gz \
    && rm firmware-1.20230405.tar.gz \
    && mv firmware-1.20230405 firmware

COPY config.txt cmdline.txt disk_setup.sh /
COPY --chmod=755 disk_setup.sh /disk_setup.sh

ENTRYPOINT ["/disk_setup.sh"]