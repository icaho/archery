#!/usr/bin/env bash

set -e

sudo pacman -Sy nvidia lib32-nvidia-utils nvidia-prime

if [ ! -d /etc/pacman.d/hooks ]; then
  sudo mkdir -p /etc/pacman.d/hooks;
fi

sudo tee -a /etc/pacman.d/hooks/nvidia.hook << END
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux
# Change the linux part above and in the Exec line if a different kernel is used

[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'
END

rm $0 # Self delete

