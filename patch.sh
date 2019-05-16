#!/bin/bash
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export ROOTDIR=$1/Linux_for_Tegra/rootfs
export INSTALLER_DIR=/root/autopilot-setup

# Download projects
echo -e "\033[41m[PATCH.SH] Downloading repos\033[0m"
git clone --depth=1 git@gitlab.com:apollorobotics/fos/fos-service-registry.git $SCRIPT_DIR/repos/fos-service-registry && rm -rf $_/.git
git clone --depth=1 git@gitlab.com:apollorobotics/fos/fos-gateway.git $SCRIPT_DIR/repos/fos-gateway && rm -rf $_/.git
git clone --depth=1 git@gitlab.com:apollorobotics/fos/fos-status-checks.git $SCRIPT_DIR/repos/fos-status-checks && rm -rf $_/.git
git clone --depth=1 git@gitlab.com:apollorobotics/fos/fos-flight-stack.git $SCRIPT_DIR/repos/fos-flight-stack && rm -rf $_/.git

# Copy projects to the sample root filesystem
echo -e "\033[41m[PATCH.SH] Moving repos to sample rootfs\033[0m"
sudo mkdir -p $ROOTDIR/$INSTALLER_DIR/
sudo cp -r $SCRIPT_DIR/target/* $ROOTDIR/$INSTALLER_DIR/
sudo cp -r $SCRIPT_DIR/repos $ROOTDIR/$INSTALLER_DIR/

# Auto start installer on first boot
command="sudo -H -u root bash -c 'cd $INSTALLER_DIR && bash $INSTALLER_DIR/install.sh >> /var/log/apollo-setup.log 2>&1'"
file=$ROOTDIR/etc/systemd/nvfb.sh
grep -qF "$command" "$file"  || echo "$command" | sudo tee --append "$file"
