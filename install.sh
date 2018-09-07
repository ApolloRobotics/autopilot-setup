#!/bin/bash

# Helper function for running a script as a user, in their home directory.
# Arg1: user
# Arg2: script
run_script_as() {
  sudo -H -u $1 bash -c "cd ~ && bash" < $2
}

# Create user account and required permissions
USER_NAME="apollo"
export $USER_NAME
adduser --disabled-password --gecos "" $USER_NAME
usermod -a -G sudo,uucp,dialout,video $USER_NAME
usermod -a -G uucp,dialout,video root

# Remove default user accounts
sudo userdel -rfRZ nvidia
sudo userdel -rfRZ ubuntu

# Update and install system dependancies 
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update && apt-get upgrade -y
sudo apt-get install -yq curl screen python-dev build-essential cmake lm-sensors git vim dnsmasq
#TODO: Verify
#sudo apt-get install -yq ppp sshpass 
#TODO: Verify
#sudo apt-get install -yq libxml2-dev libxslt1-dev libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libusb-1.0-0-dev libswscale-dev python-numpy libtbb2 libtbb-dev libpng-dev libjpeg-dev libtiff-dev libjasper-dev libdc1394-22-dev python-gst0.10 icecast2

run_script_as root redis-setup.sh
run_script_as $USER_NAME python-setup.sh
run_script_as $USER_NAME node-setup.sh
run_script_as root ros-setup.sh
run_script_as $USER_NAME ouster-setup.sh
run_script_as $USER_NAME autopilot-core-setup.sh
# dev only
run_script_as $USER_NAME sh-env-setup.sh
