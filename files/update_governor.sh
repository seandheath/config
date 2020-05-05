#!/bin/bash

if [ -d "/sys/class/power_supply/AC" ]; then
  echo "laptop" 
else
  echo "desktop"
  cpupower frequency-set -g performance
fi
