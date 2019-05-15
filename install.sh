#!/bin/bash

# Prevent running as sudo, and preload the authentication
if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root"
  exit 1
else
  echo "Some parts of this script require root privilege please enter your password to continue"
  sudo true
fi

# Select the device type
PS3='Please enter your choice: '
options=("tx1" "tx2" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "${options[0]}")
            device="${options[0]}"
            break
            ;;
        "${options[1]}")
            device="${options[1]}"
            break;
            ;;
        "${options[2]}")
            exit 0
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

# Select the connection type
PS3='Please enter your choice: '
options=("Ethernet" "WiFi" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "${options[0]}")
            connection_type="${options[0]}"
            break
            ;;
        "${options[1]}")
            connection_type="${options[1]}"
            break;
            ;;
        "${options[2]}")
            exit 0
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

# Set up connection string
if [ $connection_type = "Ethernet" ]; then
  echo "Please ensure ethernet is connected to device"
  read -p "Press enter to continue"
elif [ $connection_type = "WiFi" ]; then
  read -p "WiFI SSID (Case sensitive): " wifi_ssid
  read -p "WiFI Password (Case sensitive): " wifi_password
  SSID="$wifi_ssid" PASSWORD="$wifi_password" perl -pi -e 's/connection_string=""/connection_string='\''nmcli d wifi connect "$ENV{SSID}" password "$ENV{PASSWORD}"'\''/g' ./target/connect.sh
else 
  exit 1;
fi

# Generate ssh key if one doesn't exist
echo "[INSTALL.SH] Checking for ssh key"
if [ ! -f $HOME/.ssh/id_rsa.pub ]; then
    echo "ssh key not found! Creating..."
    ssh-keygen -t rsa -N "" -f $HOME/.ssh/id_rsa
    echo Add the following ssh-key to your github setting and re-run:
    cat $HOME/.ssh/id_rsa.pub
    exit 0
fi

# Add ssh key to authorized keys file if not present
echo "[INSTALL.SH] Adding your ssh key to target device"
public_key=`cat $HOME/.ssh/id_rsa.pub`
grep -q -F "$public_key" ./target/authorized_keys || echo "$public_key" >> ./target/authorized_keys

# Define script location variables
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export L4T=$device/Linux_for_Tegra

# Set up L4T and apply patches if it hasn't been done already
echo "[INSTALL.SH] Checking for existing nvidia files"
if [ ! -d "$device" ]; then
  mkdir $device 
fi 
cd $device

echo "[INSTALL.SH] Checking for extracted nvidia files"
if [ ! -d "$SCRIPT_DIR/$L4T" ]; then

  # Mirror for Nvidia files
  export FILE_SERVER="https://s3.us-east-2.amazonaws.com/apollorobotics-public/nvidia-files"

  # Device version
  export tx1_version="28.2.1"
  export tx2_version="28.2.0"
  device_version=${device}_version

  # Driver pack device suffix
  export tx1_suffix="210"
  export tx2_suffix="186"
  device_suffix=${device}_suffix

  # ConnectTech BSP
  export tx1_bsp="https://s3.us-east-2.amazonaws.com/apollorobotics-public/nvidia-files/CTI-L4T-V020.tgz"
  export tx2_bsp="https://s3.us-east-2.amazonaws.com/apollorobotics-public/nvidia-files/CTI-L4T-V121.tgz"
  device_bsp=${device}_bsp

  # Computed file names for flashing files
  export DRIVER_ARCHIVE="Tegra${!device_suffix}_Linux_R${!device_version}_aarch64.tbz2"
  export SAMPLE_ROOTFS="Tegra_Linux_Sample-Root-Filesystem_R${!device_version}_aarch64.tbz2"

  # Download Nvidia flashing files
  echo "[INSTALL.SH] Checking for drivers and sample rootfs"
  if [ ! -f $SCRIPT_DIR/$device/$DRIVER_ARCHIVE ]; then
      echo "[INSTALL.SH] Drivers not found. Downloading"
      wget $FILE_SERVER/$DRIVER_ARCHIVE
  fi
  if [ ! -f $SCRIPT_DIR/$device/$SAMPLE_ROOTFS ]; then
      echo "[INSTALL.SH] Rootfs not found. Downloading"
      wget $FILE_SERVER/$SAMPLE_ROOTFS
  fi

  # Unpack Drivers
  echo "[INSTALL.SH] Extracting drivers"
  tar xjvf $SCRIPT_DIR/$device/$DRIVER_ARCHIVE --directory $SCRIPT_DIR/$device

  # Unpack sample filesystem
  echo "[INSTALL.SH] Extracting rootfs"
  cp $SCRIPT_DIR/$device/$SAMPLE_ROOTFS $SCRIPT_DIR/$L4T/rootfs && cd $_
  sudo tar xjvf $SCRIPT_DIR/$L4T/rootfs/$SAMPLE_ROOTFS 
  rm $SCRIPT_DIR/$L4T/rootfs/$SAMPLE_ROOTFS

  # Install drivers to sample filesystem
  echo "[INSTALL.SH] Installing drivers"
  sudo $SCRIPT_DIR/$L4T/apply_binaries.sh

  # Install ConnectTech BSP
  echo "[INSTALL.SH] Installing ConnectTech BSP"
  cd $SCRIPT_DIR/$L4T
  wget ${!device_bsp}
  tar -xzf $(basename "${!device_bsp}")
  cd $SCRIPT_DIR/$L4T/CTI-L4T
  sudo $SCRIPT_DIR/$L4T/CTI-L4T/install.sh

  # Patch L4T
  cd $SCRIPT_DIR && bash $SCRIPT_DIR/patch.sh $device
else 
  echo "[INSTALL.SH] Nvidia files found. Using existing. Delete /${device} to clean."
fi

# Flash L4T
cd $SCRIPT_DIR/$L4T

# Start the flashing
if [ "$device" == "tx1" ]; then
  echo "[INSTALL.SH] Flashing tx1"
  sudo ./flash.sh -S 14580MiB jetson-tx1 mmcblk0p1
elif [ "$device" == "tx2" ]; then
  echo "[INSTALL.SH] Flashing tx2"
  sudo ./flash.sh orbitty mmcblk0p1
else 
  echo "Device $device not supported"
fi

# SSH into the tegra, show the logs, and wait for the install to complete
ssh_host="apollo@tegra-ubuntu.local"
ssh_port="-p 22022"
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

exit 0