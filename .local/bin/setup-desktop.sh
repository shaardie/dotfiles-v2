#!/bin/bash
set -eu

###############################################################################
# Packages
###############################################################################
filter_list() {
  sed 's/#.*//; s/[[:space:]]*$//' "$1" | grep -v '^$'
}

sudo pacman -S --needed $(filter_list ~/.config/pkglist/packages.txt)

# install yay
if ! which yay; then
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (
    cd /tmp/yay
    makepkg -si
  )
fi

# install aur packages
yay -S --needed $(filter_list ~/.config/pkglist/aur-packages.txt)

###############################################################################
# Services
###############################################################################

# Better safe
sudo systemctl daemon-reload
systemctl --user daemon-reload

# Display Manager
sudo systemctl enable gdm.service

# Network
sudo systemctl enable --now NetworkManager.service

# Timesync
sudo systemctl enable --now systemd-timesyncd.service

# Bluetooth
sudo systemctl enable --now bluetooth.service

# SDD Trim
sudo systemctl enable --now fstrim.timer

# Cleanup Pacman Cache
sudo systemctl enable --now paccache.timer

# Reflector to keep pacman mirrorlist up to date
# trigger now and enable timer
sudo systemctl enable --now reflector.timer
sudo systemctl start reflector.service # jetzt einmalig triggern

# Keep pkgfile database up to date
# trigger now and enable timer
sudo systemctl enable --now pkgfile-update.timer
sudo systemctl start pkgfile-update.service # jetzt einmalig triggern

# Printing
sudo systemctl enable --now cups.socket

# Docker
sudo systemctl enable --now docker.socket

# User services
systemctl --user enable --now ssh-agent.service

###############################################################################
# User
###############################################################################

# Groups
sudo usermod -aG docker "$USER"
sudo usermod -aG scanner "$USER"
sudo usermod -aG wheel "$USER"
sudo usermod -aG sudo "$USER"

# Shell
sudo chsh -s /bin/zsh "$USER"
