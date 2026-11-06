#!/bin/bash
set -eu

###############################################################################
# Packages
###############################################################################
filter_list() {
  sed 's/#.*//; s/[[:space:]]*$//' "$1" | grep -v '^$'
}

sudo pacman -Suy

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
systemctl --user enable --now kanshi.service
systemctl --user enable --now nm-applet.service
systemctl --user enable --now polkit-gnome-agent.service
systemctl --user enable --now cliphist-image.service
systemctl --user enable --now cliphist-text.service
systemctl --user enable --now gnome-keyring.service
systemctl --user enable --now swayidle.service
systemctl --user enable --now swaync.service
systemctl --user enable --now swayosd.service
systemctl --user enable --now udiskie.service
systemctl --user enable --now wlsunset.service
systemctl --user enable --now syncthing.service

# Disable dbus autostart of nextcloud
systemctl --user mask com.nextcloud.desktopclient.nextcloud.service

###############################################################################
# User
###############################################################################

# Groups
sudo usermod -aG docker "$USER"
sudo usermod -aG scanner "$USER"
sudo usermod -aG wheel "$USER"

# Shell
sudo chsh -s /bin/zsh "$USER"

# Defaults
# Terminal (für nvim.desktop & andere Terminal-Apps)
handlr set x-scheme-handler/terminal Alacritty.desktop

# Ordner
handlr set inode/directory nemo.desktop

# Browser
handlr set text/html firefox.desktop
handlr set application/xhtml+xml firefox.desktop
handlr set x-scheme-handler/http firefox.desktop
handlr set x-scheme-handler/https firefox.desktop
handlr set x-scheme-handler/about firefox.desktop
handlr set x-scheme-handler/unknown firefox.desktop
handlr set x-scheme-handler/chrome firefox.desktop
handlr set application/x-extension-htm firefox.desktop
handlr set application/x-extension-html firefox.desktop
handlr set application/x-extension-shtml firefox.desktop
handlr set application/x-extension-xht firefox.desktop
handlr set application/x-extension-xhtml firefox.desktop

# Text / Code
handlr set text/plain nvim.desktop
handlr set text/markdown nvim.desktop
handlr set text/x-log nvim.desktop
handlr set text/x-readme nvim.desktop
handlr set text/x-shellscript nvim.desktop
handlr set application/x-shellscript nvim.desktop
handlr set text/x-python nvim.desktop
handlr set text/x-python3 nvim.desktop
handlr set text/x-csrc nvim.desktop
handlr set text/x-chdr nvim.desktop
handlr set text/x-c++src nvim.desktop
handlr set text/x-c++hdr nvim.desktop
handlr set text/x-rust nvim.desktop
handlr set text/x-go nvim.desktop
handlr set text/x-java nvim.desktop
handlr set text/x-lua nvim.desktop
handlr set application/x-ruby nvim.desktop
handlr set text/css nvim.desktop
handlr set text/javascript nvim.desktop
handlr set application/javascript nvim.desktop
handlr set application/x-php nvim.desktop
handlr set application/json nvim.desktop
handlr set application/toml nvim.desktop
handlr set application/x-yaml nvim.desktop
handlr set application/yaml nvim.desktop
handlr set application/xml nvim.desktop
handlr set text/xml nvim.desktop
handlr set text/x-makefile nvim.desktop
handlr set text/x-cmake nvim.desktop
handlr set text/x-patch nvim.desktop
handlr set text/x-diff nvim.desktop
handlr set application/sql nvim.desktop
handlr set application/x-desktop nvim.desktop

# Bilder
handlr set image/png imv.desktop
handlr set image/jpeg imv.desktop
handlr set image/gif imv.desktop
handlr set image/webp imv.desktop
handlr set image/bmp imv.desktop
handlr set image/tiff imv.desktop
handlr set image/avif imv.desktop
handlr set image/heic imv.desktop
handlr set image/heif imv.desktop
handlr set image/jxl imv.desktop
handlr set image/x-icon imv.desktop
handlr set image/svg+xml imv.desktop

