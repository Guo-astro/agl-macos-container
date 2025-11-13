# Copyright (C) 2015-2016 Intel Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

# Since this Dockerfile is used in multiple images, force the builder to
# specify the BASE_DISTRO. This should hopefully prevent accidentally using
# a default, when another distro was desired.
ARG BASE_DISTRO=SPECIFY_ME

FROM crops/yocto:$BASE_DISTRO-base

USER root

ADD https://raw.githubusercontent.com/crops/extsdk-container/master/restrict_useradd.sh  \
        https://raw.githubusercontent.com/crops/extsdk-container/master/restrict_groupadd.sh \
        https://raw.githubusercontent.com/crops/extsdk-container/master/usersetup.py \
        /usr/bin/
COPY distro-entry.sh poky-entry.py poky-launch.sh /usr/bin/
COPY sudoers.usersetup /etc/

# For ubuntu, do not use dash.
RUN which dash &> /dev/null && (\
    echo "dash dash/sh boolean false" | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash) || \
    echo "Skipping dash reconfigure (not applicable)"

# Install AGL development dependencies
# AGL requires additional packages for automotive-specific features
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    # Graphics and Wayland support for AGL compositor
    libwayland-dev \
    wayland-protocols \
    libwayland-egl1-mesa \
    # Qt5 dependencies for AGL HMI (legacy/stable)
    qtbase5-dev \
    qtdeclarative5-dev \
    qtwayland5 \
    # Qt6 dependencies for modern AGL development
    qt6-base-dev \
    qt6-declarative-dev \
    qt6-wayland \
    qt6-wayland-dev \
    libqt6core6 \
    libqt6gui6 \
    libqt6widgets6 \
    libqt6qml6 \
    libqt6quick6 \
    # Audio support (ALSA, PulseAudio, PipeWire)
    libasound2-dev \
    libpulse-dev \
    pipewire \
    libpipewire-0.3-dev \
    # Multimedia frameworks
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer-plugins-bad1.0-dev \
    # CAN bus support for automotive communication
    can-utils \
    # Security and AppArmor for AGL security framework
    libapparmor-dev \
    apparmor-utils \
    # Systemd for service management
    libsystemd-dev \
    # JSON parsing for AGL APIs
    libjson-c-dev \
    libjansson-dev \
    # WebSockets for AGL application framework
    libwebsockets-dev \
    # OpenSSL for secure communications
    libssl-dev \
    # XML parsing
    libxml2-dev \
    libxslt1-dev \
    # D-Bus for IPC
    libdbus-1-dev \
    # Additional build tools
    ninja-build \
    cmake \
    meson \
    # Documentation tools
    doxygen \
    graphviz \
    # Testing frameworks
    libgtest-dev \
    libgmock-dev \
    # Python dependencies for AGL
    python3-pip \
    python3-jinja2 \
    python3-subunit \
    # Additional utilities
    vim \
    nano \
    # Clean up to reduce image size
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# We remove the user because we add a new one of our own.
# The usersetup user is solely for adding a new user that has the same uid,
# as the workspace. 70 is an arbitrary *low* unused uid on debian.
RUN userdel -r yoctouser && \
    mkdir /home/yoctouser && \
    groupadd -g 70 usersetup && \
    useradd -N -m -u 70 -g 70 usersetup && \
    chmod 755 /usr/bin/usersetup.py \
        /usr/bin/poky-entry.py \
        /usr/bin/poky-launch.sh \
        /usr/bin/restrict_groupadd.sh \
        /usr/bin/restrict_useradd.sh && \
    echo "#include /etc/sudoers.usersetup" >> /etc/sudoers

USER usersetup
ENV LANG=en_US.UTF-8

ENTRYPOINT ["/usr/bin/distro-entry.sh", "/usr/bin/dumb-init", "--", "/usr/bin/poky-entry.py"]
