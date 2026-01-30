# This is an example of a custom dockerfile that adds username and network connectivity
# TODO: should use docker build secrets rather than args
FROM rosberrypi-turtlebot3

ARG msr_password
ARG msr_ssid
ARG msr_psk

# Create the MSR user
RUN useradd msr --create-home --shell /usr/bin/bash --groups adm,sudo,video \
    && echo "source /opt/ros/kilted/setup.bash" >> /home/msr/.bashrc \
    && echo "export LDS_MODEL=LDS-01" >> /home/msr/.bashrc \
    && echo "msr:$msr_password" | chpasswd

COPY --chmod=600 NUMSR.nmconnection /etc/NetworkManager/system-connections

# Setup the wifi network
RUN sed "s@ROSBERRY_SSID@$msr_ssid@" \
        -i /etc/NetworkManager/system-connections/NUMSR.nmconnection \
 && sed "s@ROSBERRY_PSK@$msr_psk@" \
         -i /etc/NetworkManager/system-connections/NUMSR.nmconnection

USER msr
RUN . /opt/ros/kilted/setup.sh && rosdep update
USER root
