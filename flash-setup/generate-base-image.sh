#!/bin/bash 

# Prevent running as sudo, and preload the authentication
if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root"
  exit 1
else
  echo "Some parts of this script require root privilege please enter your password to continue"
  sudo true
fi

# Confirm Jetpack is installed
read -p "Please confirm. Has the device already been flashed and installed Jetpack? (y/n)" -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Please flash and install jetpack."
    exit 0
fi

# Copy setup files to home folder
scp -r ../base-setup apollo@tegra-ubuntu.local:~

# SSH into device
ssh -t apollo@tegra-ubuntu.local 'cd base-setup; sudo ./install.sh >> /var/log/apollo-setup.log 2>&1'

# SSH into the tegra, show the logs, and wait for the install to complete
ssh_host="apollo@tegra-ubuntu.local"
ssh_port="-p 22"
ssh_options="-q -o ConnectTimeout=10 -o BatchMode=yes -o StrictHostKeyChecking=no"
ssh_cmd="tail -f /var/log/apollo-setup.log"
ssh_log="ssh $ssh_options $ssh_port $ssh_host $ssh_cmd"

install_complete="false"
while true; do
    echo "Waiting for device..."

    while read LOGLINE; do
        echo $LOGLINE
        # This line must match the line in main.sh
        if [ "${LOGLINE}" == "Completed installation, rebooting device. You may now close this window" ]; then install_complete="true" && break; fi
    done < <($ssh_log)

    if [ "$install_complete" = "true" ]; then break; fi
    sleep 5
done

# Wait for user to place tegra into recovery and create image
read -p "Place tegra into recovery mode (while holding the recovery button, press reset) then enter y" -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Cannot create image."
    exit 0
fi

# Create flash image
sudo ./flash.sh -r -k APP -G system.img orbitty mmcblk0p1

# Flash the image
sudo ./flash.sh -r orbitty mmcblk0p1

exit 0