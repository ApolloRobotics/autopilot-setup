# Install redis dependancy 
cd $HOME
wget http://download.redis.io/releases/redis-stable.tar.gz
tar -xf redis-stable.tar.gz
rm redis-stable.tar.gz
cd $HOME/redis-stable
make && sudo make install
echo -n | sudo $HOME/redis-stable/utils/install_server.sh
rm -r $HOME/redis-stable
