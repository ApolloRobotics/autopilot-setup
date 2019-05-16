# Installs the latest verision of nvm
echo -e "\033[41m[TARGET/NODE-SETUP.SH] Downloading nvm\033[0m"
cd $HOME
export NVM_DIR="$HOME/.nvm" && (
git clone https://github.com/creationix/nvm.git "$NVM_DIR"
cd "$NVM_DIR"
git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" origin`
) && . "$NVM_DIR/nvm.sh"
echo -e "\033[41m[TARGET/NODE-SETUP.SH] Installing nvm\033[0m"
cd $HOME && "$NVM_DIR/install.sh" # This loads and installs nvm

# Install node & pm2
echo -e "\033[41m[TARGET/NODE-SETUP.SH] Installing node\033[0m"
nvm install stable
npm install -g pm2
