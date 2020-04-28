#!/bin/bash

echo "Ensure you change hostname:"
echo "hostnamectl set-hostname <name>"
sudo dnf install ansible
bash run.sh

