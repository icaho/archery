#!/usr/bin/env bash

set -e

sudo pacman -Sy --needed bluedevil breeze-gtk drkonqi kde-gtk-config kdeplasma-addons kgamma5 khotkeys kinfocenter kscreen ksshaskpass ksysguard kwallet-pam kwayland-integration kwrited plasma-browser-integration plasma-desktop plasma-disks plasma-nm plasma-pa plasma-sdk plasma-thunderbolt plasma-vault plasma-workspace-wallpapers powerdevil sddm-kcm xdg-desktop-portal-kde sddm kdialog konsole dolphin noto-fonts \
phonon-qt5-vlc snapper plasma-firewall ark unzip zsh adobe-source-code-pro-fonts \
inetutils \
colord-kde kdeconnect exfat-utils

curl -O https://raw.githubusercontent.com/icaho/archery/master/pacman-pkglist.txt

sudo pacman -S --needed < pacman-pkglist.txt

git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si
cd -

curl -O https://raw.githubusercontent.com/icaho/archery/master/aur-pkglist.txt

yay -S --needed < aur-pkglist.txt

rm $0 # Self delete