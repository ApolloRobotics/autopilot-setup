# Setup InertialSenese
echo -e "\033[42m[TARGET/LOAM-SETUP.SH] Downloading InertialSense\033[0m"
cd $HOME/workspace/
INERTIAL_SENSE_VERSION="1.7.5"
wget https://github.com/inertialsense/InertialSenseSDK/archive/$INERTIAL_SENSE_VERSION.tar.gz
tar xvfz $INERTIAL_SENSE_VERSION.tar.gz && rm $_ 
mkdir -p $INERTIAL_SENSE_VERSION/build && cd $_
echo -e "\033[42m[TARGET/LOAM-SETUP.SH] Installing InertialSense\033[0m"
cmake .. && make
ln -s $HOME/workspace/InertialSenseSDK-1.7.5 $HOME/workspace/catkin_ws/src/inertial_sense

# Set up loam_ros 
echo -e "\033[42m[TARGET/LOAM-SETUP.SH] Installing loam_ros\033[0m"
ln -s $HOME/workspace/loam_ros/loam_interface $HOME/workspace/catkin_ws/src/loam_interface
ln -s $HOME/workspace/loam_ros/loam_graph $HOME/workspace/catkin_ws/src/loam_graph
source /opt/ros/kinetic/setup.bash
cd $HOME/workspace/catkin_ws
source $HOME/workspace/catkin_ws/devel/setup.sh
catkin_make
