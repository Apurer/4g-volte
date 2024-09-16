# Dockerfile for srsUE with bladeRF support

FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

# Install updates and dependencies
RUN apt-get update && \
    apt-get -y install cmake libfftw3-dev libmbedtls-dev libboost-program-options-dev \
    libconfig++-dev libsctp-dev git libzmq3-dev libboost-system-dev libboost-test-dev \
    libboost-thread-dev libqwt-qt5-dev qtbase5-dev software-properties-common \
    g++ make pkg-config libpython3-dev python3-numpy swig libi2c-dev net-tools \
    iputils-ping libusb-1.0-0-dev iproute2 wget \
    **libncurses5-dev**

# Install bladeRF drivers and firmware
RUN git clone https://github.com/Nuand/bladeRF.git && \
    cd bladeRF/host/ && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DINSTALL_UDEV_RULES=ON -DBLADERF_GROUP=plugdev ../ && \
    make && make install && \
    ldconfig && \
    mkdir -p /etc/Nuand/bladeRF/ && \
    wget https://www.nuand.com/fpga/hostedxA4-latest.rbf \
    -O /etc/Nuand/bladeRF/hostedxA4-latest.rbf

# Install srsRAN (srsLTE) with bladeRF support
RUN git clone https://github.com/srsran/srsRAN_4G.git && \
    cd srsRAN_4G && \
    git checkout release_22_04 && \
    mkdir build && cd build && \
    cmake ../ -DENABLE_BLADERF=ON && \
    make -j$(nproc) && make install && \
    ldconfig

# Install srsRAN configuration files
RUN cd srsRAN_4G/build && srsran_install_configs.sh service

# Set environment variable for UHD images (if using USRP devices)
ENV UHD_IMAGES_DIR=/usr/share/uhd/images/

# Set work directory
WORKDIR /mnt/srsue

# Copy the initialization script into the container
COPY srsue_init.sh /mnt/srsue/srsue_init.sh
RUN chmod +x /mnt/srsue/srsue_init.sh

# Copy configuration templates into the container
COPY bladerf_ue.conf /mnt/srsue/bladerf_ue.conf

# Entry point
CMD ["./srsue_init.sh"]
