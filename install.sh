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
  sed -i "s/^connection_string=.*/connection_string=\"nmcli d wifi connect '$wifi_ssid' password '$wifi_password'\"/g" ./target/connect.sh
else 
  exit 1;
fi

# Generate ssh key if one doesn't exist
if [ ! -f $HOME/.ssh/id_rsa.pub ]; then
    echo "ssh key not found! Creating..."
    ssh-keygen -t rsa -N "" -f $HOME/.ssh/id_rsa
fi

# Add ssh key to authorized keys file if not present
public_key=`cat $HOME/.ssh/id_rsa.pub`
grep -q -F "$public_key" ./target/authorized_keys || echo "$public_key" >> ./target/authorized_keys

echo "Flashing $device"

# Define script location variables
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export L4T=$device/Linux_for_Tegra

# Set up L4T and apply patches if it hasn't been done already
if [ ! -d "$device" ]; then
  mkdir $device 
fi 
cd $device

if [ ! -d "$SCRIPT_DIR/$L4T" ]; then

  # Mirror for Nvidia files
  export FILE_SERVER="https://s3.us-east-2.amazonaws.com/apollorobotics-public/nvidia-files"

  # Device version
  export tx1_version="24.2.3"
  export tx2_version="28.2.1"
  device_version=${device}_version

  # Driver pack device suffix
  export tx1_suffix="210"
  export tx2_suffix="186"
  device_suffix=${device}_suffix

  # Computed file names for flashing files
  export DRIVER_ARCHIVE="Tegra${!device_suffix}_Linux_R${!device_version}_aarch64.tbz2"
  export SAMPLE_ROOTFS="Tegra_Linux_Sample-Root-Filesystem_R${!device_version}_aarch64.tbz2"

  # Download Nvidia flashing files
  if [ ! -f $SCRIPT_DIR/$device/$DRIVER_ARCHIVE ]; then
      wget $FILE_SERVER/$DRIVER_ARCHIVE
  fi
  if [ ! -f $SCRIPT_DIR/$device/$SAMPLE_ROOTFS ]; then
      wget $FILE_SERVER/$SAMPLE_ROOTFS
  fi

  # Unpack Drivers
  tar xjvf $SCRIPT_DIR/$device/$DRIVER_ARCHIVE --directory $SCRIPT_DIR/$device

  # Unpack sample filesystem
  cp $SCRIPT_DIR/$device/$SAMPLE_ROOTFS $SCRIPT_DIR/$L4T/rootfs && cd $_
  sudo tar xjvf $SCRIPT_DIR/$L4T/rootfs/$SAMPLE_ROOTFS 
  rm $SCRIPT_DIR/$L4T/rootfs/$SAMPLE_ROOTFS

  # Install drivers to sample filesystem
  sudo $SCRIPT_DIR/$L4T/apply_binaries.sh

  # Patch L4T
  cd $SCRIPT_DIR && bash $SCRIPT_DIR/patch.sh $device
fi

# Flash L4T
cd $SCRIPT_DIR/$L4T

# Modifies line 503 of flash.sh to tell mkfs.ext4 to NOT use "64bit" or "metadata_csum"
original_flash='mkfs -t $4 "${loop_dev}"'
modified_flash='mkfs -t $4 -O ^metadata_csum,^64bit "${loop_dev}"'
sed -i "s/$original_flash/$modified_flash/g" ./flash.sh

# Start the flashing
if [ "$device" == "tx1" ]; then
  sudo ./flash.sh -S 14580MiB jetson-tx1 mmcblk0p1
elif [ "$device" == "tx2" ]; then
  sudo ./flash.sh -S 29318MiB jetson-tx2 mmcblk0p1
else 
  echo "Device $device not supported"
fi
