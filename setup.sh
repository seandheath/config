#!/bin/bash

set -e
set -o pipefail
WD=$(pwd)

if [ $(hostname) = "localhost" ]; then
	echo "Please enter new hostname: "
	read HNAME
	sudo hostnamectl set-hostname $HNAME
	echo "Please close and reopen shell to read new hostname."
	exit 1
fi

say(){
	echo ""
	echo "$(tput bold)$1$(tput sgr0)"
}

if [ ! -f /etc/yum.repos.d/rpmfusion-free.repo ]; then
	say "Installing RPM Fusion"
	sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
fi

if [ ! -f /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:pschyska:alacritty.repo ]; then
	say "Adding COPR repository for Alacritty"
	sudo dnf copr enable -y pschyska/alacritty
fi

if [ ! -f /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:gregw:i3desktop.repo ]; then
	say "Adding COPR repository for i3-gaps"
	sudo dnf copr enable -y gregw/i3desktop
fi

if [ ! -f /etc/yum.repos.d/vscodium.repo ]; then
	say "Adding VSCodium Repository"
	sudo rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
	printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=gitlab.com_paulcarroty_vscodium_repo\nbaseurl=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/repos/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg" |sudo tee -a /etc/yum.repos.d/vscodium.repo
fi

if [ ! -f /etc/yum.repos.d/nordvpn.repo ]; then
	say "Adding repository for NordVPN"
	sudo dnf install -y https://repo.nordvpn.com/yum/nordvpn/centos/noarch/Packages/n/nordvpn-release-1.0.0-1.noarch.rpm
fi

say "Installing packages"
sudo dnf install -y $(sort -u ./packages.txt)
pip install --user $(sort -u ./pip.txt)

if [ ! -f /etc/X11/xorg.conf.d/20-nvidia.conf ]; then
	say "Setting up NVIDIA for $(hostname)"
	sudo cp files/nvidia-$(hostname) /etc/X11/xorg.conf.d/20-nvidia.conf
fi

say "Updating .profile"
cp files/profile ~/.profile

say "Updating alacritty"
mkdir -p ~/.config/alacritty
cp files/alacritty.yml ~/.config/alacritty/

say "Updating i3"
mkdir -p ~/.config/i3
cp files/i3config ~/.config/i3/config
cat files/i3config-$(hostname) >> ~/.config/i3/config

say "Updating git"
mkdir -p ~/.config/git
cp files/git ~/.config/git/config

say "Updating governor"
sudo cp files/{ac.target,battery.target,governor.service} /etc/systemd/system/
sudo cp files/update_governor.sh /usr/bin/update_governor
sudo chmod 755 /usr/bin/update_governor
sudo systemctl enable --now governor.service

say "Updating flatpaks"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

say "Installing pdfannots"
sudo cp files/pdfannots /usr/bin/pdfannots
sudo chmod 755 /usr/bin/pdfannots


if [ ! -d ~/.cargo ]; then
	say "Installing rust"
	curl -sSL -o /tmp/rustup.sh https://sh.rustup.rs
	chmod +x /tmp/rustup.sh
	/tmp/rustup.sh -y
else
	say "Rust already installed"
fi

if [ ! -d ~/.nvm ]; then
	say "Installing NVM"
	curl -sSL -o /tmp/nvm.sh https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh
	chmod +x /tmp/nvm.sh
	/tmp/nvm.sh
	source ~/.bash_profile
	nvm install node
else
	say "NVM already installed"
fi

if [ ! -d ~/.rvm ]; then
	say "Installing RVM"
	curl -sSL -o /tmp/rvm.sh https://get.rvm.io
	chmod +x /tmp/rvm.sh
	/tmp/rvm.sh stable --ruby
else
	say "RVM already installed"
fi

if [ ! -d ~/.config/bash ]; then
	say "Setting up bash"
	git clone https://github.com/seandheath/bash.git ~/.config/bash
	~/.config/bash/setup.sh
	cd $WD
else
	say "Bash already configured"
fi

if [ ! -d ~/.config/nvim ]; then
	say "Setting up nvim"
	git clone https://github.com/seandheath/vim.git ~/.config/nvim
	~/.config/nvim/setup.sh
	cd $WD
else 
	say "nvim already configured"
fi

dconf write /org/mate/desktop/session/required-components-list '["windowmanager", "panel"]'
dconf write /org/mate/desktop/session/required-components/windowmanager "'i3'"
