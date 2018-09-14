# Install autopilot-core

cd $HOME
source $HOME/.bashrc

# Make pip, virtual available to the shell. Not sure why this is needed when it already exists in bashrc
export PATH=$PATH:$HOME/.local/bin

# Make nvm, npm available to the shell. Not sure why this is needed when it already exists in bashrc
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Install projects
cd $HOME/workspace/autopilot-core/tma-service-registry && npm install
cd $HOME/workspace/autopilot-core/tma-gateway && npm install
cd $HOME/workspace/autopilot-core/flight-stack 
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt

# Set environment variables
echo "NODE_ENV=\"development\"
CLOUD_URI=\"http://dev.flightservice.io\"
VEHICLE_TYPE=\"multirotor\"" > $HOME/.env
