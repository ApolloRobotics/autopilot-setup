# Install python dependencies
echo -e "\033[41m[TARGET/PYTHON-SETUP.SH] Downloading pip\n\033[0m"
cd $HOME
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
echo -e "\033[41m[TARGET/PYTHON-SETUP.SH] Installing pip\n\033[0m"
python get-pip.py --user
rm get-pip.py
echo -e "\033[41m[TARGET/PYTHON-SETUP.SH] Adding to path\n\033[0m"
export PATH=$PATH:$HOME/.local/bin
echo 'export PATH=$PATH:$HOME/.local/bin' >> $HOME/.bashrc
echo -e "\033[41m[TARGET/PYTHON-SETUP.SH] Installing virtualenv\n\033[0m"
pip install virtualenv --user 
