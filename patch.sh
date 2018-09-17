#!/bin/bash
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export ROOTDIR=$1/Linux_for_Tegra/rootfs
export INSTALLER_DIR=/root/autopilot-setup

# Download projects
git clone --depth=1 git@github.com:ApolloRobotics/tma-service-registry.git $SCRIPT_DIR/repos/tma-service-registry && rm -rf $_/.git
git clone --depth=1 git@github.com:ApolloRobotics/tma-gateway.git $SCRIPT_DIR/repos/tma-gateway && rm -rf $_/.git
git clone --depth=1 git@github.com:ApolloRobotics/flight-stack.git $SCRIPT_DIR/repos/flight-stack && rm -rf $_/.git

# Copy projects to the sample root filesystem
sudo mkdir -p $ROOTDIR/$INSTALLER_DIR/
sudo cp -r $SCRIPT_DIR/target/* $ROOTDIR/$INSTALLER_DIR/
sudo cp -r $SCRIPT_DIR/repos $ROOTDIR/$INSTALLER_DIR/

# Auto start installer on first boot
command="sudo -H -u root bash -c 'cd $INSTALLER_DIR && bash $INSTALLER_DIR/install.sh >> /var/log/apollo-setup.log 2>&1'"
file=$ROOTDIR/etc/systemd/nvfb.sh
grep -qF "$command" "$file"  || echo "$command" | sudo tee --append "$file"
