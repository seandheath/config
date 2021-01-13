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
#npm config set prefix ~/.npm

echo "rslsync"
mkdir -p ~/.config/rslsync
mkdir ~/.sync
cp files/rslsync.conf ~/.config/rslsync/rslsync.conf

echo 'gnome'
dconf load / < files/gnome.conf

say "Removing directories"
rm -rf $HOME/{Documents,Music,Pictures,Public,Templates,Videos}

say "Enabling Services"
echo "resilio sync"
systemctl enable --user --now rslsync
echo "syncthing"
sudo systemctl enable --now syncthing@user
