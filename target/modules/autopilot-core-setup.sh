# Install autopilot-core
cd $HOME
source $HOME/.bashrc

# Make pip, virtual available to the shell. Not sure why this is needed when it already exists in bashrc
export PATH=$PATH:$HOME/.local/bin

# Make nvm, npm available to the shell. Not sure why this is needed when it already exists in bashrc
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Install projects
echo "[TARGET/AUTOPILOT-CORE-SETUP.SH] Installing service registry"
cd $HOME/workspace/autopilot-core/fos-service-registry && npm install
echo "[TARGET/AUTOPILOT-CORE-SETUP.SH] Installing api gateway"
cd $HOME/workspace/autopilot-core/fos-gateway && npm install
echo "[TARGET/AUTOPILOT-CORE-SETUP.SH] Installing status checks"
cd $HOME/workspace/autopilot-core/fos-status-checks && npm install
echo "[TARGET/AUTOPILOT-CORE-SETUP.SH] Installing flight stack"
cd $HOME/workspace/autopilot-core/fos-flight-stack 
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt

# Set environment variables
echo "[TARGET/AUTOPILOT-CORE-SETUP.SH] Creating .env"
echo "NODE_ENV=\"development\"
CLOUD_URI=\"http://api.flightservice.io\"
VEHICLE_TYPE=\"multirotor\"" > $HOME/.env

# Set up PM2
echo "[TARGET/AUTOPILOT-CORE-SETUP.SH] Setting up PM2"
cd $HOME/workspace/autopilot-core
pm2 start $HOME/workspace/autopilot-core/fos-service-registry/index.js --name registry
pm2 start $HOME/workspace/autopilot-core/fos-gateway/index.js --name gateway
pm2 start $HOME/workspace/autopilot-core/fos-status-checks/index.js --name gateway
pm2 start $HOME/workspace/autopilot-core/fos-flight-stack/mavproxy_start.sh --name mavproxy
pm2 start $HOME/workspace/autopilot-core/fos-flight-stack/start.sh --name flight-stack
pm2 save && pm2 startup
sudo env PATH=$PATH:/home/apollo/.nvm/versions/node/$(nvm current)/bin /home/apollo/.nvm/versions/node/$(nvm current)/lib/node_modules/pm2/bin/pm2 startup systemd -u apollo --hp /home/apollo

exit 0
