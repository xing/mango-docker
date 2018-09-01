FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

#=============
# Set WORKDIR
#=============
WORKDIR /root

#==================
# General Packages
#------------------
# openjdk-8-jdk
#   Java
# ca-certificates
#   SSL client
# tzdata
#   Timezone
# zip
#   Make a zip file
# unzip
#   Unzip zip file
# curl
#   Transfer data from or to a server
# wget
#   Network downloader
# libqt5webkit5
#   Web content engine (Fix issue in Android)
# libgconf-2-4
#   Required package for chrome and chromedriver to run on Linux
# xvfb
#   X virtual framebuffer
# xterm
#   Terminal emulator
# supervisor
#   Process manager
# socat
#   Port forwarder
#------------------
#  NoVNC Packages
#------------------
# x11vnc
#   VNC server for X display
# openbox
#   Windows manager
# menu
#   Debian menu
# python-numpy
#   Numpy, For faster performance: https://github.com/novnc/websockify/issues/77
# net-tools
#   Netstat
#------------------
#  Video Recording
#------------------
# ffmpeg
#   Video recorder
# jq
#   Sed for JSON data
#------------------
#    KVM Package
# for emulator x86
# https://help.ubuntu.com/community/KVM/Installation
#------------------
# qemu-kvm
# libvirt-bin
# ubuntu-vm-builder
# bridge-utils
#==================
RUN apt-get -qqy update && apt-get -qqy install --no-install-recommends \
    openjdk-8-jdk \
    ca-certificates \
    tzdata \
    zip \
    unzip \
    curl \
    python3 \
    wget \
    libqt5webkit5 \
    libgconf-2-4 \
    xvfb \
    xterm \
    menu \
    net-tools \
    ffmpeg \
    jq \
    libvirt-bin \
    bridge-utils \
    gnupg \
    build-essential \
    libcurl4-gnutls-dev \
    libmysqld-dev \
    libsqlite3-dev \
    libsodium-dev \
    libxml2-dev \
    libxslt1-dev \
    git \
    ssh-client \
 && rm -rf /var/lib/apt/lists/*

#===============
# Set JAVA_HOME
#===============
ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre" \
    PATH=$PATH:$JAVA_HOME/bin


#=====================
# Install Android SDK and SDK packages
#=====================
ARG ANDROID_BUILD_TOOLS_VERSION=27.0.3
ARG ANDROID_PLATFORM_VERSION="android-27"
ARG SDK_VERSION=sdk-tools-linux-4333796

ENV SDK_VERSION=$SDK_VERSION \
    ANDROID_BUILD_TOOLS_VERSION=$ANDROID_BUILD_TOOLS_VERSION \
    ANDROID_HOME=/root

RUN wget -O tools.zip https://dl.google.com/android/repository/${SDK_VERSION}.zip && \
    unzip tools.zip && rm tools.zip && \
    chmod a+x -R $ANDROID_HOME && \
    chown -R root:root $ANDROID_HOME

ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin

ARG ANDROID_VERSION=8.1
ARG API_LEVEL=27
ARG BROWSER=chrome
ENV ANDROID_VERSION=$ANDROID_VERSION \
    API_LEVEL=$API_LEVEL \
    BROWSER=$BROWSER

ENV PATH ${PATH}:${ANDROID_HOME}/build-tools

RUN mkdir -p ~/.android && \
    touch ~/.android/repositories.cfg && \
    echo y | sdkmanager "platform-tools" && \
    echo y | sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION" && \
    echo y | sdkmanager "platforms;$ANDROID_PLATFORM_VERSION" && \
    echo y | sdkmanager "platforms;android-${API_LEVEL}"

ENV PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools

#=======
# Set timezone
#=======
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#========
# Giving read/write access to all the future folders and files created by docker container
#========
RUN echo 'umask 000' >> /root/.profile
