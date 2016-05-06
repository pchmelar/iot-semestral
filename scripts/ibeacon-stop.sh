#!/bin/sh
echo "Disabling virtual iBeacon..."
sudo hciconfig hci0 noleadv
echo "Complete!"