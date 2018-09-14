#!/bin/bash

# Prevent running as sudo, and preload the authentication
if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root"
  exit 1
else
  echo "Some parts of this script require root privilege please enter your password to continue"
  sudo true
fi

# Define script location variables
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export ROOTFS=Linux_for_Tegra/rootfs

# Set up L4T and apply patches if it hasn't been done already
if [ ! -d "Linux_for_Tegra" ]; then

  export FILE_SERVER="https://s3.us-east-2.amazonaws.com/apollorobotics-public/nvidia-files"
  export ver="28.2.1"
  export DRIVER_ARCHIVE="Tegra186_Linux_R${ver}_aarch64.tbz2"
  export SAMPLE_ROOTFS="Tegra_Linux_Sample-Root-Filesystem_R${ver}_aarch64.tbz2"

  # Download Nvidia flashing files
  if [ ! -f $SCRIPT_DIR/$DRIVER_ARCHIVE ]; then
      wget $FILE_SERVER/$DRIVER_ARCHIVE
  fi
  if [ ! -f $SCRIPT_DIR/$SAMPLE_ROOTFS ]; then
      wget $FILE_SERVER/$SAMPLE_ROOTFS
  fi

  # Unpack Drivers
  tar xjvf $SCRIPT_DIR/$DRIVER_ARCHIVE

  # Unpack sample filesystem
  cp $SCRIPT_DIR/$SAMPLE_ROOTFS $SCRIPT_DIR/Linux_for_Tegra/rootfs && cd $_
  sudo tar xjvf $SCRIPT_DIR/Linux_for_Tegra/rootfs/$SAMPLE_ROOTFS
  rm $SCRIPT_DIR/Linux_for_Tegra/rootfs/$SAMPLE_ROOTFS

  # Install drivers to sample filesystem
  sudo $SCRIPT_DIR/Linux_for_Tegra/apply_binaries.sh

  # Patch L4T
  cd $SCRIPT_DIR && bash $SCRIPT_DIR/patch.sh
fi

# Flash L4T
cd $SCRIPT_DIR/Linux_for_Tegra
sudo ./flash.sh jetson-tx2 mmcblk0p1
