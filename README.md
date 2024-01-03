# archery Arch Installation

Unattended Arch install

Basically boot to the arch live usb. Change layout, and connect to the Wi-Fi

## Change layout, and connect to the internet

``` bash
loadkeys uk
```

``` bash
iwctl
```

``` bash
station wlan0 connect (wifi-ssid)
```

## Getting the script

choose the version of the script you want to install, for intel use unattended-intel.sh for amd use unattended-amd.sh

``` bash
curl -O https://raw.githubusercontent.com/icaho/archery/main/unattended-intel.sh
```

``` bash
chmod +x unattended-intel.sh
```

### Now run the script

It will install everything on the NVMe at /dev/nvme0n1

``` bash
./unattended-intel.sh
```

## Desktop Install

Totally optional, will install my custom i3 or a base plasma.

### Grab the installer file

``` bash
curl -O https://raw.githubusercontent.com/icaho/archery/main/desktop-install.sh
```

``` bash
chmod +x desktop-install.sh
```

#### setup pacman and yay (aur)

``` bash
./desktop-install.sh -mc
```

#### install base packages

``` bash
./desktop-install.sh -py
```

#### install desktop of choice

I3

``` bash
./desktop-install.sh -i
```

Plasma

``` bash
./desktop-install.sh -k
```

add the -d flag to auto remove the script after running
