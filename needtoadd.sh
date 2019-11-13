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
#TODO: Might need to change to 192.168.168 need to verify

sudo systemctl enable dnsmasq
sudo systemctl daemon-reload
nmcli c delete "Wired connection 1"

# Edit /lib/systemd/system/dnsmasq.service
Restart=on-failure
RestartSec=5

# Auto connect to lte
auto ppp0

#Automount exfat usb
sudo apt-get install exfat-utils exfat-fuse



sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F42ED6FBAB17C654
 GPG error: http://packages.ros.org/ros/ubuntu xenial InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY F42ED6FBAB17C654

 CMake Error at /usr/local/share/cmake-3.15/Modules/FindPackageHandleStandardArgs.cmake:137 (message):
Could NOT find Boost (missing: Boost_INCLUDE_DIR program_options thread
system iostreams filesystem) (Required is at least version "1.42")
Call Stack (most recent call first):
/usr/local/share/cmake-3.15/Modules/FindPackageHandleStandardArgs.cmake:378 (_FPHSA_FAILURE_MESSAGE)
/usr/local/share/cmake-3.15/Modules/FindBoost.cmake:1990 (find_package_handle_standard_args)
CMakeLists.txt:193 (find_package)


CMake Warning (dev) in /usr/local/share/cmake-3.15/Modules/FindBoost.cmake:
Policy CMP0011 is not set: Included scripts do automatic cmake_policy PUSH
and POP. Run "cmake --help-policy CMP0011" for policy details. Use the
cmake_policy command to set the policy and suppress this warning.

The included script

/usr/local/share/cmake-3.15/Modules/FindBoost.cmake

affects policy settings. CMake is implying the NO_POLICY_SCOPE option for
compatibility, so the effects are applied to the including context.
Call Stack (most recent call first):
CMakeLists.txt:193 (find_package)
This warning is for project developers. Use -Wno-dev to suppress it.

-- Configuring incomplete, errors occurred!
See also "/root/libLAS-1.8.1/build/CMakeFiles/CMakeOutput.log".


[TARGET/OUSTER-SETUP.SH] Setting up ouster_client
-- The C compiler identification is GNU 5.4.0
-- The CXX compiler identification is GNU 5.4.0
-- Check for working C compiler: /usr/bin/cc
-- Check for working C compiler: /usr/bin/cc -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
-- Detecting C compile features - done
-- Check for working CXX compiler: /usr/bin/c++
-- Check for working CXX compiler: /usr/bin/c++ -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Found PkgConfig: /usr/bin/pkg-config (found version "0.29.1")
-- Checking for module 'jsoncpp'
-- No package 'jsoncpp' found
CMake Error at /usr/local/share/cmake-3.15/Modules/FindPkgConfig.cmake:458 (message):
A required package was not found
Call Stack (most recent call first):
/usr/local/share/cmake-3.15/Modules/FindPkgConfig.cmake:637 (_pkg_check_modules_internal)
CMakeLists.txt:10 (pkg_check_modules)


-- Configuring incomplete, errors occurred!
See also "/home/apollo/workspace/ouster_example/ouster_client/build/CMakeFiles/CMakeOutput.log".
[TARGET/OUSTER-SETUP.SH] Setting up ouster_viz
-- The C compiler identification is GNU 5.4.0
-- The CXX compiler identification is GNU 5.4.0
-- Check for working C compiler: /usr/bin/cc
-- Check for working C compiler: /usr/bin/cc -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
-- Detecting C compile features - done
-- Check for working CXX compiler: /usr/bin/c++
-- Check for working CXX compiler: /usr/bin/c++ -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Looking for pthread.h
-- Looking for pthread.h - found
-- Performing Test CMAKE_HAVE_LIBC_PTHREAD
-- Performing Test CMAKE_HAVE_LIBC_PTHREAD - Failed
-- Looking for pthread_create in pthreads
-- Looking for pthread_create in pthreads - not found
-- Looking for pthread_create in pthread
-- Looking for pthread_create in pthread - found
-- Found Threads: TRUE
CMake Error at CMakeLists.txt:10 (find_package):
By not providing "FindEigen3.cmake" in CMAKE_MODULE_PATH this project has
asked CMake to find a package configuration file provided by "Eigen3", but
CMake did not find one.

Could not find a package configuration file provided by "Eigen3" with any
of the following names:

Eigen3Config.cmake
eigen3-config.cmake

Add the installation prefix of "Eigen3" to CMAKE_PREFIX_PATH or set
"Eigen3_DIR" to a directory containing one of the above files. If "Eigen3"
provides a separate development package or SDK, be sure it has been
installed.


-- Configuring incomplete, errors occurred!
See also "/home/apollo/workspace/ouster_example/ouster_viz/build/CMakeFiles/CMakeOutput.log".
See also "/home/apollo/workspace/ouster_example/ouster_viz/build/CMakeFiles/CMakeError.log".
[TARGET/OUSTER-SETUP.SH] Setting up catkin and ouster_example
bash: line 18: /opt/ros/kinetic/setup.bash: No such file or directory
bash: line 19: catkin_make: command not found

TARGET/OUSTER-SETUP.SH] Setting up catkin and ouster_example
bash: line 18: /opt/ros/kinetic/setup.bash: No such file or directory
bash: line 19: catkin_make: command not found
[TARGET/OUSTER-SETUP.SH] Installing aliases
[TARGET/OUSTER-SETUP.SH] Adding LiDAR as a network device
sudo: no tty present and no askpass program specified
[TARGET/OUSTER-SETUP.SH] Configuring dnsmasq
sed: couldn't open temporary file /etc/sediIVDzd: Permission denied
sed: couldn't open temporary file /etc/sedxGj8jd: Permission denied

[TARGET/MAIN.SH] Installing MAVros
bash: line 10: catkin_make: command not found
sudo: no tty present and no askpass program specified
[TARGET/LOAM-SETUP.SH] Downloading InertialSense
bash: line 16: catkin_init_workspace: command not found
bash: line 17: https://github.com/inertialsense/inertial_sense_ros.git: No such file or directory
bash: line 18: cd: inertial_sense: No such file or directory
fatal: Not a git repository (or any of the parent directories): .git

[TARGET/LOAM-SETUP.SH] Installing InertialSense
bash: line 22: catkin_make: command not found
[TARGET/LOAM-SETUP.SH] Installing loam_ros
bash: line 28: /opt/ros/kinetic/setup.bash: No such file or directory
bash: line 30: /home/apollo/workspace/catkin_ws/devel/setup.sh: No such file or directory
bash: line 31: catkin_make: command not found
[TARGET/LOAM-SETUP.SH] Downloading libharu
'
#NOT WORKING
sudo apt-get build-dep python3-lxml
sudo apt-get install libgeotiff-dev


# Move ouster device and DNS config to last



certbot
mavproxy install
redis-server install