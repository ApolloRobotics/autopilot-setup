# Load modules serial number and save to device
source ./serialnumber.sh
set_serial_number

#Set up LTE
echo -e "\033[42mSetting up modem\033[0m"
sudo nmcli c add type gsm ifname ttyUSB2 con-name verizon apn MW01.VZWSTATIC

# Add LiDAR as network device
echo -e "\033[42mAdding LiDAR as a network device\033[0m"
sudo nmcli c delete "Wired connection 1"
sudo nmcli con add type ethernet con-name lidar ifname eth0 ip4 10.5.5.1/24 
nmcli con modify lidar ipv4.never-default true

# Configure dnsmasq
echo -e "\033[42mConfiguring dnsmasq\033[0m"
sudo sh -c "echo 'interface=eth0\ndhcp-range=10.5.5.50,10.5.5.100,12h' > /etc/dnsmasq.conf"
# Make dnsmasq wait for network online. Can wait for a specific device too https://bugs.launchpad.net/ubuntu/+source/dnsmasq/+bug/1531184
sudo sed -i '/\[Install\]/i Restart=on-failure' /lib/systemd/system/dnsmasq.service
sudo sed -i '/\[Install\]/i RestartSec=5\n' /lib/systemd/system/dnsmasq.service
sudo systemctl enable dnsmasq
sudo systemctl daemon-reload

# Function to Add OS1 Hostname to .bashrc. Could be simplified and automated 
echo -e "\033[42mAdding hostname to bashrc\033[0m"
echo '
#OS1 HOSTNAME
save_os1_hostname() { 
  os1_hostname=$(sudo journalctl -u dnsmasq | grep -o "os1-[a-zA-Z0-9]*") 
  sed -i "/#OS1 HOSTNAME/a OS1_HOSTNAME=\"$os1_hostname\"" $HOME/.bashrc 
} 
if [ -z ${OS1_HOSTNAME+x} ]; then echo -e "\033[41m\nWARNING: OS1 Hostname not stored. Please boot with the LiDAR connected and run save_os1_hostname\033[0m"; fi
' >> $HOME/.bashrc 

# Set up PM2
echo -e "\033[42mSetting up PM2\033[0m"
pm2 start $HOME/workspace/fos/fos-service-registry/index.js --name registry
pm2 start $HOME/workspace/fos/fos-gateway/index.js --name gateway
pm2 start $HOME/workspace/fos/fos-status-checks/index.js --name status-checks
pm2 start $HOME/workspace/fos/fos-flight-stack/mavproxy_start.sh --name mavproxy
pm2 start $HOME/workspace/fos/fos-flight-stack/start.sh --name flight-stack
pm2 save && pm2 startup
sudo env PATH=$PATH:/home/apollo/.nvm/versions/node/$(nvm current)/bin /home/apollo/.nvm/versions/node/$(nvm current)/lib/node_modules/pm2/bin/pm2 startup systemd -u apollo --hp /home/apollo
