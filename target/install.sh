export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
export INSTALLER_DIR=/root/autopilot-setup

# Set Timezone to LA
echo -e "\033[41m[TARGET/INSTALL.SH] Setting timezone\033[0m"
sudo timedatectl set-timezone America/Los_Angeles

# Create user account and required permissions
echo -e "\033[41m[TARGET/INSTALL.SH] Create apollo user\033[0m"
export USER_NAME="apollo"
adduser --disabled-password --gecos "" $USER_NAME
usermod -a -G sudo,uucp,dialout,video,adm $USER_NAME
usermod -a -G uucp,dialout,video root
echo "$USER_NAME:ElonMusk13"|chpasswd

# SSH Hardening
echo -e "\033[41m[TARGET/INSTALL.SH] Securing SSH\033[0m"
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
yes | sudo -H -u $USER_NAME bash -c 'ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa'
cat /home/$USER_NAME/.ssh/id_rsa.pub
cat $INSTALLER_DIR/authorized_keys >> /root/.ssh/authorized_keys
cat $INSTALLER_DIR/authorized_keys >> /home/$USER_NAME/.ssh/authorized_keys
sudo chown $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh/authorized_keys
sed -i 's/\<Port 22\>/Port 22022/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sudo service ssh restart

# Wait for internet connection
echo -e "\033[41m[TARGET/INSTALL.SH] Waiting for internet...\033[0m"
bash ./connect.sh

# Update and install system dependancies 
echo -e "\033[41m[TARGET/INSTALL.SH] Apt update & upgrade\033[0m"
export DEBIAN_FRONTEND=noninteractive 
mv sources.list /etc/apt/
sudo apt-get update
yes "yes" | apt-get -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade

# Run the main script on reboot
# Create cron job non-iteractively (also without risk of duplication)
# https://stackoverflow.com/questions/878600/how-to-create-a-cron-job-using-bash-automatically-without-the-interactive-editor
# Ended up not using the above solution in favor of a much simpler one. Add the script to cron, have the script remove itself from cron.
echo -e "\033[41m[TARGET/INSTALL.SH] Setting up auto-start of main.sh\033[0m"
export INSTALLER_DIR=/root/autopilot-setup
command="sudo -H -u root bash -c 'cd $INSTALLER_DIR && bash $INSTALLER_DIR/main.sh >> /var/log/apollo-setup.log 2>&1'"
job="@reboot $command"
cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -

# Remove this files self-start line 
echo -e "\033[41m[TARGET/INSTALL.SH] Removing this script auto-start\033[0m"
head -n -1 /etc/systemd/nvfb.sh > temp.sh ; mv temp.sh /etc/systemd/nvfb.sh

# Make setup files executable
echo -e "\033[41m[TARGET/INSTALL.SH] Making setup files executable\033[0m"
find . -name '*.sh' -type f | xargs chmod +x

echo -e "\033[41m[TARGET/INSTALL.SH] Rebooting, please wait. Install is still in progress\033[0m"
reboot