# Video
handlr set video/mp4 mpv.desktop
handlr set video/x-matroska mpv.desktop
handlr set video/webm mpv.desktop
handlr set video/quicktime mpv.desktop
handlr set video/x-msvideo mpv.desktop
handlr set video/mpeg mpv.desktop
handlr set video/ogg mpv.desktop
handlr set video/x-flv mpv.desktop
handlr set video/3gpp mpv.desktop
handlr set video/x-ms-wmv mpv.desktop
handlr set video/mp2t mpv.desktop

# Audio
handlr set audio/mpeg mpv.desktop
handlr set audio/flac mpv.desktop
handlr set audio/ogg mpv.desktop
handlr set audio/x-vorbis+ogg mpv.desktop
handlr set audio/opus mpv.desktop
handlr set audio/wav mpv.desktop
handlr set audio/x-wav mpv.desktop
handlr set audio/aac mpv.desktop
handlr set audio/mp4 mpv.desktop
handlr set audio/x-m4a mpv.desktop
handlr set audio/webm mpv.desktop
handlr set audio/x-mpegurl mpv.desktop
handlr set application/x-mpegurl mpv.desktop

# PDF & Dokumente
handlr set application/pdf okularApplication_pdf.desktop
handlr set application/epub+zip okularApplication_epub.desktop
handlr set image/vnd.djvu okularApplication_djvu.desktop
handlr set application/postscript okularApplication_ghostview.desktop

# Archive
handlr set application/zip xarchiver.desktop
handlr set application/x-tar xarchiver.desktop
handlr set application/gzip xarchiver.desktop
handlr set application/x-compressed-tar xarchiver.desktop
handlr set application/x-bzip2 xarchiver.desktop
handlr set application/x-bzip-compressed-tar xarchiver.desktop
handlr set application/x-xz xarchiver.desktop
handlr set application/x-xz-compressed-tar xarchiver.desktop
handlr set application/zstd xarchiver.desktop
handlr set application/x-zstd-compressed-tar xarchiver.desktop
handlr set application/vnd.rar xarchiver.desktop
handlr set application/x-rar xarchiver.desktop
handlr set application/x-rar-compressed xarchiver.desktop
handlr set application/x-7z-compressed xarchiver.desktop

# Office
handlr set application/msword libreoffice-writer.desktop
handlr set application/rtf libreoffice-writer.desktop
handlr set application/vnd.oasis.opendocument.text libreoffice-writer.desktop
handlr set application/vnd.openxmlformats-officedocument.wordprocessingml.document libreoffice-writer.desktop
handlr set application/vnd.ms-excel libreoffice-calc.desktop
handlr set text/csv libreoffice-calc.desktop
handlr set application/vnd.oasis.opendocument.spreadsheet libreoffice-calc.desktop
handlr set application/vnd.openxmlformats-officedocument.spreadsheetml.sheet libreoffice-calc.desktop
handlr set application/vnd.ms-powerpoint libreoffice-impress.desktop
handlr set application/vnd.oasis.opendocument.presentation libreoffice-impress.desktop
handlr set application/vnd.openxmlformats-officedocument.presentationml.presentation libreoffice-impress.desktop

# Mail, Kalender, Feeds
handlr set message/rfc822 org.mozilla.Thunderbird.desktop
handlr set x-scheme-handler/mailto org.mozilla.Thunderbird.desktop
handlr set x-scheme-handler/mid org.mozilla.Thunderbird.desktop
handlr set text/calendar org.mozilla.Thunderbird.desktop
handlr set application/x-extension-ics org.mozilla.Thunderbird.desktop
handlr set x-scheme-handler/webcal org.mozilla.Thunderbird.desktop
handlr set x-scheme-handler/webcals org.mozilla.Thunderbird.desktop
handlr set application/rss+xml org.mozilla.Thunderbird.desktop
handlr set application/x-extension-rss org.mozilla.Thunderbird.desktop
handlr set x-scheme-handler/feed org.mozilla.Thunderbird.desktop
handlr set x-scheme-handler/news org.mozilla.Thunderbird.desktop
handlr set x-scheme-handler/nntp org.mozilla.Thunderbird.desktop
handlr set x-scheme-handler/snews org.mozilla.Thunderbird.desktop
handlr set x-scheme-handler/net.thunderbird org.mozilla.Thunderbird.desktop

# Signal
handlr set x-scheme-handler/sgnl signal.desktop
handlr set x-scheme-handler/signalcaptcha signal.desktop
