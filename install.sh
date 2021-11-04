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
                            --text="Installation for Fedora initiated. It needs to intigrate the rpmfusion repository for ffmpeg. Do you agree with this?"

                        case $? in 
                        0) 
                            echo Install Fedora Dependencies
                            echo Add rpmfusion repository for ffmpeg
                            dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm 
                            echo Install dev tools and dependencies
                            dnf install -y cmake gcc-c++ vala pkgconfig gtk3-devel clutter-devel clutter-gtk-devel clutter-gst3-devel youtube-dl ffmpeg && STATUS="OK"
                            ;;
                        1) 
                            zenity --info --width 500\
                              --text="Unfortunately, it is not possible for me to work like this."
                            exit 0
                            ;;
                        -1)
                            zenity --info --width 500\
                              --text="Oops. This should not happen."
                            exit 0
                            ;;
                        esac
                
                elif [[ "$OS" == "Manjaro Linux" ]]; then
			        # Manjaro
                    zenity --question --width 500\
                            --text="Installation for Manjaro initiated. Is tis correct?"
                    case $? in 
                        0)  
                            echo Renew Package Database
                            pacman -Sy
                            echo Install Manjaro Dependencies  
			                pacman -S base-devel ffmpeg youtube-dl cmake vala pkgconfig gtk3 clutter clutter-gtk clutter-gst gst-libav --noconfirm && STATUS="OK"
                            ;;
                        1) 
                            zenity --info --width 500\
                              --text="Unfortunately, it is not possible for me to work like this."
                            exit 0
                            ;;
                        -1)
                            zenity --info --width 500\
                              --text="Oops. This should not happen."
                            exit 0
                            ;;
                        esac
                elif [[ "$OS" == "Arch Linux" ]]; then
			        # Arch
                    zenity --question --width 500\
                            --text="Installation for Arch Linux initiated. Is tis correct?"
                    case $? in 
                        0)  
                            echo Renew Package Database
                            pacman -Sy
                            echo Install Arch Linux Dependencies       
			                pacman -S git base-devel ffmpeg youtube-dl cmake vala pkgconfig gtk3 clutter clutter-gtk clutter-gst gst-libav --noconfirm && STATUS="OK"
                            ;;
                        1) 
                            zenity --info --width 500\
                              --text="Unfortunately, it is not possible for me to work like this."
                            exit 0
                            ;;
                        -1)
                            zenity --info --width 500\
                              --text="Oops. This should not happen."
                            exit 0
                            ;;
                        esac
                elif [[ "$OS" == "Ubuntu" ]]; then
			        # Arch
                    zenity --question --width 500\
                            --text="Installation for Ubuntu initiated. Is tis correct?"
                    case $? in 
                        0)  
                            echo Renew Package Database
                            apt-get update
                            echo Install Ubuntu Dependencies       
                            apt-get install ffmpeg youtube-dl valac cmake pkg-config libgtk-3-dev libclutter-gtk-1.0-dev libclutter-gst-3.0-dev 
                            ;;
                        1) 
                            zenity --info --width 500\
                              --text="Unfortunately, it is not possible for me to work like this."
                            exit 0
                            ;;
                        -1)
                            zenity --info --width 500\
                              --text="Oops. This should not happen."
                            exit 0
                            ;;
                        esac
                else
			            echo "This OS is not Supported!"        
                fi


    if [ "$STATUS" == "OK" ]; then
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
    
    else
        echo "Sry but the Installer does not work for your system!"

    fi
fi

