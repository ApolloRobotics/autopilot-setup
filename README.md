# Autopilot Setup 

## Install
1. clone this repo into root user's home and cd into the directory
2. `bash install.sh`
3. (temporary) After a while you will be prompted: `Are you sure you want to continue connecting (yes/no)?` follow steps 4-5 then select yes
3. (temporary) While the script is running, open a new window, log in as 'apollo' run: `ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa`
4. (temporary) run `cat ~/.ssh/id_rsa.pub` copy the output and add it to github ssh keys

Note: Steps 3-5 are necessary until the autopilot core repos are made public 
