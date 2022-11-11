#!/bin/bash

# List of Supported Distros
os_array=('Fedora Linux' 'Manjaro Linux' 'Arch Linux' 'Ubuntu' 'Pop!_OS')

# If user == root, then stop the script

if [ $(whoami) == 'root' ]; then
    echo "Please run as regular user!"
    exit 1
fi

# Check the Name of a User
ORIGIN_USER=$(whoami)

# Ask for sudo password

echo "Asking for sudo password"
PASS=`zenity --password --title "Install Animated Wallpaper"`

# Checking if user has cancelled the password prompt
case $? in 
0) 
    ;;
1) 
    zenity --info --width=500\
        --text="Unfortunately, it is not possible for me to work like this."
    exit 0
    ;;
-1)
    echo "Exiting"
    exit 1
    ;;
esac

# Checking if provided password isn't empty
if [ -z "$PASS" ]; then
    zenity --question --width=500\
        --text="Provided empty sudo password. Continue?"
    
    case $? in 
    0) 
        ;;
    1) 
        zenity --info --width 500\
            --text="Unfortunately, it is not possible for me to work like this."
        exit 0
        ;;
    -1)
        zenity --info --width 500\
            --text="Oops. This should not have happened...."
        exit 1
        ;;
    esac
fi

# Checking if provided password is correct
echo "$PASS" | sudo -S -k -v
case $? in 
0) 
    echo "Verified sudo privileges."
    ;;
1)
    zenity --info --width 500\
        --text="Cannot run with sufficient privileges."
    exit 0
    ;;
-1)
    zenity --info --width 500\
        --text="Oops. This should not have happened...."
    exit 1
    ;;
esac


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

# Check if OS is Supported in os_array

os_check="0"

for i in "${os_array[@]}"; do
    if [ "$OS" == "$i" ]; then
        os_check="1"
        echo "$os_check"
    fi
done

vDownloader=$(zenity --list --title "Animated Wallpaper Helper" --text "Which video downloader do you want to use?"\
 --column "Selection" --column "Typ" --radiolist  --column "Info"\
   TRUE yt-dlp "A fork of youtube-dl with more features and better performance" \
   FALSE youtube-dl "The Classic Downloader" \
 --width=800 --height=350)


if [ "$os_check" == "0" ]; then

    zenity --question \
        --text="Your Linux system is not supported by the automatic script. The following is a list of supported distributions. If your distro is based on one, you can try to use the installer from it. \n\n Would you like to try?" \
        --width=600\
        -- height=100

    case $? in 
    0) 
        ;;
    1) 
        echo "Aborted"
        exit 0
        ;;
    -1)
        zenity --info --width 500\
            --text="Oops. This should not have happened...."
        exit 1
        ;;
    esac

    OS=$(zenity --list \
        --title="Select the name of the background set" \
        --column="choose:"\
        --height=400\
        "${os_array[@]}")

    case $? in 
    0) 
        os_check="1"
        ;;
    1)
        echo "Aborted"
        exit 0
        ;;
    -1)
        zenity --info --width 500\
            --text="Oops. This should not have happened...."
        exit 1
        ;;
    esac
fi


# Install Dependencies
if [ "$os_check" == "1" ]; then
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
            echo "$PASS" | sudo -S dnf install -y cmake gcc-c++ vala pkgconfig gtk3-devel clutter-devel clutter-gtk-devel clutter-gst3-devel $vDownloader ffmpeg && STATUS="OK"
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
            echo "$PASS" | sudo -S pacman -S base-devel ffmpeg $vDownloader cmake vala pkgconfig gtk3 clutter clutter-gtk clutter-gst gst-libav --noconfirm && STATUS="OK"
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
            echo "$PASS" | sudo -S pacman -S git base-devel ffmpeg $vDownloader cmake vala pkgconfig gtk3 clutter clutter-gtk clutter-gst gst-libav --noconfirm && STATUS="OK"
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
            echo "$PASS" | sudo -S apt install git ffmpeg $vDownloader valac cmake pkg-config libgtk-3-dev libclutter-gtk-1.0-dev libclutter-gst-3.0-dev build-essential --yes && STATUS="OK" 
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

    elif [[ "$OS" == "Pop!_OS" ]]; then
        # Ubuntu
        zenity --question --width 500\
        --text="Pop!_OS Detected. Is this correct?"
        
        case $? in 
        0)  
            echo Renewing Package Database
            echo "$PASS" | sudo -S apt-get update
            echo Installing Pop!_OS Dependencies       
            echo "$PASS" | sudo -S apt install git ffmpeg $vDownloader valac cmake pkg-config libgtk-3-dev libclutter-gtk-1.0-dev libclutter-gst-3.0-dev build-essential --yes && STATUS="OK" 
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
fi

if [ "$STATUS" == "OK" ]; then
    # Clone and Install animated-wallpaper
    echo 'Cloning animated-wallpaper from github. (https://github.com/Ninlives/animated-wallpaper)'

    git clone https://github.com/Ninlives/animated-wallpaper
    cd animated-wallpaper
    cmake . && make && echo "$PASS" | sudo -S make install
    cd ..
    rm -rf animated-wallpaper

    # Install animated_wallpaper_helper

    echo "$PASS" | sudo -S cp -r awp /usr/local/share/
    echo "$PASS" | sudo -S cp awp.desktop /usr/share/applications/
    echo "$PASS" | sudo -S chmod +x /usr/local/share/awp/awp.sh
    echo "$PASS" | sudo -S chmod +x /usr/local/share/awp/awp-autostart.sh


    # Create Cachedir
    Cachedir="$HOME/.cache/Animated_Wallpapers"
    mkdir -p "$Cachedir"

    # Save Downloader
    VDownloaderSave="$Cachedir/vdownloader.txt"
    echo $vDownloader > $VDownloaderSave


    echo "Animated Wallpapers was installed successfully."
    
    zenity --question --width 500\
        --text="Animated Wallpapers was installed successfully. Do you want to start the script now?"

    case $? in 
    0) 
        echo Start Animated Wallpaper
        sudo -u $ORIGIN_USER sh "/usr/local/share/awp/awp.sh" & exit 0
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

    zenity --error \
    --text="Sorry but the Installer does not work on your system!"
fi
