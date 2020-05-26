#!/bin/bash
set -e 

say(){
    echo ""
    echo "$(tput bold)$1$(tput sgr0)"
}

say "Configuring Yay"
sudo sed -i "/PKGEXT='.pkg.tar.xz'/ c\\PKGEXT='.pkg.tar'" /etc/makepkg.conf
sudo sed -i "/BUILDENV=(!distcc color !ccache check !sign)/ c\\BUILDENV=(!distcc color ccache check !sign)" /etc/makepkg.conf

say "Pacman"
sudo pacman --needed --noconfirm -Syyu $(sort -u ./pacman.txt)
say "Pip"
pip install --user $(sort -u ./pip.txt)
say "Yay"
yay --needed --noconfirm -S $(sort -u ./yay.txt)

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
say "Removing directories"
rm -rf $HOME/{Documents,Music,Pictures,Public,Templates,Videos}

say "Updating Config Files"
echo "alacritty"
mkdir -p ~/.config/alacritty
cp files/alacritty.yml ~/.config/alacritty/

echo "i3"
mkdir -p ~/.config/i3
cp files/i3config ~/.config/i3/config

echo "i3status-rust"
mkdir -p ~/.config/i3status
cp files/i3status-$(hostname) ~/.config/i3status/config.toml

echo "git"
git config --global user.name "Sean Heath"
git config --global user.email "se@nheath.com"

if [ ! -f /etc/X11/xorg.conf.d/20-nvidia.conf ]; then
    echo "nvidia"
    sudo cp files/nvidia-$(hostname) /etc/X11/xorg.conf.d/20-nvidia.conf
fi

if [ ! -d ~/.config/bash ]; then
    echo "bash"
    git clone https://github.com/seandheath/bash.git ~/.config/bash
    ~/.config/bash/setup.sh
    cd $WD
fi

if [ ! -d ~/.config/nvim ]; then
    echo "nvim"
    git clone https://github.com/seandheath/vim.git ~/.config/nvim
    ~/.config/nvim/setup.sh
    cd $WD
fi
if [ ! -f /usr/bin/vim ]; then
    sudo ln -s /usr/bin/nvim /usr/bin/vim
fi

if [ ! -f /usr/bin/update_governor ]; then
	say "Updating CPU Governor"
	sudo cp files/{ac.target,battery.target,governor.service} /etc/systemd/system/
	sudo cp files/update_governor.sh /usr/bin/update_governor
	sudo chmod 755 /usr/bin/update_governor
	sudo cp files/99-powertargets.rules /etc/udev/rules.d/
	sudo systemctl enable --now governor.service
fi

say "Enabling Services"
echo "resilio sync"
systemctl enable --user --now rslsync
echo "psd"
systemctl --user enable --now psd

say "Disabling Services"
echo "libvirtd"
sudo systemctl disable --now libvirtd

say "Setting iptables rules"
sudo ./files/iptables.sh

dconf write /org/mate/desktop/session/required-components-list '["windowmanager", "panel"]'
dconf write /org/mate/desktop/session/required-components/windowmanager "'i3'"
