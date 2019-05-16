# Install redis dependancy 
echo -e "\033[42m[TARGET/REDIS-SETUP.SH] Downloading redis\033[0m"
cd $HOME
wget http://download.redis.io/releases/redis-stable.tar.gz
tar -xf redis-stable.tar.gz
rm redis-stable.tar.gz
cd $HOME/redis-stable
echo -e "\033[42m[TARGET/REDIS-SETUP.SH] Installing redis\033[0m"
make && sudo make install
echo -n | sudo $HOME/redis-stable/utils/install_server.sh
rm -r $HOME/redis-stable
