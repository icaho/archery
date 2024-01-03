#!/usr/bin/env bash

clear   # Clear the TTY
set -e  # The script will not run if we CTRL + C, or in case of an error

read -p "Enter drive name: " drive

if [ "$drive" == nvme0n1 ] ; then
    bootpt="p1"
    rootpt="p2"
elif [ "$drive" == mmcblk0 ] ; then
    bootpt="p1"
    rootpt="p2"
else
    bootpt=1
    rootpt=2
fi

DRIVE=/dev/$drive
BOOT=$DRIVE$bootpt
ROOT=$DRIVE$rootpt

cryptsetup luksOpen $ROOT cryptroot  # Open the mapper

mount -o noatime,compress-force=zstd:1,ssd,space_cache=v2,subvol=@ /dev/mapper/cryptroot /mnt
mount -o noatime,compress-force=zstd:1,ssd,space_cache=v2,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o noatime,compress-force=zstd:1,ssd,space_cache=v2,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots
mount -o noatime,compress-force=zstd:1,ssd,space_cache=v2,subvol=@tmp /dev/mapper/cryptroot /mnt/tmp
mount -o noatime,compress-force=zstd:1,ssd,space_cache=v2,subvol=@var_cache /dev/mapper/cryptroot /mnt/var/cache
mount -o noatime,compress-force=zstd:1,ssd,space_cache=v2,subvol=@var_log /dev/mapper/cryptroot /mnt/var/log
mount $BOOT /mnt/boot

arch-chroot /mnt /bin/bash