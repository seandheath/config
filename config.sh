#!/bin/bash

set -e 

say(){
    echo ""
    echo "$(tput bold)$1$(tput sgr0)"
}

say "Updating Config Files"
echo "git"
git config --global user.name "Sean Heath"
git config --global user.email "se@nheath.com"

echo "podman"
echo "user:100000:65536" | sudo tee /etc/subuid
echo "user:100000:65536" | sudo tee /etc/subgid
podman system migrate

echo 'npm'
npm config set prefix ~/.npm

echo "rslsync"
mkdir -p ~/.config/rslsync
cp files/rslsync.conf ~/.config/rslsync/rslsync.conf

if [ ! -f /etc/X11/xorg.conf.d/20-nvidia.conf ]; then
    echo "nvidia"
    sudo cp files/nvidia-$(hostname) /etc/X11/xorg.conf.d/20-nvidia.conf
fi

say "Removing directories"
rm -rf $HOME/{Documents,Music,Pictures,Public,Templates,Videos}

say "Setting npm config"
npm config set prefix ~/.npm

say "Enabling Services"
echo "resilio sync"
systemctl enable --user --now rslsync
echo "psd"
systemctl --user enable --now psd
