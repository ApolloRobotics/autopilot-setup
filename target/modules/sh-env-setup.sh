cd $HOME

# Install Ultimate Bash (dev-only)
cd ~ && git clone https://github.com/jakehewitt/bash-settings.git .bash-settings && make -C .bash-settings/ && source ~/.bashrc

# Install git radar (dev-only)
cd ~ && git clone https://github.com/michaeldfallen/git-radar .git-radar
echo 'export PATH=$PATH:$HOME/.git-radar' >> ~/.bashrc
# echo 'export PS1="$PS1\$(git-radar --bash --fetch)"' >> ~/.bashrc