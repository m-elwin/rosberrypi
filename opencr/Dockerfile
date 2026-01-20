# This dockerfile is for building the opencr firmware
FROM ubuntu:noble

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
    curl \
    libc6:i386 \
    libc++6:i386 \
    git

# Clone (my fork of) the opencr repository
RUN git clone https://github.com/NU-MSR/OpenCR -b numsr_iron

# Install the arduino CLI from instructions https://arduino.github.io/arduino-cli/0.29/installation/
RUN curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh

# Install the OpenCR board files
COPY arduino-cli.yaml /arduino-cli.yaml

RUN arduino-cli --config-file /arduino-cli.yaml core install OpenCR:OpenCR -v && \
    arduino-cli --config-file /arduino-cli.yaml core update-index && \
    arduino-cli --config-file /arduino-cli.yaml lib update-index && \
    arduino-cli --config-file /arduino-cli.yaml lib install Dynamixel2Arduino

# This command creates the firmware in the firmware directory
# Add -v for verbose output when debugging
# The opencr_ld_shell converts the bin file to a form that can be loaded onto the OpenCR board
# The output is /nuburger.opencr
RUN arduino-cli --config-file /arduino-cli.yaml compile  --build-path /firmware \
                --fqbn OpenCR:OpenCR:OpenCR \
                --library /OpenCR/arduino/opencr_arduino/opencr/libraries/turtlebot3_ros2 \
                /OpenCR/arduino/opencr_arduino/opencr/libraries/turtlebot3_ros2/examples/turtlebot3_burger/turtlebot3_burger.ino \
                && /OpenCR/arduino/opencr_develop/opencr_ld_shell/opencr_ld_shell_x86 make /firmware/turtlebot3_burger.ino.bin nuburger NU-MSR

RUN apt-get update && apt-get install -yq gcc-aarch64-linux-gnu

# Cross-compile the Opencr shell for arm64. This is the tool that is used to load firmware onto the opencr board
RUN cd /OpenCR/arduino/opencr_develop/opencr_ld_shell \
    && aarch64-linux-gnu-gcc -o opencr_ld_shell_arm64 main.c opencr_ld.c serial_posix.c ./msg/msg.c \
    && mv opencr_ld_shell_arm64 /


COPY --chmod=755 opencr_install_firmware /