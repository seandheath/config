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

echo "i3status-rust"
mkdir -p ~/.config/i3status
cp files/i3status ~/.config/i3status/config.toml

echo "git"
git config --global user.name "Sean Heath"
git config --global user.email "se@nheath.com"

say "Removing directories"
rm -rf $HOME/{Documents,Music,Pictures,Public,Templates,Videos}

say "Enabling Services"
echo "psd"
systemctl --user enable --now psd

dconf write /org/mate/desktop/session/required-components-list '["windowmanager", "panel"]'
dconf write /org/mate/desktop/session/required-components/windowmanager "'i3'"
