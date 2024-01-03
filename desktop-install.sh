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
	curl -O https://raw.githubusercontent.com/icaho/archery/main/pacman/pacman-pkglist
	echo "installing pacman-pkglist"
	sleep 5
	sudo pacman -S --needed - < pacman-pkglist
	rm pacman-pkglist
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
	curl -O https://raw.githubusercontent.com/icaho/archery/main/aur/aur-pkglist
	echo "installing aur packages"
	sleep 5
	yay -S --needed --noconfirm - < aur-pkglist
	sudo cp /usr/share/doc/gtk3-nocsd/etc/xinit/xinitrc.d/30-gtk3-nocsd.sh /etc/X11/xinit/xinitrc.d/30-gtk3-nocsd.sh
	rm aur-pkglist
}

i3Install()
{
  echo "grab list of packages to install I3"
	curl -O https://raw.githubusercontent.com/icaho/archery/main/pacman/i3-pkglist
	echo "installing i3 pacman packages"
	sleep 5
	sudo pacman -S --needed - < i3-pkglist
	curl -O https://raw.githubusercontent.com/icaho/archery/main/aur/i3-aur-pkglist
	echo "installing i3 aur packages"
	sleep 5
	yay -S --needed --noconfirm - < i3-aur-pkglist
	rm i3-pkglist i3-aur-pkglist
}

plasmaPacmanInstall()
{
	echo "grab pacman list of packages to install"
	curl -O https://raw.githubusercontent.com/icaho/archery/main/pacman/plasma-pkglist
	echo "installing plasma pacman packages"
	sleep 5
	sudo pacman -S --needed - < plasma-pkglist
	curl -O https://raw.githubusercontent.com/icaho/archery/main/aur/plasma-aur-pkglist
	echo "installing plasma aur packages"
	sleep 5
	yay -S --needed --noconfirm - < plasma-aur-pkglist
	rm plasma-pkglist
}

mainInstall()
{
	git clone https://github.com/icaho/archery-dotfiles.git

	( sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/main/tools/install.sh)" "" --unattended )

	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

	if [ "$DESKTOP" == "i3" ]; then
		i3Install
		rsync --recursive --verbose --exclude={'.git','README.md'} archery-dotfiles/ $HOME
		sudo git clone https://github.com/icaho/lightdm-webkit-material.git /usr/share/lightdm-webkit/themes/material
		sudo sed -i "/^\[Seat/a greeter-session=lightdm-webkit2-greeter" /etc/lightdm/lightdm.conf
		sudo sed -i "s/webkit_theme        = antergos/webkit_theme        = material/" /etc/lightdm/lightdm-webkit2-greeter.conf
    sudo systemctl enable lightdm
	elif [ "$DESKTOP" == "plasma" ]; then
	  plasmaPacmanInstall
		rsync --recursive --verbose --exclude={'.git','README.md','.config/alacritty','.config/autorandr','.config/dunst','.config/i3','.config/picom','.config/polybar','.config/ranger','.config/rofi','.config/vlc'} archery-dotfiles/ $HOME
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
		sudo systemctl enable sddm
	fi

	rm -rf archery-dotfiles

	sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="kungfupanda"/' ~/.zshrc
	sed -i 's/plugins=(git)/plugins=(git kubectl zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

	sudo usermod -a -G docker $USER
	sudo usermod -a -G tfenv $USER
	sudo systemctl enable docker bluetooth avahi-daemon

	fc-cache -f -v
	nvim --headless +PlugInstall +qall 2>&1 > /dev/null
	
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
		DESKTOP=i3
		mainInstall
		;;
		k) # Install and configure Plasma
		DESKTOP=plasma
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