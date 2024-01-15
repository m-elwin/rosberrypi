# This image contains all the tools used to write the disk image
FROM ubuntu:jammy

RUN apt-get update \
    && apt-get install -yq \
    curl \
    parted


# Get the raspberry pi firmware
RUN curl -L "https://github.com/raspberrypi/firmware/archive/refs/tags/1.20230405.tar.gz" > firmware-1.20230405.tar.gz \
    && tar xf firmware-1.20230405.tar.gz \
    && rm firmware-1.20230405.tar.gz \
    && mv firmware-1.20230405 firmware

COPY --chmod=755 disk_setup.sh /disk_setup.sh

# The disk volume is where the raspi image filesystem tarball is placed
# And it is where the output disk image is placed
VOLUME ["/disk"]

ENTRYPOINT ["/disk_setup.sh"]