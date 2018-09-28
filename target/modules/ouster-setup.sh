cd $HOME

# Clone Ouster repo
git clone https://github.com/ouster-lidar/ouster_example.git $HOME/workspace/ouster_example

# Setup ROS independant projects
cd $HOME/workspace/ouster_example/ouster_client && mkdir build && cd build && cmake .. && make
cd $HOME/workspace/ouster_example/ouster_viz && mkdir build && cd build && cmake .. && make

# Install ROS Sample
mkdir -p $HOME/workspace/catkin_ws && cd $_
mkdir src
ln -s $HOME/workspace/ouster_example/ $HOME/workspace/catkin_ws/src
source /opt/ros/kinetic/setup.bash
catkin_make
echo "source $HOME/workspace/catkin_ws/devel/setup.bash" >> $HOME/.bashrc

# Startup alias shortcuts for ROS
echo 'alias qk_launch="roslaunch ouster_ros os1.launch os1_hostname:=$OS1_HOSTNAME os1_udp_dest:=192.168.2.1"' >> $HOME/.bash_aliases
echo 'alias qk_record="rosbag record /os1_node/imu_packets /os1_node/lidar_packets"' >> $HOME/.bash_aliases
echo 'alias qk_rviz="rviz -d $HOME/workspace/ouster_example/ouster_ros/viz.rviz"' >> $HOME/.bash_aliases
echo 'alias fk_launch="roslaunch ouster_ros os1.launch replay:=true"' >> $HOME/.bash_aliases
echo 'alias fk_play="rosbag play --clock "' >> $HOME/.bash_aliases

# Add LiDAR as network device
sudo nmcli con add type ethernet con-name lidar ifname eth0 ip4 192.168.2.1/24

# Configure dnsmasq
sed -i 's/^#interface=.*/interface=eth0/g' /etc/dnsmasq.conf
sed -i 's/^#dhcp-range=.*/dhcp-range=192.168.2.50,192.168.2.150,12h/g' /etc/dnsmasq.conf
# Make dnsmasq wait for network online. Can wait for a specific device too https://bugs.launchpad.net/ubuntu/+source/dnsmasq/+bug/1531184
sed -i '/Requires=network.target/aAfter=network-online.target\nWants=network-online.target' /lib/systemd/system/dnsmasq.service

# Function to Add OS1 Hostname to .bashrc. Could be simplified and automated 
echo '
save_os1_hostname() { 
  os1_hostname=$(sudo journalctl -u dnsmasq | grep -o "os1-[a-zA-Z0-9]*") 
  echo "export OS1_HOSTNAME=\"$os1_hostname\"" >> $HOME/.bashrc 
} 
if [ -z ${OS1_HOSTNAME+x} ]; then echo "\n WARNING: OS1 Hostname not stored. Please boot with the LiDAR connected and run save_os1_hostname"; fi
' >> $HOME/.bashrc 
