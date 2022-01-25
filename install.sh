#!/bin/bash

if [ $(whoami) == 'root' ]; then
    echo "Please run as regular user!"
    exit 1
fi

ORIGIN_USER=$(whoami)

echo "Asking for sudo password"
PASS=`zenity --password --title "Install Animated Wallpaper"`

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
                            echo "$PASS" | sudo -S dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm 
                            echo Installing dev tools and dependencies
                            echo "$PASS" | sudo -S dnf install -y cmake gcc-c++ vala pkgconfig gtk3-devel clutter-devel clutter-gtk-devel clutter-gst3-devel youtube-dl ffmpeg && STATUS="OK"
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
                            echo "$PASS" | sudo -S pacman -Sy
                            echo Installing Manjaro Dependencies  
			                echo "$PASS" | sudo -S pacman -S base-devel ffmpeg youtube-dl cmake vala pkgconfig gtk3 clutter clutter-gtk clutter-gst gst-libav --noconfirm && STATUS="OK"
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
                            echo "$PASS" | sudo -S pacman -Sy
                            echo Installing Arch Linux Dependencies       
			                echo "$PASS" | sudo -S pacman -S git base-devel ffmpeg youtube-dl cmake vala pkgconfig gtk3 clutter clutter-gtk clutter-gst gst-libav --noconfirm && STATUS="OK"
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
                            echo "$PASS" | sudo -S apt-get update
                            echo Installing Ubuntu Dependencies       
                            echo "$PASS" | sudo -S apt install git ffmpeg youtube-dl valac cmake pkg-config libgtk-3-dev libclutter-gtk-1.0-dev libclutter-gst-3.0-dev build-essential --yes && STATUS="OK" 
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
        cmake . && make && echo "$PASS" | sudo -S make install
        cd ..
        rm -rf animated-wallpaper

        # Clone and Install animated_wallpaper_helper

        echo "$PASS" | sudo -S cp -r awp /usr/local/share/
        echo "$PASS" | sudo -S cp awp.desktop /usr/share/applications/
        echo "$PASS" | sudo -S chmod +x /usr/local/share/awp/awp.sh
        echo "$PASS" | sudo -S chmod +x /usr/local/share/awp/awp-autostart.sh

        zenity --question --width 500\
            --text="Animated Wallpapers was installed successfully. Do you want to start the script now?"

        case $? in 
        0) 
            echo Start Animated Wallpaper
            sudo -u $ORIGIN_USER sh "/usr/local/share/awp/awp.sh"
            ;;
        1) 
            exit 0
            echo Close
            ;;
        -1)
            zenity --info --width 500\
            --text="Oops. This should not have happened...."
            exit 0
            ;;
        esac
    
else
    echo "Sorry but the Installer does not work on your system!"

fi


