#MAVros 
echo -e "\033[42m[TARGET/MAIN.SH] Downloading MAVros\033[0m"
cd $HOME/workspace
wget https://github.com/mavlink/mavros/archive/master.zip
unzip master.zip && rm $_
cd mavros_master
rm -ry test_mavros
echo -e "\033[42m[TARGET/MAIN.SH] Installing MAVros\033[0m"
ln -s $HOME/workspace/mavros-master $HOME/workspace/catkin_ws/src/mavros 
catkin_make
sudo $HOME/workspace/mavros-master/mavros/scripts/install_geographiclib_datasets.sh

# Setup InertialSenese
echo -e "\033[42m[TARGET/LOAM-SETUP.SH] Downloading InertialSense\033[0m"
cd $HOME/workspace/catkin_ws/src
catkin_init_workspace
https://github.com/inertialsense/inertial_sense_ros.git
cd inertial_sense
git submodule update --init --recursive
echo -e "\033[42m[TARGET/LOAM-SETUP.SH] Installing InertialSense\033[0m"
cd ../..
catkin_make

# Set up loam_ros 
echo -e "\033[42m[TARGET/LOAM-SETUP.SH] Installing loam_ros\033[0m"
ln -s $HOME/workspace/loam_ros/loam_interface $HOME/workspace/catkin_ws/src/loam_interface
ln -s $HOME/workspace/loam_ros/loam_graph $HOME/workspace/catkin_ws/src/loam_graph
source /opt/ros/kinetic/setup.bash
cd $HOME/workspace/catkin_ws
source $HOME/workspace/catkin_ws/devel/setup.sh
catkin_make

# Setup libharu
echo -e "\033[42m[TARGET/LOAM-SETUP.SH] Downloading libharu\033[0m"
cd $HOME
git clone https://github.com/libharu/libharu.git
echo -e "\033[42m[TARGET/LOAM-SETUP.SH] Installing libharu\033[0m"
cd libharu
mkdir build && cd $_
cmake .. && make -j4 && sudo make install
cd $HOME