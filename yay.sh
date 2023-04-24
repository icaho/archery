#!/usr/bin/env bash

set -e

git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si
cd -

curl -O https://raw.githubusercontent.com/icaho/archery/master/aur-pkglist.txt

yay -S --needed --noconfirm - < aur-pkglist.txt