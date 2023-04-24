#!/usr/bin/env bash

set -e

( sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended )

git clone https://github.com/icaho/archery-dotfiles.git
rsync --recursive --verbose --exclude '.git' --exclude 'README.md' archery-dotfiles/ $HOME
rm -rf archery-dotfiles

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sudo git clone https://github.com/icaho/lightdm-webkit-material.git /usr/share/lightdm-webkit/themes/material

sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="kungfupanda"/' ~/.zshrc
sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting)/' ~/.zshrc

sudo sed -i "/^\[Seat/a greeter-session=lightdm-webkit2-greeter" /etc/lightdm/lightdm.conf
sudo sed -i "s/webkit_theme        = antergos/webkit_theme        = material/" /etc/lightdm/lightdm-webkit2-greeter.conf

sudo usermod -a -G docker $USER
sudo systemctl enable docker bluetooth avahi-daemon lightdm

fc-cache -f -v

nvim --headless +PlugInstall +qall 2>&1 > /dev/null
sudo usermod -a -G tfenv $USER

rm pacman-pkglist.txt
rm aur-pkglist.txt

rm $0 # Self delete
