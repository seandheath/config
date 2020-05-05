#!/bin/bash

if [ -d "/sys/class/power_supply/AC" ]; then
  echo "On Laptop"
  if $(udevadm info -a -p /sys/class/power_supply/AC | grep -q 'ATTR{online}=="1"'); then
    echo "On AC"
    cpupower frequency-set -g performance
  else
    echo "On Battery"
    cpupower frequency-set -g powersave
  fi
else
  echo "On Desktop"
  cpupower frequency-set -g performance
fi
