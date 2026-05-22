#!/bin/bash
set -e
echo "[*] Android Recovery Tool"
read -p "Device serial: " DEVICE
adb -s $DEVICE reboot bootloader
sleep 2
fastboot -s $DEVICE devices
echo "[✓] Device ready for recovery operations"
