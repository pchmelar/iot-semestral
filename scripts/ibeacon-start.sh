#!/bin/sh
echo "Launching virtual iBeacon..."
sudo hciconfig hci0 up
sudo hciconfig hci0 noleadv
sudo hciconfig hci0 leadv 3
sudo hciconfig hci0 noscan
sudo hcitool -i hci0 cmd 0x08 0x0008 1E 02 01 1A 1A FF 4C 00 02 15 E2 0A 39 F4 73 F5 4B C4 A1 2F 17 D1 AD 07 A9 61 00 00 00 00 C8 00
echo "Complete! iBeacon UUID: e20a39f4-73f5-4bc4-a12f-17d1ad07a961"