#!/usr/bin/env bash

set -e

sudo pacman -Sy --needed bluedevil breeze-gtk drkonqi kde-gtk-config kdeplasma-addons kgamma5 khotkeys kinfocenter kscreen ksshaskpass ksysguard kwallet-pam kwayland-integration kwrited plasma-browser-integration plasma-desktop plasma-disks plasma-nm plasma-pa plasma-sdk plasma-thunderbolt plasma-vault plasma-workspace-wallpapers powerdevil sddm-kcm xdg-desktop-portal-kde sddm kdialog konsole dolphin noto-fonts \
phonon-qt5-vlc snapper plasma-firewall ark unzip zsh adobe-source-code-pro-fonts \
inetutils \
colord-kde kdeconnect exfat-utils

yay -S --needed montserrat-font-ttf archlinux-artwork \
sierrabreeze-kwin-decoration-git

curl -O https://raw.githubusercontent.com/icaho/archery/master/pacman-pkglist.txt

sudo pacman -S --needed < pacman-pkglist.txt

git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si
cd -

curl -O https://raw.githubusercontent.com/icaho/archery/master/aur-pkglist.txt

yay -S --needed < aur-pkglist.txt

sudo mkdir /etc/sddm.conf.d

sudo tee -a /etc/sddm.conf.d/kde_settings.conf << END
[General]
HaltCommand=/usr/bin/systemctl poweroff
Numlock=none
RebootCommand=/usr/bin/systemctl reboot

[Theme]
Current=breeze

[Users]
MaximumUid=60000
MinimumUid=1000
END

sudo systemctl enable docker bluetooth avahi-daemon sddm

rm pacman-pkglist.txt
rm aur-pkglist.txt

rm $0 # Self delete
