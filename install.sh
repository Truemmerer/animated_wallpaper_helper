#!/bin/bash

if (whoami != root)
  then echo "Please run as root"

  else

# Detect OS
if [[ -e /etc/fedora-release ]]; then
	os="fedora"
	os_version=$(grep -oE '[0-9]+' /etc/fedora-release | head -1)
fi

# Install Dependencies
		if [[ "$os" == "fedora" ]]; then
			# Fedora
			echo Install Fedora Dependencies 
			dnf install -y cmake vala pkgconfig gkt3-devel clutter-devel clutter-gtk clutter-gst3-devel youtube-dl 
		fi

# Clone and Install animated-wallpaper
echo Clone animated-wallpaper from github. (https://github.com/Ninlives/animated-wallpaper)

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

exit