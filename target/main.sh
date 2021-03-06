#!/bin/bash

# Define global vars
export INSTALLER_DIR=/root/autopilot-setup

# Fix path when run from cron
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games


# Helper function for running a script as a user, in their home directory.
# Arg1: user
# Arg2: script
run_script_as() {
  sudo -H -u $1 bash -c "cd ~ && bash" < $2
}

# Wait for internet connection
bash ./connect.sh

# Add additional repos and update
export DEBIAN_FRONTEND=noninteractive 
sudo apt-get update
yes "yes" | apt-get -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade


# Remove automatic running of this file
crontab -l | grep -v "@reboot sudo -H -u root bash -c 'cd $INSTALLER_DIR && bash $INSTALLER_DIR/main.sh >> /var/log/apollo-setup.log 2>&1'"  | crontab -

# Update and install system dependancies 
export DEBIAN_FRONTEND=noninteractive
sudo apt-get install -y curl screen python-dev build-essential cmake git vim dnsmasq
#TODO: Verify Note: I did not install any of these on the TX2 and it seems to be working just fine.
#sudo apt-get install -yq ppp sshpass 
#TODO: Verify Note: I did not install any of these on the TX2 and it seems to be working just fine.
#sudo apt-get install -yq libxml2-dev libxslt1-dev libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libusb-1.0-0-dev libswscale-dev python-numpy libtbb2 libtbb-dev libpng-dev libjpeg-dev libtiff-dev libjasper-dev libdc1394-22-dev python-gst0.10 icecast2

# Move required files for autopilot-core to user
export COREDIR=/home/$USER_NAME/workspace/
mkdir -p $COREDIR/autopilot-core
mv $INSTALLER_DIR/repos/* $COREDIR/autopilot-core
chown -R $USER_NAME:$USER_NAME $COREDIR

# Add Apollo wallpaper to the default location
mv $INSTALLER_DIR/wallpaper.png /usr/share/backgrounds
chown -R $USER_NAME:$USER_NAME /usr/share/backgrounds

# Install modules
bash $INSTALLER_DIR/modules/ros-setup.sh $USER_NAME 
run_script_as root $INSTALLER_DIR/modules/redis-setup.sh
run_script_as $USER_NAME $INSTALLER_DIR/modules/python-setup.sh
run_script_as $USER_NAME $INSTALLER_DIR/modules/node-setup.sh
run_script_as $USER_NAME $INSTALLER_DIR/modules/ouster-setup.sh
run_script_as $USER_NAME $INSTALLER_DIR/modules/serialnumber.sh
run_script_as $USER_NAME $INSTALLER_DIR/modules/autopilot-core-setup.sh
# dev env only
run_script_as $USER_NAME $INSTALLER_DIR/modules/sh-env-setup.sh
sudo apt install -y terminator

# Remove default user accounts
sudo userdel -rfRZ nvidia
sudo userdel -rfRZ ubuntu

# Clean up
sudo apt autoremove -y
rm -rf /root/autopilot-setup

# This line must match the line in install.sh
echo "Completed installation, rebooting device. You may now close this window"
reboot
