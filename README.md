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
``` bash
curl -O https://raw.githubusercontent.com/icaho/archery/master/unattended.sh
```

``` bash
chmod +x unattended.sh
```

## Now run the script
It will install everything on the NVMe at /dev/nvme0n1
``` bash
./unattended.sh
```