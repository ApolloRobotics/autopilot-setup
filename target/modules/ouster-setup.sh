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
echo 'alias qk_launch="roslaunch ouster_ros os1.launch os1_hostname:=<os1_hostname> os1_udp_dest:=<udp_data_dest_ip>"' >> $HOME/.bash_aliases
echo 'alias qk_record="rosbag record /os1_node/imu_packets /os1_node/lidar_packets"' >> $HOME/.bash_aliases
echo 'alias qk_rviz="rviz -d $HOME/workspace/ouster_example/ouster_ros/viz.rviz"' >> $HOME/.bash_aliases
echo 'alias fk_launch="roslaunch ouster_ros os1.launch replay:=true"' >> $HOME/.bash_aliases
echo 'alias fk_play="rosbag play --clock $HOME/Downloads/file"' >> $HOME/.bash_aliases
