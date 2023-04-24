#!/usr/bin/env bash

set -e

sudo pacman -Syu git rsync curl

curl -O https://raw.githubusercontent.com/icaho/archery/master/pacman-pkglist.txt

sudo pacman -S --needed - < pacman-pkglist.txt