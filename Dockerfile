FROM joesss/mango-base:crash

ENV DEVICE="Nexus 5X"

ENV DEBIAN_FRONTEND=noninteractive

#=============
# Set WORKDIR
#=============
WORKDIR /root

#============
# Install needed Ubuntu packages
#============
RUN apt-get -qqy update && apt-get -qqy install --no-install-recommends \
    supervisor \
    socat \
    x11vnc \
    openbox \
    python-numpy \
    qemu-kvm \
    ubuntu-vm-builder \
    libssl1.0-dev \
    libreadline-dev \
    cpu-checker \
 && rm -rf /var/lib/apt/lists/*

#=====================
# Install Android images and emulator
#=====================

ARG API_LEVEL=27
ARG SYS_IMG=x86
ARG IMG_TYPE=google_apis

ENV API_LEVEL=$API_LEVEL \
    SYS_IMG=$SYS_IMG \
    IMG_TYPE=$IMG_TYPE

RUN echo y | sdkmanager "system-images;android-${API_LEVEL};${IMG_TYPE};${SYS_IMG}" && \
    echo y | sdkmanager "emulator"

#=========
# Install rbenv and ruby 2.3.1
#=========
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv \
&&  git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build \
&&  git clone https://github.com/jf/rbenv-gemset.git /usr/local/rbenv/plugins/rbenv-gemset \
&&  /usr/local/rbenv/plugins/ruby-build/install.sh
ENV PATH /usr/local/rbenv/bin:$PATH
ENV RBENV_ROOT /usr/local/rbenv

RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh \
&&  echo 'export PATH=/usr/local/rbenv/bin:$PATH' >> /etc/profile.d/rbenv.sh \
&&  echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh

RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /root/.bashrc \
&&  echo 'export PATH=/usr/local/rbenv/bin:$PATH' >> /root/.bashrc \
&&  echo 'eval "$(rbenv init -)"' >> /root/.bashrc

ENV CONFIGURE_OPTS --disable-install-doc
ENV PATH /usr/local/rbenv/bin:/usr/local/rbenv/shims:$PATH

RUN eval "$(rbenv init -)"; rbenv install 2.3.1 \
&&  eval "$(rbenv init -)"; rbenv global 2.3.1 \
&&  eval "$(rbenv init -)"; gem update --system

#=======
# Set an env var
#=======
ENV DOCKER_ENV=1

#=======
# noVNC
#=======
RUN  wget -nv -O noVNC.zip "https://github.com/novnc/noVNC/archive/v1.0.0.zip" \
 && unzip -x noVNC.zip \
 && rm noVNC.zip  \
 && mv noVNC-1.0.0 noVNC \
 && wget -nv -O websockify.zip "https://github.com/novnc/websockify/archive/v0.8.0.zip" \
 && unzip -x websockify.zip \
 && mv websockify-0.8.0 ./noVNC/utils/websockify \
 && rm websockify.zip \
 && ln noVNC/vnc.html noVNC/index.html

#================================================
# noVNC Default Configurations
# These Configurations can be changed through -e
#================================================
ENV DISPLAY=:0 \
    SCREEN=0 \
    SCREEN_WIDTH=1600 \
    SCREEN_HEIGHT=900 \
    SCREEN_DEPTH=16 \
    LOCAL_PORT=5900 \
    TARGET_PORT=6080 \
    TIMEOUT=1 \
    VIDEO_PATH=/tmp/video \
    LOG_PATH=/var/log/supervisor

#===============
# Expose noVNC port
#===============
EXPOSE 6080
 
#======================
# Add Emulator Devices
#======================
COPY devices /root/devices

#===================
# Run emulator state
#===================
COPY src /root/src
COPY supervisord.conf /root/

RUN chmod -R +x /root/src && chmod +x /root/supervisord.conf

HEALTHCHECK --timeout=10s \
    CMD timeout 40 adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done'

CMD /usr/bin/supervisord --configuration supervisord.conf
