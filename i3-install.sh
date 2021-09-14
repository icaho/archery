#!/usr/bin/env bash

set -e

sudo pacman -Syu git rsync curl

curl -O https://raw.githubusercontent.com/icaho/archery/master/pacman-pkglist.txt

sudo pacman -S --needed - < pacman-pkglist.txt

git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si
cd -

curl -O https://raw.githubusercontent.com/icaho/archery/master/aur-pkglist.txt

yay -S --needed - < aur-pkglist.txt

( sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" )

git clone https://github.com/icaho/archery-dotfiles.git
rsync --recursive --verbose --exclude '.git' --exclude 'README.md' archery-dotfiles/ $HOME
rm -rf archery-dotfiles

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="kungfupanda"/' ~/.zshrc
sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting)/' ~/.zshrc

sudo sed -i "/^\[Seat/a greeter-session=lightdm-webkit2-greeter" /etc/lightdm/lightdm.conf
sudo sed -i "s/webkit_theme        = antergos/webkit_theme        = material/" /etc/lightdm/lightdm-webkit2-greeter.conf

sudo usermod -a -G docker $USER
sudo systemctl enable docker bluetooth avahi-daemon lightdm

nvim --headless +PlugInstall +qall 2>&1 > /dev/null

rm pacman-pkglist.txt
rm aur-pkglist.txt

rm $0 # Self delete
