# Install redis dependancy 
echo "[TARGET/REDIS-SETUP.SH] Downloading redis"
cd $HOME
wget http://download.redis.io/releases/redis-stable.tar.gz
tar -xf redis-stable.tar.gz
rm redis-stable.tar.gz
cd $HOME/redis-stable
echo "[TARGET/REDIS-SETUP.SH] Installing redis"
make && sudo make install
echo -n | sudo $HOME/redis-stable/utils/install_server.sh
rm -r $HOME/redis-stable
