# Install ROS system dependacies
echo -e "\033[41m[TARGET/ROS-SETUP.SH] Apt install\n\033[0m"
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
sudo apt-get update
sudo apt-get install -y ros-kinetic-desktop-full
sudo apt-get install -y python-rosinstall python-rosinstall-generator python-wstool build-essential
sudo rosdep init

# Finish ROS install
echo -e "\033[41m[TARGET/ROS-SETUP.SH] Setting up ROS env\n\033[0m"
sudo -H -u $1 bash -c "\
cd ~ && \
rosdep update && \
echo 'source /opt/ros/kinetic/setup.bash' >> ~/.bashrc && \
source ~/.bashrc"
