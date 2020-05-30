#!/bin/bash

set -e 

say(){
    echo ""
    echo "$(tput bold)$1$(tput sgr0)"
}

say "Updating Config Files"
echo "alacritty"
mkdir -p ~/.config/alacritty
cp files/alacritty.yml ~/.config/alacritty/

echo "i3"
mkdir -p ~/.config/i3
cp files/i3config ~/.config/i3/config
cat files/i3config-$(hostname) >> ~/.config/i3/config

echo "i3status-rust"
mkdir -p ~/.config/i3status
cp files/i3status-$(hostname) ~/.config/i3status/config.toml

echo "git"
git config --global user.name "Sean Heath"
git config --global user.email "se@nheath.com"

echo "podman"
echo "user:100000:65536" | sudo tee /etc/subuid
echo "user:100000:65536" | sudo tee /etc/subgid

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

if [ ! -f /usr/bin/update_governor ]; then
	say "Updating CPU Governor"
	sudo cp files/{ac.target,battery.target,governor.service} /etc/systemd/system/
	sudo cp files/update_governor.sh /usr/bin/update_governor
	sudo chmod 755 /usr/bin/update_governor
	sudo cp files/99-powertargets.rules /etc/udev/rules.d/
	sudo systemctl enable --now governor.service
fi

say "Setting npm config"
npm config set prefix ~/.npm

say "Enabling Services"
echo "resilio sync"
systemctl enable --user --now rslsync
echo "psd"
systemctl --user enable --now psd
echo "cockpit"
sudo systemctl enable --now cockpit.socket

say "Enabling ufw"
sudo ufw enable

dconf write /org/mate/desktop/session/required-components-list '["windowmanager", "panel"]'
dconf write /org/mate/desktop/session/required-components/windowmanager "'i3'"
