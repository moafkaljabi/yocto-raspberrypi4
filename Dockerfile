# ============================================
# Dockerfile: Yocto build environment for Raspberry Pi 4B
# Base: Ubuntu 22.04 (tested with Yocto Kirkstone)
# Goal: Build Linux images with embedded support (IIO, serial, etc.)
# ============================================

# Use official Ubuntu LTS as base
FROM ubuntu:22.04

# Set environment
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TZ=Etc/UTC

# --------------------------------------------
# Install required packages for Yocto build
# --------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    gawk wget git-core diffstat unzip texinfo gcc make \
    chrpath socat cpio python3 python3-pip python3-pexpect \
    xz-utils debianutils iputils-ping python3-git \
    build-essential locales sudo curl nano rsync \
    python3-requests python3-jinja2 python3-subunit \
    quilt libncurses5-dev zstd lz4 python3-distutils \
    file bc bison flex ccache && \
    rm -rf /var/lib/apt/lists/*

# Set up locale
RUN locale-gen en_US.UTF-8

# --------------------------------------------
# Create a non-root user for building
# Yocto should never be run as root
# --------------------------------------------
ARG USERNAME=yocto
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && usermod -aG sudo $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to non-root user
USER $USERNAME
WORKDIR /home/$USERNAME

# --------------------------------------------
# Environment variables for Yocto
# --------------------------------------------
ENV BUILDDIR=/home/$USERNAME/yocto-build
ENV POKYDIR=/home/$USERNAME/poky

# Create build directory
RUN mkdir -p $BUILDDIR

# --------------------------------------------
# Clone Yocto Poky, meta-raspberrypi, meta-openembedded
# Pin to Kirkstone release
# --------------------------------------------
RUN git clone -b kirkstone https://git.yoctoproject.org/git/poky.git $POKYDIR \
    && git clone -b kirkstone https://github.com/agherzan/meta-raspberrypi.git $POKYDIR/../meta-raspberrypi \
    && git clone -b kirkstone https://github.com/openembedded/meta-openembedded.git $POKYDIR/../meta-openembedded

# Optional: clone ADI/meta-iio layer if needed
# RUN git clone -b kirkstone https://github.com/analogdevicesinc/meta-adi.git $POKYDIR/../meta-iio

# --------------------------------------------
# Add helpful aliases
# --------------------------------------------
RUN echo "alias goyo='source $POKYDIR/oe-init-build-env $BUILDDIR'" >> /home/$USERNAME/.bashrc

# Set working directory to build dir
WORKDIR $BUILDDIR

# ============================================
# Notes for user after container starts:
# 1. Run: goyo
# 2. Edit build/conf/local.conf & bblayers.conf
#    - Set MACHINE = "raspberrypi4-64"
#    - Add extra packages for IIO support:
#        IMAGE_INSTALL_append = " iio-utils libiio python3-libiio "
#    - Add serial support if needed:
#        IMAGE_INSTALL_append = " setserial "
# 3. Build minimal image:
#        bitbake core-image-minimal
# 4. Output images will be under build/tmp/deploy/images/raspberrypi4-64/
# ============================================

# Default command: open bash
CMD ["/bin/bash"]

