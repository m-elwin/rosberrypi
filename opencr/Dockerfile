# This dockerfile is for building the opencr firmware
FROM ubuntu:noble

### Dependencies required to compile arduino for the OpenCR board
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
    curl \
    libc6:i386 \
    libc++6:i386 \
    git \
    gcc-aarch64-linux-gnu

#### The Arduino CLI is used to compile the firmware
# Install the arduino CLI from instructions https://arduino.github.io/arduino-cli/0.29/installation/
RUN curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh

# Install the OpenCR board files
COPY arduino-cli.yaml /arduino-cli.yaml

RUN arduino-cli --config-file /arduino-cli.yaml core install OpenCR:OpenCR -v && \
    arduino-cli --config-file /arduino-cli.yaml core update-index && \
    arduino-cli --config-file /arduino-cli.yaml lib update-index && \
    arduino-cli --config-file /arduino-cli.yaml lib install Dynamixel2Arduino

#### Building the custom firmware
# Clone (my fork of) the opencr repository
RUN git clone https://github.com/NU-MSR/OpenCR -b numsr_iron

### Cross-compiled Opencr shell for arm64. This is the tool that is used to load the firmware onto the OpenCR board from the raspi
# Cross-compile the Opencr shell for arm64. This is the tool that is used to load firmware onto the opencr board
RUN cd /OpenCR/arduino/opencr_develop/opencr_ld_shell \
    && aarch64-linux-gnu-gcc -o opencr_ld_shell_arm64 main.c opencr_ld.c serial_posix.c ./msg/msg.c \
    && mv opencr_ld_shell_arm64 /



# This command creates the firmware in the firmware directory
# Add -v for verbose output when debugging
# The opencr_ld_shell converts the bin file to a form that can be loaded onto the OpenCR board
# The output is /nuburger.opencr
# This builds the custom firmware
RUN arduino-cli --config-file /arduino-cli.yaml compile  --build-path /firmware_msr \
                --fqbn OpenCR:OpenCR:OpenCR \
                --library /OpenCR/arduino/opencr_arduino/opencr/libraries/turtlebot3_ros2 \
                /OpenCR/arduino/opencr_arduino/opencr/libraries/turtlebot3_ros2/examples/turtlebot3_burger/turtlebot3_burger.ino \
                && /OpenCR/arduino/opencr_develop/opencr_ld_shell/opencr_ld_shell_x86 make /firmware_msr/turtlebot3_burger.ino.bin nuburger NU-MSR

## Building the robotis firmware (this is the original firmware
RUN cd OpenCR \
    && git switch master \
    && cd .. \
    && arduino-cli --config-file /arduino-cli.yaml compile  --build-path /firmware_robotis\
                --fqbn OpenCR:OpenCR:OpenCR \
                --library /OpenCR/arduino/opencr_arduino/opencr/libraries/turtlebot3_ros2 \
                /OpenCR/arduino/opencr_arduino/opencr/libraries/turtlebot3_ros2/examples/turtlebot3_burger/turtlebot3_burger.ino \
                && /OpenCR/arduino/opencr_develop/opencr_ld_shell/opencr_ld_shell_x86 make /firmware_robotis/turtlebot3_burger.ino.bin burger ROBOTIS