cd $HOME

# Install Ultimate Bash (dev-only)
cd ~ && git clone https://github.com/jakehewitt/bash-settings.git .bash-settings && make -C .bash-settings/ && source ~/.bashrc

# Install git radar (dev-only)
cd ~ && git clone https://github.com/michaeldfallen/git-radar .git-radar
echo 'export PATH=$PATH:$HOME/.git-radar' >> ~/.bashrc
# echo 'export PS1="$PS1\$(git-radar --bash --fetch)"' >> ~/.bashrc

## Change GUI settings
# Enable gsettings to be changed
PID=$(pgrep gnome-session)
export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ|cut -d= -f2-)
# Turn user's screen lock off
gsettings set org.gnome.desktop.session idle-delay 0
# Change user's wallpaper
gsettings set org.gnome.desktop.background picture-uri file:///usr/share/backgrounds/wallpaper.png

exit 0
