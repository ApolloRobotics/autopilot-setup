# Testing
roslaunch mavros apm.launch fcu_url:='tcp://sitl.flightservice.io:5762' > /dev/null 2>&1 &
rostopic hz /mavlink/from

# TODO: Need to manually build loam_process
# TODO: link NDT .a file to /usr/lib 
sudo ln -s $(pwd)/libndt_gpu.a /usr/lib/libndt_gpu.a
sudo ln -s $(pwd)/../include/ndt_gpu /usr/include/ndt_gpu

# SD on boot
sudo vim /etc/fstab
/dev/root            /                    rootfs          defaults                                     0 1
/dev/mmcblk1p1       /media/apollo/disk   ext4            defaults                                     0 1
/dev/sda2            /media/apollo/DATA   vfat            defaults,umask=000                           0 1