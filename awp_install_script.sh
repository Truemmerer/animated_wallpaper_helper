#!/bin/bash

if [ $(whoami) != 'root' ]; then
  echo "Please run as root"

  else

    # Detect OS
if [ -f /etc/os-release ]; then
        # freedesktop.org and systemd
        . /etc/os-release
    OS=$NAME
elif type lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -si)
elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

# Install Dependencies
        if [ "$OS" == "Fedora" ]; then
            # Fedora
            echo Install Fedora Dependencies
            dnf install -y cmake vala pkgconfig gtk3-devel clutter-devel clutter-gtk clutter-gst3-devel youtube-dl
        elif [ "$OS" == "Debian" ]; then
            # Debian
            echo Install Debian Dependencies
            apt install -y build-essential vala pkgconfig gtk3-devel clutter-devel clutter-gtk clutter-gst3-devel youtube-dl
        fi

# Clone and Install animated-wallpaper
echo 'Clone animated-wallpaper from github. (https://github.com/Ninlives/animated-wallpaper)'

git clone https://github.com/Ninlives/animated-wallpaper
cd animated-wallpaper
cmake . && make && make install
cd ..
rm -rf animated-wallpaper

# Clone and Install animated_wallpaper_helper

mv awp /usr/local/share/
mv animation-wallpaper.desktop /usr/share/applications/
chmod +x /usr/local/share/awp/awp.sh
chmod +x /usr/local/share/awp/awp_autostart.sh

fi

exit 0
