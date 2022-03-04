#!/bin/bash

Cachedir="$HOME/.cache/Animated_Wallpapers"
read PictureFolder < "$Cachedir/folder.txt"

zenity --question --width 500\
    --text="Did you want to remove Animated Wallpaper?"

    case $? in 
        0) 

            PASS=`zenity --password --title "Uninstall Animated Wallpaper"`

            case $? in
            0)
                killall animated-wallpaper
	 	        echo Remove Animated Wallpaper Helper
                echo rm -rf $Cachedir
                rm -rf "$Cachedir"
                echo rm -rf "/usr/local/share/awp"
                echo "$PASS" | sudo -S rm -rf "/usr/local/share/awp"
                echo rm -f "/usr/share/applications/awp.desktop"
                echo "$PASS" | sudo -S rm -f "/usr/share/applications/awp.desktop"
                echo rm -f "$HOME/.config/autostart/awp-autostart.desktop"
                echo "$PASS" | sudo -S rm -f "$HOME/.config/autostart/awp-autostart.desktop"

                echo Remove Animated Wallpaper
                echo rm -f "/usr/local/bin/animated-wallpaper"
                echo "$PASS" | sudo -S rm -f "/usr/local/bin/animated-wallpaper"
       
                ;;
            1)
                echo "Stop login."
                exit 0
                ;;
            -1)
                echo "An unexpected error has occurred."
                exit 0
                ;;
            esac       
            ;;
        1) 
            exit 0
            ;;
        -1)
            zenity --info --width 500\
            --text="Oops. This should not have happened...."
            exit 0
            ;;
    esac

zenity --question --width 500\
    --text="Animated wallpaper has been removed. Do you also want to delete the animated wallpapers?"

    case $? in 
        0) 
            echo Delete animated wallpapers
            rm -rf "$PictureFolder"
            ;;
        1) 
            ;;
        -1)
            zenity --info --width 500\
            --text="Oops. This should not have happened...."
            exit 0
            ;;
    esac