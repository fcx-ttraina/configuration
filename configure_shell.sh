#!/bin/bash

# Download oh-my-zsh
sudo apt install zsh -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Add our profiles to ~/.zshrc
for i in $(ls /etc/profile.d); do echo "source /etc/profile.d/$i" >> ~/.zshrc; done

# Enable ctrl+backspace/ctrl+delete to delete words before/after cursor
echo "bindkey '^H' backward-kill-word" >> ~/.zshrc
echo "bindkey '5~' kill-word" >> ~/.zshrc

# Configure path
echo 'export VOLTA_HOME="$HOME/.volta"' >> ~/.zshrc
echo 'export PATH="$VOLTA_HOME/bin:$PATH"' >> ~/.zshrc
echo '. "$HOME/.cargo/env"' >> ~/.zshrc
echo 'alias maria="docker exec -it alchemy-mariadb-1 mysql -uroot -p oee"' >> ~/.zshrc

# Add custom theme
touch ~/.oh-my-zsh/themes/custom-ttr.zsh-theme

cat <<"TAGTEXTFILE" >> ~/.oh-my-zsh/themes/custom-ttr.zsh-theme
function get_date() {
  echo "%{$FG[130]%}[%T]%{$reset_color%}"
}

function get_user_host() {
  echo "%{$FG[141]%}%n%{$reset_color%}@%{$FG[164]%}%m%{$reset_color%}"
}

function get_current_dir() {
  echo "%B%{$FG[051]%}%c%{$reset_color%}%b"
}

function get_prompt() {
  echo "%(?:%{$fg_bold[green]%}❯ :%{$fg_bold[red]%}❯ )%{$reset_color%}"
}

PROMPT='$(get_date) $(get_user_host) $(git_prompt_info)
$(get_current_dir) $(get_prompt)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
TAGTEXTFILE

sed -i -e 's/ZSH_THEME=.*$/ZSH_THEME="custom-ttr"/g' ~/.zshrc

source ~/.zshrc

# Increase file watch limit (to prevent `yarn watch` errors)
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

# Add docker-compose override configuration
ln -sf /vagrant/docker-compose.override.yml /home/vagrant/alchemy/docker-compose.override.yml

ln -sf /vagrant/databases ~/databases

cp -r /vagrant/certs ~/certs
chmod 400 ~/certs/*

exit 0
