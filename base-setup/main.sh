#!/bin/bash

# This script is responsible for:
# 1. Installing apt packages
# 2. Building and installing all needed dependancies

# Import utilities
source ../lib/logger.sh
source ../lib/connect.sh
source ../lib/constants.sh
source ../lib/autorun.sh
source ../lib/run_as.sh
 
# Fix path when run from cron
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games

# Add Apollo wallpaper to the default location
debug "Setting up fstab"
mv $INSTALLER_DIR/base-setup/fstab /etc/fstab

# Wait for internet connection
debug "Waiting for internet connection..."
wait_for_connection

# Add additional repos and update
debug "Apt update & upgrade"
export DEBIAN_FRONTEND=noninteractive 
sudo apt-get update
yes "yes" | apt-get -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade

# Remove automatic running of this file
#disable_on_boot $INSTALLER_DIR main.sh

# Update and install system dependancies 
debug "Installing apt packages"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get install -y curl screen python-dev build-essential cmake git vim dnsmasq
sudo apt-get install -yq libxml2-dev libxslt1-dev libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libusb-1.0-0-dev libswscale-dev python-numpy 
sudo apt-get build-dep -y python3-lxml
# For node to run on port 80
sudo apt-get install -yq libcap2-bin
# Install PCL for loam_ros
sudo apt-get install -yq libpcl-dev 
# libLAS dependancy
sudo apt-get install -yq libgeotiff-dev
# Enable exfat usb devices
sudo apt-get install -yq exfat-utils exfat-fuse

# Install Crow
debug "Installing crow"
cd $HOME
sudo apt-get install libtcmalloc-minimal4 
sudo apt-get install libssl-dev libboost-all-dev # Didn't require these the first time...
sudo ln -s /usr/lib/libtcmalloc_minimal.so.4 /usr/lib/libtcmalloc_minimal.so
git clone --depth=1 https://github.com/ipkn/crow.git
mkdir -p crow/build && cd $_
cmake .. && make -j4
sudo cp -r $HOME/crow/include/* /usr/include/
cd $HOME && rm -rf crow

# Install LibLAS
debug "Installing libLAS"
wget http://download.osgeo.org/liblas/libLAS-1.8.1.tar.bz2
tar xvfj libLAS-*
cd libLAS-*
export LDFLAGS="${LDFLAGS} -pthread"
mkdir build && cd $_
cmake .. && make -j4 && sudo make install
cd $HOME && rm -rf libLAS-*

# Setup libharu
debug "Downloading libharu"
cd $HOME
git clone https://github.com/libharu/libharu.git
debug "Installing libharu"
cd libharu
mkdir build && cd $_
cmake .. && make -j4 && sudo make install
cd $HOME && rm -rf libharu

# Add Apollo wallpaper to the default location
debug "Setting wallpaper"
mv $INSTALLER_DIR/base-setup/wallpaper.png /usr/share/backgrounds
chown -R $USER_NAME:$USER_NAME /usr/share/backgrounds

# Install modules
debug "Installing modules"
bash $INSTALLER_DIR/base-setup/modules/ros-setup.sh $USER_NAME 
run_script_as root $INSTALLER_DIR/base-setup/modules/redis-setup.sh
run_script_as $USER_NAME $INSTALLER_DIR/base-setup/modules/python-setup.sh
run_script_as $USER_NAME $INSTALLER_DIR/base-setup/modules/node-setup.sh

# Enable node to run on port 80
debug "Enabling node to run on port 80"
NODE_VERSION=$(sudo -H -i -u apollo bash -c 'which node')
sudo setcap cap_net_bind_service=+ep $NODE_VERSION

# Remove default user accounts
debug "Removing nvidia and ubuntu users"
sudo userdel -rfRZ nvidia
sudo userdel -rfRZ ubuntu

# Clean up
debug "Cleaning up"
sudo apt autoremove -y
for i in $(find /var/log -type f); do cat /dev/null > $i; done
history -c

# This line must match the line in install.sh
echo "Completed installation, rebooting device. You may now close this window"
# reboot
