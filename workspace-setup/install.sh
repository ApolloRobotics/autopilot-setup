#!/bin/bash

# This script is responsible for:
# 1. Installing Apollo code

# Import utilities
source ../lib/logger.sh
source ../lib/connect.sh
source ../lib/constants.sh
source ../lib/run_as.sh

# Fix path when run from cron
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
export PATH=$PATH:$HOME/.local/bin

# Wait for internet connection
debug "Waiting for internet connection..."
wait_for_connection

# Setting up directories
debug "Setting up directories"
mkdir -p $HOME/workspace/fos
mkdir -p $HOME/workspace/catkin_ws && cd $_
mkdir src
catkin build
echo "source $HOME/workspace/catkin_ws/devel/setup.bash" >> $HOME/.bashrc

# Clone Ouster repo
debug "Downloading ouster"
cd $HOME/workspace
git clone --depth=1 https://github.com/ouster-lidar/ouster_example.git
ln -s $HOME/workspace/ouster_example/ $HOME/workspace/catkin_ws/src

# Setup APX ROS
debug "Downloading Loam APX"
cd $HOME/workspace
git clone --depth=1 git@github.com:/ApolloRobotics/apx_ros.git
ln -s $HOME/workspace/apx_ros $HOME/workspace/catkin_ws/src/

# make the processing application 
debug "Making processing application"
cd $HOME/workspace/apx_ros/process
mkdir build && cd $_
cmake .. && make

# Make all the projects
debug "Building all projects" 
source /opt/ros/kinetic/setup.bash
source $HOME/workspace/catkin_ws/devel/setup.sh
cd $HOME/workspace/catkin_ws
catkin build

# Install FOS

# Make nvm, npm available to the shell. Not sure why this is needed when it already exists in bashrc
source $HOME/.bashrc
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

debug "Downloading repos"
git clone --depth=1 git@gitlab.com:apollorobotics/fos/fos-service-registry.git $HOME/workspace/fos/fos-service-registry && rm -rf $_/.git
git clone --depth=1 git@gitlab.com:apollorobotics/fos/fos-gateway.git $HOME/workspace/fos/fos-gateway && rm -rf $_/.git
git clone --depth=1 git@gitlab.com:apollorobotics/fos/fos-status-checks.git $HOME/workspace/fos/fos-status-checks && rm -rf $_/.git
git clone --depth=1 git@gitlab.com:apollorobotics/fos/fos-flight-stack.git $HOME/workspace/fos/fos-flight-stack && rm -rf $_/.git

# Install projects
debug "Installing service registry"
cd $HOME/workspace/fos/fos-service-registry && npm install
debug "Installing api gateway"
cd $HOME/workspace/fos/fos-gateway && npm install
debug "Installing status checks"
cd $HOME/workspace/fos/fos-status-checks && npm install
debug "Installing flight stack"
cd $HOME/workspace/fos/fos-flight-stack 
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt

# Set environment variables
debug "Creating .env"
echo "NODE_ENV=\"production\"
CLOUD_URI=\"http://api.flightservice.io\"" > $HOME/.env

# Clean up
mv $HOME/workspace-setup/post-flash-setup $HOME
rm -rf $HOME/workspace-setup
rm -rf $HOME/lib
rm $HOME/.ssh/id_rsa*
sudo sh -c 'for i in $(find /var/log -type f); do cat /dev/null > $i; done'
history -c