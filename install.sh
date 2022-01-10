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
                if [ "$OS" == "Fedora Linux" ]; then
                        # Fedora

                        zenity --question --width 500\
                            --text="Fedora Detected. It needs to intigrate the rpmfusion repository for ffmpeg. Do you agree with this?"

                        case $? in 
                        0) 
                            echo Installing Fedora Dependencies
                            echo Add rpmfusion repository for ffmpeg
                            dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm 
                            echo Installing dev tools and dependencies
                            dnf install -y cmake gcc-c++ vala pkgconfig gtk3-devel clutter-devel clutter-gtk-devel clutter-gst3-devel youtube-dl ffmpeg && STATUS="OK"
                            ;;
                        1) 
                            zenity --info --width 500\
                              --text="Unfortunately, it is not possible for me to work like this."
                            exit 0
                            ;;
                        -1)
                            zenity --info --width 500\
                              --text="Oops. This should not have happened...."
                            exit 0
                            ;;
                        esac
                
                elif [[ "$OS" == "Manjaro Linux" ]]; then
			        # Manjaro
                    zenity --question --width 500\
                            --text="Manjaro Detected. Is this correct?"
                    case $? in 
                        0)  
                            echo Renewing Package Database
                            pacman -Sy
                            echo Installing Manjaro Dependencies  
			                pacman -S base-devel ffmpeg youtube-dl cmake vala pkgconfig gtk3 clutter clutter-gtk clutter-gst gst-libav --noconfirm --needed && STATUS="OK"
                            ;;
                        1) 
                            zenity --info --width 500\
                              --text="Unfortunately, it is not possible for me to work like this."
                            exit 0
                            ;;
                        -1)
                            zenity --info --width 500\
                              --text="Oops. This should not have happened...."
                            exit 0
                            ;;
                        esac
                elif [[ "$OS" == "Arch Linux" ]]; then
			        # Arch
                    zenity --question --width 500\
                            --text="Arch Linux Detected. Is this correct?"
                    case $? in 
                        0)  
                            echo Renewing Package Database
                            pacman -Sy
                            echo Installing Arch Linux Dependencies       
			                pacman -S git base-devel ffmpeg youtube-dl cmake vala pkgconfig gtk3 clutter clutter-gtk clutter-gst gst-libav --noconfirm --needed && STATUS="OK"
                            ;;
                        1) 
                            zenity --info --width 500\
                              --text="Unfortunately, it is not possible for me to work like this."
                            exit 0
                            ;;
                        -1)
                            zenity --info --width 500\
                              --text="Oops. This should not have happened..."
                            exit 0
                            ;;
                        esac
                elif [[ "$OS" == "Ubuntu" ]]; then
			        # Ubuntu
                    zenity --question --width 500\
                            --text="Ubuntu Detected. Is this correct?"
                    case $? in 
                        0)  
                            echo Renewing Package Database
                            apt-get update
                            echo Installing Ubuntu Dependencies       
                            apt install git ffmpeg youtube-dl valac cmake pkg-config libgtk-3-dev libclutter-gtk-1.0-dev libclutter-gst-3.0-dev build-essential --yes && STATUS="OK" 
			    ;;
                        1) 
                            zenity --info --width 500\
                              --text="Unfortunately, it is not possible for me to work like this."
                            exit 0
                            ;;
                        -1)
                            zenity --info --width 500\
                              --text="Oops. This should not have happened..."
                            exit 0
                            ;;
                        esac
                else
			            echo "This OS is not Supported!"        
                fi


    if [ "$STATUS" == "OK" ]; then
        # Clone and Install animated-wallpaper
        echo 'Cloning animated-wallpaper from github. (https://github.com/Ninlives/animated-wallpaper)'

        git clone https://github.com/Ninlives/animated-wallpaper
        cd animated-wallpaper
        cmake . && make && sudo make install
        cd ..
        rm -rf animated-wallpaper

        # Clone and Install animated_wallpaper_helper

        cp -r awp /usr/local/share/
        cp awp.desktop /usr/share/applications/
        chmod +x /usr/local/share/awp/awp.sh
        chmod +x /usr/local/share/awp/awp-autostart.sh
    
    else
        echo "Sorry but the Installer does not work on your system!"

    fi
fi

