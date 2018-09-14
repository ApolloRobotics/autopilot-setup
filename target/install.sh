export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games

nmcli d wifi connect Xponential_EMP password "3DINC&W0rks"

timeout=0
while [ $(ifconfig | grep -F "192.168.1." | wc -l) -eq 0 ]; do
    sleep 5
    timeout=$((timeout+1))
    nmcli d wifi connect Xponential_EMP password "3DINC&W0rks"
    if [ "$timeout" -gt 60 ]; then
        #Time out here
        echo "install.sh connection timed out"
        exit 1
    fi
done
echo "Connected"

# Update and install system dependancies 
export DEBIAN_FRONTEND=noninteractive 
mv sources.list /etc/apt/
sudo apt-get update
yes "yes" | apt-get -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade

# Run the main script on reboot
# Create cron job non-iteractively (also without risk of duplication)
# https://stackoverflow.com/questions/878600/how-to-create-a-cron-job-using-bash-automatically-without-the-interactive-editor
# Ended up not using the above solution in favor of a much simpler one. Add the script to cron, have the script remove itself from cron.
export INSTALLER_DIR=/root/autopilot-setup
command="sudo -H -u root bash -c 'cd $INSTALLER_DIR && bash $INSTALLER_DIR/main.sh >> /var/log/apollo-setup.log 2>&1'"
job="@reboot $command"
cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -

# Remove this files self-start line 
head -n -1 /etc/systemd/nvfb.sh > temp.sh ; mv temp.sh /etc/systemd/nvfb.sh

# Make setup files executable
find . -name '*.sh' -type f | xargs chmod +x

reboot
