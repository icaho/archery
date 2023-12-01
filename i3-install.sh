#!/usr/bin/env bash

set -e

pacmanDeps()
{
	echo "installing deps"
	sudo pacman -Syu git rsync curl
}

pacmanInstall()
{
	echo "grab pacman list of packages to install"
	curl -O https://raw.githubusercontent.com/icaho/archery/main/pacman-pkglist.txt
	echo "installing pacman-pkglist"
	sleep 5
	sudo pacman -S --needed - < pacman-pkglist.txt
	rm pacman-pkglist.txt
}

yaySetup()
{
	echo "installing yay aur helper tool"
	git clone https://aur.archlinux.org/yay.git /tmp/yay
	cd /tmp/yay
	makepkg -si
	cd -
}

yayInstall()
{
	echo "grab aur list of packages to install"
	curl -O https://raw.githubusercontent.com/icaho/archery/main/aur-pkglist.txt
	echo "installing aur packages"
	sleep 5
	yay -S --needed --noconfirm - < aur-pkglist.txt
	rm aur-pkglist.txt
}

mainInstall()
{
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
}

burnAfterReading()
{
	rm $0 # Self delete
}

while getopts "pyidcm" option; do
	case $option in
		p) # Install pacman packages
		pacmanInstall
		;;
		m) # pacman deps
		pacmanDeps
		;;
		y) # Install aur packages
		yayInstall
		;;
		c) # config yay
		yaySetup
		;;
		i) # Install and configure i3
		mainInstall
		;;
		d) # Remove script after the run
		burnAfterReading
		exit
		;;
		\?) # Invalid option
		echo "Error: Invalid option"
		exit
		;;
	esac
done