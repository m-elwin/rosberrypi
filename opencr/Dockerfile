# This dockerfile is for building the opencr firmware
FROM ubuntu:jammy

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

RUN ln -s /OpenCR/arduino/opencr_release /arduino && \
    arduino-cli --config-file /arduino-cli.yaml core install OpenCR:OpenCR -v && \
    arduino-cli --config-file /arduino-cli.yaml core update-index && \
    arduino-cli --config-file /arduino-cli.yaml lib update-index && \
    arduino-cli --config-file /arduino-cli.yaml lib install Dynamixel2Arduino

# This command creates the firmware in the firmware directory
# Add -v for verbose output when debugging
# The opencr_ld_shell converts the bin file to a form that can be loaded onto the OpenCR board
# The output is /nuburger.opencr
RUN arduino-cli --config-file /arduino-cli.yaml compile  --build-path /firmware \
                --fqbn OpenCR:OpenCR:OpenCR arduino/packages/OpenCR/hardware/OpenCR/1.5.1/libraries/turtlebot3_ros2/examples/turtlebot3_burger/turtlebot3_burger.ino \
                && /OpenCR/arduino/opencr_develop/opencr_ld_shell/opencr_ld_shell_x86 make /firmware/turtlebot3_burger.ino.bin nuburger NU-MSR
