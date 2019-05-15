# Install python dependencies
echo "[TARGET/PYTHON-SETUP.SH] Downloading pip"
cd $HOME
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
echo "[TARGET/PYTHON-SETUP.SH] Installing pip"
python get-pip.py --user
rm get-pip.py
echo "[TARGET/PYTHON-SETUP.SH] Adding to path"
export PATH=$PATH:$HOME/.local/bin
echo 'export PATH=$PATH:$HOME/.local/bin' >> $HOME/.bashrc
echo "[TARGET/PYTHON-SETUP.SH] Installing virtualenv"
pip install virtualenv --user 
