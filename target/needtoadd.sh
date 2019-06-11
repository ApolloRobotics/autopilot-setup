## DNS
ip addr flush dev eth0
ip addr show dev eth0
sudo ip addr add 10.5.5.1/24 dev eth0
sudo ip link set eth0 up
ip addr show dev eth0
sudo dnsmasq -C /dev/null -kd -F 10.5.5.50,10.5.5.100 -i eth0 --bind-dynamic

#Edit dnsmasq.conf
interface=eth0
dhcp-range=10.5.5.50,10.5.5.100,12h

sudo systemctl enable dnsmasq
sudo systemctl daemon-reload

# Edit /lib/systemd/system/dnsmasq.service
Restart=on-failure
RestartSec=5

# Auto connect to lte
auto ppp0

#Automount exfat usb
sudo apt-get install exfat-utils exfat-fuse
