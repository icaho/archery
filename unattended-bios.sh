#!/usr/bin/env bash

clear   # Clear the TTY
set -e  # The script will not run if we CTRL + C, or in case of an error
set -u  # Treat unset variables as an error when substituting

continent_city=Europe/London
keymap=uk

read -p "Enter drive name: " drive
read -p "Enter name: " username
# username=st
read -p "Enter hostname: " hostname
# hostname=bebop
read -s -p "Enter userpass: " user_password
read -s -p "Enter rootpass: " root_password

if [ "$drive" == nvme0n1 ] ; then
    bootpt="p1"
    rootpt="p2"
else
    bootpt=1
    rootpt=2
fi

DRIVE=/dev/$drive
BOOT=$DRIVE$bootpt
ROOT=$DRIVE$rootpt

timedatectl set-ntp true  # Synchronize motherboard clock
sgdisk --zap-all $DRIVE  # Delete tables
sgdisk --clear \
       --new=1:0:+600MiB --typecode=1:8300 --change-name=1:BOOT\
       --new=2:0:0 --typecode=2:8300\
         $DRIVE

mkfs.ext3 $BOOT

mkdir -p -m0700 /run/cryptsetup  # Change permission to root only
cryptsetup luksFormat --type luks2 $ROOT
cryptsetup luksOpen $ROOT cryptroot  # Open the mapper

mkfs.btrfs /dev/mapper/cryptroot  # Format the encrypted partition

mount /dev/mapper/cryptroot /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@tmp
btrfs su cr /mnt/@swap
btrfs su cr /mnt/@snapshots
btrfs su cr /mnt/@var_cache
btrfs su cr /mnt/@var_log


umount /mnt

mount -o noatime,compress-force=zstd:1,ssd,space_cache=v2,subvol=@ /dev/mapper/cryptroot /mnt
mkdir -p /mnt/{boot,home,var,.snapshots,tmp,swapspace} # Create directories for their respective subvolumes
mount -o noatime,compress-force=zstd:1,ssd,space_cache=v2,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o noatime,compress-force=zstd:1,ssd,space_cache=v2,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots
mount -o noatime,compress-force=zstd:1,ssd,space_cache=v2,subvol=@tmp /dev/mapper/cryptroot /mnt/tmp
mkdir /mnt/var/{log,cache} # Create directories for their respective var subvolumes
mount -o noatime,compress-force=zstd:1,ssd,space_cache=v2,subvol=@var_cache /dev/mapper/cryptroot /mnt/var/cache
mount -o noatime,compress-force=zstd:1,ssd,space_cache=v2,subvol=@var_log /dev/mapper/cryptroot /mnt/var/log
mount -o rw,noatime,space_cache,subvol=@swap /dev/mapper/cryptroot /mnt/swapspace
mount $BOOT /mnt/boot

sed -i "/#Color/a ILoveCandy" /etc/pacman.conf  # Making pacman prettier
sed -i "s/#Color/Color/g" /etc/pacman.conf  # Add color to pacman
sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 10/g" /etc/pacman.conf  # Parallel downloads
tee -a /etc/pacman.conf << END
[multilib]
Include = /etc/pacman.d/mirrorlist
END

pacman -Syy

pacstrap /mnt base base-devel linux linux-firmware \
    intel-ucode \
    networkmanager \
    efibootmgr \
    btrfs-progs \
    neovim \
    zsh \
    wpa_supplicant \
    dosfstools \
    e2fsprogs \
    sudo \
    tmux \
    rsync \
    openssh \
    git \
    neovim \
    htop \
    openvpn \
    networkmanager-openvpn \
    fzf \
    ruby \
    python \
    nodejs \
    earlyoom \
    xorg-server \
    xf86-video-fbdev \
    xf86-video-intel \
    grub-bios \
    os-prober


genfstab -U /mnt >> /mnt/etc/fstab  # Generate the entries for fstab
arch-chroot /mnt /bin/bash << EOF
timedatectl set-ntp true
ln -sf /usr/share/zoneinfo/$continent_city /etc/localtime
hwclock --systohc
sed -i "s/#en_GB/en_GB/g; s/#en_US.UTF-8/en_US.UTF-8/g" /etc/locale.gen
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
locale-gen

