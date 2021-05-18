# Debian based systems only more Distros needs to be added


#!/bin/bash

# Detect OS
if grep -qs "ubuntu" /etc/os-release; then
	os="ubuntu"
	os_version=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
elif [[ -e /etc/debian_version ]]; then
	os="debian"
	os_version=$(grep -oE '[0-9]+' /etc/debian_version | head -1)
elif [[ -e /etc/centos-release ]]; then
	os="centos"
	os_version=$(grep -oE '[0-9]+' /etc/centos-release | head -1)
elif [[ -e /etc/fedora-release ]]; then
	os="fedora"
	os_version=$(grep -oE '[0-9]+' /etc/fedora-release | head -1)
else
	echo "This installer seems to be running on an unsupported distribution.
Supported distributions are Arch, Ubuntu, Debian, CentOS, and Fedora."
	exit
fi

if [[ "$os" == "ubuntu" && "$os_version" -lt 1804 ]]; then
	echo "Ubuntu 18.04 or higher is required to use this installer.
This version of Ubuntu is too old and unsupported."
	exit
fi

if [[ "$os" == "debian" && "$os_version" -lt 10 ]]; then
	echo "Debian 10 or higher is required to use this installer.
This version of Debian is too old and unsupported."
	exit
fi

if [[ "$os" == "centos" && "$os_version" -lt 7 ]]; then
	echo "CentOS 7 or higher is required to use this installer.
This version of CentOS is too old and unsupported."
	exit
fi

# Install Dependencies
		if [[ "$os" == "ubuntu" ]]; then
			# Ubuntu
			apt update
			apt install -y youtube-dl cmake
		elif [[ "$os" == "debian" && "$os_version" -eq 10 ]]; then
			# Debian 10
			apt update
      apt install -y youtube-dl cmake
		elif [[ "$os" == "centos" && "$os_version" -eq 8 ]]; then
			# CentOS 8
			dnf install -y youtube-dl cmake
		elif [[ "$os" == "centos" && "$os_version" -eq 7 ]]; then
			# CentOS 7
			yum install -y youtube-dl cmake
		elif [[ "$os" == "fedora" ]]; then
			# Fedora
			dnf install -y youtube-dl
		fi
    
# Clone and Install animated-wallpaper
git clone https://github.com/Ninlives/animated-wallpaper
cd animated-wallpaper
cmake . && make && make install

# Clone and Install animated_wallpaper_helper
git clone https://github.com/Truemmerer/animated_wallpaper_helper.git
mv awp /usr/local/share/
mv animation-wallpaper.desktop /usr/share/applications/
chmod +x /usr/local/share/awp/awp.sh
chmod +x /usr/local/share/awp/awp_autostart.sh
