#!/bin/bash

# This script is responsible for:
# 1. Updating the system 
# 2. Installing all system dependancies 
# 3. Making changes to system configuration

# Import utilities
source ../lib/logger.sh
source ../lib/connect.sh
source ../lib/constants.sh
source ../lib/autorun.sh

# Sets scripts path
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games

# Set Timezone to LA
debug "Setting timezone to Los Angeles"
sudo timedatectl set-timezone America/Los_Angeles

# Create user account and required permissions
debug "Create apollo user"
export USER_NAME="apollo"
adduser --disabled-password --gecos "" $USER_NAME
usermod -a -G sudo,uucp,dialout,video,adm $USER_NAME
usermod -a -G uucp,dialout,video root
echo "$USER_NAME:ElonMusk13"|chpasswd

# SSH Hardening
debug "Securing SSH"
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
yes | sudo -H -u $USER_NAME bash -c 'ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa'
cat /home/$USER_NAME/.ssh/id_rsa.pub
cat $INSTALLER_DIR/base-setup/authorized_keys >> /root/.ssh/authorized_keys
cat $INSTALLER_DIR/base-setup/authorized_keys >> /home/$USER_NAME/.ssh/authorized_keys
sudo chown $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh/authorized_keys
sed -i 's/\<Port 22\>/Port 22022/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sudo service ssh restart

# Wait for internet connection
debug "Waiting for internet..."
wait_for_connection

# Update and install system dependancies 
debug "Apt update & upgrade"
export DEBIAN_FRONTEND=noninteractive 
mv sources.list /etc/apt/
sudo apt-get update
yes "yes" | apt-get -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade

# Update cmake
debug "Update CMake"
cd $HOME
git clone --depth=1 https://github.com/Kitware/CMake.git
cd CMake
./bootstrap && make -j4 && sudo make install && cd $HOME && rm -rf CMake

# Run the main script on reboot
# Create cron job non-iteractively (also without risk of duplication)
# https://stackoverflow.com/questions/878600/how-to-create-a-cron-job-using-bash-automatically-without-the-interactive-editor
# Ended up not using the above solution in favor of a much simpler one. Add the script to cron, have the script remove itself from cron.
#enable_on_boot $INSTALLER_DIR main.sh

# Make setup files executable
debug "Making setup files executable"
find . -name '*.sh' -type f | xargs chmod +x

debug "Rebooting, please wait. Install is still in progress"
#reboot