echo -e "127.0.0.1\tlocalhost" >> /etc/hosts
echo -e "::1\t\tlocalhost" >> /etc/hosts
echo -e "127.0.1.1\t$hostname.localdomain\t$hostname" >> /etc/hosts

echo -e "KEYMAP=$keymap" > /etc/vconsole.conf
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
echo "Defaults !tty_tickets" >> /etc/sudoers
sed -i "/#Color/a ILoveCandy" /etc/pacman.conf
sed -i "s/#Color/Color/g; s/#ParallelDownloads = 5/ParallelDownloads = 6/g; s/#UseSyslog/UseSyslog/g; s/#VerbosePkgLists/VerbosePkgLists/g" /etc/pacman.conf
sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/g; s/-)/--threads=0 -)/g; s/gzip/pigz/g; s/bzip2/pbzip2/g' /etc/makepkg.conf

echo -e "$hostname" > /etc/hostname
useradd -m -g users -G wheel,games,power,optical,storage,scanner,lp,audio,video,input,adm,users -s /bin/zsh $username
echo -en "$root_password\n$root_password" | passwd
echo -en "$user_password\n$user_password" | passwd $username

sed -i "s/^# %wheel/%wheel/g" /etc/sudoers

systemctl enable NetworkManager.service NetworkManager-wait-online.service fstrim.timer sshd.service earlyoom.service

tee -a /etc/pacman.conf << END

[multilib]
Include = /etc/pacman.d/mirrorlist
END

journalctl --vacuum-size=100M --vacuum-time=2weeks

touch /etc/sysctl.d/99-swappiness.conf
echo 'vm.swappiness=20' > /etc/sysctl.d/99-swappiness.conf

touch /etc/udev/rules.d/backlight.rules
tee -a /etc/udev/rules.d/backlight.rules << END
RUN+="/bin/chgrp video /sys/class/backlight/intel_backlight/brightness"
RUN+="/bin/chmod g+w /sys/class/backlight/intel_backlight/brightness"
END

touch /etc/udev/rules.d/81-backlight.rules
tee -a /etc/udev/rules.d/81-backlight.rules << END
SUBSYSTEM=="backlight", ACTION=="add", KERNEL=="intel_backlight", ATTR{brightness}="9000"
END

mkdir -p /etc/pacman.d/hooks/
touch /etc/pacman.d/hooks/100-systemd-boot.hook
tee -a /etc/pacman.d/hooks/100-systemd-boot.hook << END
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot
When = PostTransaction
Exec = /usr/bin/bootctl update
END

truncate -s 0 /swapspace/swapfile
chattr +C /swapspace/swapfile
btrfs property set /swapspace/swapfile compression none
fallocate -l 16G /swapspace/swapfile
mkswap /swapspace/swapfile
chmod 600 /swapspace/swapfile
tee -a /etc/fstab << END
/swapspace/swapfile none swap defaults,discard 0 0
END

sed -i "s/^HOOKS.*/HOOKS=(base systemd keyboard autodetect sd-vconsole modconf block sd-encrypt btrfs filesystems fsck)/g" /etc/mkinitcpio.conf
sed -i 's/^MODULES.*/MODULES=(intel_agp i915)/' /etc/mkinitcpio.conf
sed -i 's/^BINARIES.*/BINARIES=(btrfs)/' /etc/mkinitcpio.conf
mkinitcpio -P

grub-install --target=i386-pc --recheck $DRIVE
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
cat /etc/default/grub | sed -e 's/^\(\(GRUB_CMDLINE_LINUX_DEFAULT=\)\(.*\)\)$/#\1\n\2\3/' > /tmp/default-grub
cat /tmp/default-grub | awk 'm = $0 ~ /^GRUB_CMDLINE_LINUX_DEFAULT=/ {
        gsub(/quiet/, "quiet 'cryptdevice=UUID=$(blkid -s UUID -o value $ROOT):luks' 'root=/dev/mapper/cryptroot'", $0);
        print
    } !m { print }' > /etc/default/grub
rm /tmp/default-grub
grub-mkconfig -o /boot/grub/grub.cfg



EOF

umount -R /mnt
