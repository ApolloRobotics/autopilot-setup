#!/bin/bash

# Define global vars
export USER_NAME="apollo"
export INSTALLER_DIR=/root/autopilot-setup

# Fix path when run from cron
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games


# Helper function for running a script as a user, in their home directory.
# Arg1: user
# Arg2: script
run_script_as() {
  echo -e "\033[42m[TARGET/MAIN.SH] Run $2 as $1\033[0m"
  sudo -H -u $1 bash -c "cd ~ && bash" < $2
}

# Wait for internet connection
echo -e "\033[42m[TARGET/MAIN.SH] Waiting for internet connection...\033[0m"
bash ./connect.sh

# Add additional repos and update
echo -e "\033[42m[TARGET/MAIN.SH] Apt update & upgrade\033[0m"
export DEBIAN_FRONTEND=noninteractive 
sudo apt-get update
yes "yes" | apt-get -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade

# Remove automatic running of this file
echo -e "\033[42m[TARGET/MAIN.SH] Remove auto-start of this file\033[0m"
crontab -l | grep -v "@reboot sudo -H -u root bash -c 'cd $INSTALLER_DIR && bash $INSTALLER_DIR/main.sh >> /var/log/apollo-setup.log 2>&1'"  | crontab -

# Update and install system dependancies 
echo -e "\033[42m[TARGET/MAIN.SH] Installing apt packages\033[0m"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get install -y curl screen python-dev build-essential cmake git vim dnsmasq
#TODO: Verify Note: I did not install any of these on the TX2 and it seems to be working just fine.
#sudo apt-get install -yq ppp sshpass 
#TODO: Verify Note: I did not install any of these on the TX2 and it seems to be working just fine.
sudo apt-get install -yq libxml2-dev libxslt1-dev libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libusb-1.0-0-dev libswscale-dev python-numpy 
#libtbb2 libtbb-dev libpng-dev libjpeg-dev libtiff-dev libjasper-dev libdc1394-22-dev python-gst0.10 icecast2
sudo apt-get build-dep python3-lxml
# For node to run on port 80
sudo apt-get install libcap2-bin
# Install PCL for loam_ros
sudo apt-get install libpcl-dev 
# libLAS dependancy
sudo apt-get install libgeotiff-dev
# Enable exfat usb devices
sudo apt-get install exfat-utils exfat-fuse

# Install Crow
echo -e "\033[42m[TARGET/MAIN.SH] Installing crow\033[0m"
sudo apt-get install libtcmalloc-minimal4 
sudo apt-get install libssl-dev libboost-all-dev # Didn't require these the first time...
sudo ln -s /usr/lib/libtcmalloc_minimal.so.4 /usr/lib/libtcmalloc_minimal.so
git clone --depth=1 https://github.com/ipkn/crow.git
mkdir -p crow/build && cd $_
cmake .. && make -j
sudo cp -r $HOME/crow/include/* /usr/include/
cd $HOME && rm -rf crow

# Install LibLAS
echo -e "\033[42m[TARGET/MAIN.SH] Installing libLAS\033[0m"
wget http://download.osgeo.org/liblas/libLAS-1.8.1.tar.bz2
tar xvfj libLAS-*
cd libLAS-*
export LDFLAGS="${LDFLAGS} -pthread"
mkdir build && cd $_
cmake .. && make -j4 && sudo make install
cd $HOME && rm -rf libLAS-*

# Move required files for autopilot-core to user
echo -e "\033[42m[TARGET/MAIN.SH] Moving fos files into user workspace\033[0m"
export COREDIR=/home/$USER_NAME/workspace/
mkdir -p $COREDIR/autopilot-core
mv $INSTALLER_DIR/repos/* $COREDIR/
mv $COREDIR/fos-* $COREDIR/autopilot-core
chown -R $USER_NAME:$USER_NAME $COREDIR

# Add Apollo wallpaper to the default location
echo -e "\033[42m[TARGET/MAIN.SH] Setting wallpaper\033[0m"
mv $INSTALLER_DIR/wallpaper.png /usr/share/backgrounds
chown -R $USER_NAME:$USER_NAME /usr/share/backgrounds

# Install modules
echo -e "\033[42m[TARGET/MAIN.SH] Installing modules\033[0m"
bash $INSTALLER_DIR/modules/ros-setup.sh $USER_NAME 
run_script_as root $INSTALLER_DIR/modules/redis-setup.sh
run_script_as $USER_NAME $INSTALLER_DIR/modules/python-setup.sh
run_script_as $USER_NAME $INSTALLER_DIR/modules/node-setup.sh
run_script_as $USER_NAME $INSTALLER_DIR/modules/ouster-setup.sh
run_script_as $USER_NAME $INSTALLER_DIR/modules/loam-setup.sh
run_script_as $USER_NAME $INSTALLER_DIR/modules/serialnumber.sh
run_script_as $USER_NAME $INSTALLER_DIR/modules/autopilot-core-setup.sh
# dev env only
run_script_as $USER_NAME $INSTALLER_DIR/modules/sh-env-setup.sh
sudo apt install -y terminator

# Enable node to run on port 80
NODE_VERSION=$(sudo -H -i -u apollo bash -c 'which node')
sudo setcap cap_net_bind_service=+ep $NODE_VERSION

# Remove default user accounts
echo -e "\033[42m[TARGET/MAIN.SH] Removing nvidia and ubuntu users\033[0m"
# sudo userdel -rfRZ nvidia
# sudo userdel -rfRZ ubuntu

# Clean up
echo -e "\033[42m[TARGET/MAIN.SH] CLeaning up install files\033[0m"
sudo apt autoremove -y
rm -rf /root/autopilot-setup

# This line must match the line in install.sh
echo "Completed installation, rebooting device. You may now close this window"
reboot
