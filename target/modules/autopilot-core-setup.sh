# Install autopilot-core
cd $HOME
source $HOME/.bashrc

# Make pip, virtual available to the shell. Not sure why this is needed when it already exists in bashrc
export PATH=$PATH:$HOME/.local/bin

# Make nvm, npm available to the shell. Not sure why this is needed when it already exists in bashrc
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Install projects
echo -e "\033[41m[TARGET/AUTOPILOT-CORE-SETUP.SH] Installing service registry\n\033[0m"
cd $HOME/workspace/autopilot-core/fos-service-registry && npm install
echo -e "\033[41m[TARGET/AUTOPILOT-CORE-SETUP.SH] Installing api gateway\n\033[0m"
cd $HOME/workspace/autopilot-core/fos-gateway && npm install
echo -e "\033[41m[TARGET/AUTOPILOT-CORE-SETUP.SH] Installing status checks\n\033[0m"
cd $HOME/workspace/autopilot-core/fos-status-checks && npm install
echo -e "\033[41m[TARGET/AUTOPILOT-CORE-SETUP.SH] Installing flight stack\n\033[0m"
cd $HOME/workspace/autopilot-core/fos-flight-stack 
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt

# Set environment variables
echo -e "\033[41m[TARGET/AUTOPILOT-CORE-SETUP.SH] Creating .env\n\033[0m"
echo "NODE_ENV=\"development\"
CLOUD_URI=\"http://api.flightservice.io\"
VEHICLE_TYPE=\"multirotor\"" > $HOME/.env

# Set up PM2
echo -e "\033[41m[TARGET/AUTOPILOT-CORE-SETUP.SH] Setting up PM2\n\033[0m"
cd $HOME/workspace/autopilot-core
pm2 start $HOME/workspace/autopilot-core/fos-service-registry/index.js --name registry
pm2 start $HOME/workspace/autopilot-core/fos-gateway/index.js --name gateway
pm2 start $HOME/workspace/autopilot-core/fos-status-checks/index.js --name gateway
pm2 start $HOME/workspace/autopilot-core/fos-flight-stack/mavproxy_start.sh --name mavproxy
pm2 start $HOME/workspace/autopilot-core/fos-flight-stack/start.sh --name flight-stack
pm2 save && pm2 startup
sudo env PATH=$PATH:/home/apollo/.nvm/versions/node/$(nvm current)/bin /home/apollo/.nvm/versions/node/$(nvm current)/lib/node_modules/pm2/bin/pm2 startup systemd -u apollo --hp /home/apollo

exit 0
