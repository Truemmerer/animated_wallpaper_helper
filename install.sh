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
                        echo Add rpmfusion repository for ffmpeg
                        dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm 
                        echo Install dev tools and dependencies
                        dnf install -y cmake gcc-c++ vala pkgconfig gtk3-devel clutter-devel clutter-gtk-devel clutter-gst3-devel youtube-dl ffmpeg
                fi


# Clone and Install animated-wallpaper
echo 'Clone animated-wallpaper from github. (https://github.com/Ninlives/animated-wallpaper)'

git clone https://github.com/Ninlives/animated-wallpaper
cd animated-wallpaper
cmake . && make && make install
cd ..
rm -rf animated-wallpaper

# Clone and Install animated_wallpaper_helper

cp -r awp /usr/local/share/
cp awp.desktop /usr/share/applications/
chmod +x /usr/local/share/awp/awp.sh
chmod +x /usr/local/share/awp/awp-autostart.sh

fi

