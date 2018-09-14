# Autopilot Setup 

## Prerequisites 
1. Ubuntu 14.04 or later. 
2. At least 28GB free disk space
3. Tegra pluged into Host machine and in recovery mode. Check with `lsusb` if Nvidia shows up then it's good. 
4. User must have access to the core autopilot repos and have their SSH key added to their github account. https://help.github.com/articles/connecting-to-github-with-ssh/

## Note
This repo is over 1gb in download size and could temporarily take up to 28GB of diskspace. 

## Install
1. `git clone git@github.com:ApolloRobotics/autopilot-setup.git autopilot-setup && cd $_ && bash install.sh`
