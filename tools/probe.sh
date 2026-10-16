#!/usr/bin/env bash
# Probe for the Airwave on USB and on the LAN.
# Usage: ./tools/probe.sh
set -uo pipefail

echo "=== USB devices (non-hub) ==="
system_profiler SPUSBDataType 2>/dev/null \
  | grep -E 'Product ID|Vendor ID|Serial Number|^ {4,}[A-Za-z].*:$' \
  | grep -v -i 'dell dock' || echo "  (none readable)"

echo
echo "=== ioreg USB names ==="
ioreg -p IOUSB -l -w 0 2>/dev/null \
  | grep -E '"(USB Product Name|USB Vendor Name|idVendor|idProduct)"' \
  || echo "  (none)"

echo
echo "=== ADB ==="
adb start-server >/dev/null 2>&1
adb devices -l

echo
echo "=== Disk / mass storage ==="
diskutil list external 2>/dev/null | head -20

echo
echo "=== LAN sweep for adbd:5555 and common ports ==="
SUBNET=$(ipconfig getifaddr en0 2>/dev/null | sed 's/\.[0-9]*$/.0\/24/')
if [ -n "${SUBNET:-}" ]; then
  echo "  subnet: $SUBNET"
  nmap -p 5555,5037,22,23,80,8080 --open -T4 "$SUBNET" 2>/dev/null \
    | grep -E 'Nmap scan report|open'
else
  echo "  could not determine subnet (en0 down?)"
fi
