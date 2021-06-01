#!/bin/bash

set -e 

say(){
    echo ""
    echo "$(tput bold)$1$(tput sgr0)"
}

WD=$(pwd)

say "Updating Profile"
cp files/profile ~/.profile
source ~/.profile
echo "PATH: $PATH"

say "Configuring Yay"
yay --save --sudoloop
sudo sed -i "/PKGEXT='.pkg.tar.xz'/ c\\PKGEXT='.pkg.tar'" /etc/makepkg.conf
sudo sed -i "/BUILDENV=(!distcc color !ccache check !sign)/ c\\BUILDENV=(!distcc color ccache check !sign)" /etc/makepkg.conf

say "Pacman"
sudo sed -i "s/#\[multilib\]/[multilib]" /etc/pacman.conf
sudo sed -i "s/#Include = \/etc\/pacman\.d\/mirrorlist/Include = \/etc\/pacman.d\/mirrorlist/" /etc/pacman.conf
sudo pacman --needed --noconfirm -Syyu $(sort -u ./pacman.txt)
say "Pip"
pip install --user $(sort -u ./pip.txt)
say "Yay"
yay --norebuild --noconfirm -S $(echo $(cat ./yay.txt))

if [ ! -d ~/.cargo ]; then
    say "Rust"
    curl -sSL -o /tmp/rustup.sh https://sh.rustup.rs
    chmod +x /tmp/rustup.sh
    /tmp/rustup.sh -y
fi

if [ ! -d ~/go/bin ]; then
	say "Go"
	mkdir -p ~/go/bin
	export GOPATH="~/go"
	export PATH="$PATH:~/go/bin"
fi

if [ ! -d ~/.config/bash ]; then
    say "Installing Bash Config"
    git clone https://github.com/seandheath/bash.git ~/.config/bash
    ~/.config/bash/setup.sh
    cd $WD
fi

if [ ! -d ~/.config/nvim ]; then
    say "Installing neovim Config"
    git clone https://github.com/seandheath/vim.git ~/.config/nvim
    ~/.config/nvim/setup.sh
    cd $WD
fi
if [ ! -f /usr/bin/vim ]; then
    sudo ln -s /usr/bin/nvim /usr/bin/vim
fi

say "Updating Config Files"
echo "git"
git config --global user.name "Sean Heath"
git config --global user.email "se@nheath.com"

echo 'gnome'
dconf load / < files/gnome.conf

say "Enabling Services"
echo "syncthing"
sudo systemctl enable --now syncthing@user
