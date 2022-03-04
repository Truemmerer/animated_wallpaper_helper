#!/bin/bash

# Find "Videos" folder of a user
Userdirs="$HOME/.config/user-dirs.dirs" 
if [ -f "$Userdirs" ]; then
       source "$HOME/.config/user-dirs.dirs"
else
    XDG_VIDEOS_DIR="$HOME/Videos"   
fi 

Download="$XDG_VIDEOS_DIR/Animated_Wallpapers"
Bilddir="$Download/Bild"
Cachedir="$HOME/.cache/Animated_Wallpapers"
Appdir="/usr/local/share/awp"
FILEABOUT="$Appdir/about.txt"

# Save the Picture Folder
echo $Download > "$Cachedir/folder.txt" 

# Create (recrusiv) necessary folders if they do not already exist. 
mkdir -p "$Cachedir"
mkdir -p "$Bilddir"

# Should already have used version 0.5 or earlier: 
Olddir="$HOME/Animated_Wallpapers" 
if [ -d "$Olddir" ]; then 
    cp -r $Olddir/* "$Download"
    rm -rf "$Olddir"
    zenity --info \
    --text="The animated backgrounds have been moved to your Video folder: $Download"
fi

# Go to the working folder
cd $Download

###############
# MAIN SCRIPT:
###############

INPUT=$(zenity --list --title "Animated Wallpaper Helper" --window-icon=/usr/local/share/awp/awp_wallpaper_icon.png --text "What do you want?"\
 --column "Selection" --column "Typ" --radiolist  FALSE "Existing" FALSE "New" TRUE "Start Animated Wallpapers" FALSE "Stop Animated Wallpapers" FALSE "Enable Autostart" FALSE "Disable Autostart" FALSE "Uninstall" FALSE About\
 --width=600 --height=295)


# Existing Wallpaper

if [ "$INPUT" == "Existing" ]
then

Video=$(zenity --file-selection --title "Choose the live wallpaper" --filename='$Download' --width=600 --file-filter=""*.mkv" "*.webm"")

case $? in 

0) 
    echo "select Video"
    ;;
1) 
    echo "Aborted"
    exit 0
    ;;
-1) 
    zenity --info --width 500\
        --text="Oops. This should not happen."
    exit 0
    ;;
    
esac

    cd "$Bilddir"
    Bild=$(zenity --file-selection --title "Select the corresponding still image" --filename='$Bilddir' --width=600 --file-filter=""*.png" "*.jpg" "*.jpeg"") 

    case $? in 

    0)
        echo "select Picture"
        ;;

    1) 
        echo "Aborted"
        exit 0
        ;;
    -1) 
        zenity --info --width 500\
            --text="Oops. This should not happen."
        exit 0
        ;;    

    esac

cd ..
echo $Bild > "$Cachedir/lastpicture.txt"
echo $Video > "$Cachedir/lastvideo.txt" 
killall animated-wallpaper

gsettings set org.gnome.desktop.background picture-uri "file://$Bild"\
&& animated-wallpaper "$Video" & exit 0

fi

# Start Animated Wallpaper with the last image
if [ "$INPUT" == "Start Animated Wallpapers" ]
then

# Check if there was a previous wallpaper and if yes load this

    killall animated-wallpaper

    read lastpic < "$Cachedir/lastpicture.txt"
    read lastvid < "$Cachedir/lastvideo.txt"


    if [ -f "$lastpic" ]; then
        if [ -f "$lastvid" ]; then
	    gsettings set org.gnome.desktop.background picture-uri "file://$lastpic"\
	    && animated-wallpaper "$lastvid" & exit 0
        else
            zenity --error \
            --text="No wallpaper has been used yet that can be called up."

            sh "/usr/local/share/awp/awp.sh"
        fi 
    else

        zenity --error \
        --text="No wallpaper has been used yet that can be called up."

        sh "/usr/local/share/awp/awp.sh"
    fi
fi

# Stop Animated Wallpaper
if [ "$INPUT" == "Stop Animated Wallpapers" ]
then

    killall animated-wallpaper && exit 0

fi

# Download a new Animated Wallpaper
if [ "$INPUT" == "New" ]
then

    LINK=$(zenity --entry --title "Insert link" --text "Link to the video" --width=600)
    NAME=$(zenity --entry --title "What should the wallpaper be called?" --text "Without file suffix" --width=600)


   youtube-dl --restrict-filenames "$LINK" -o "$NAME"\
   | zenity --progress --title "Progress" --text "The download is running" --pulsate --width=200 --auto-close
   ffmpeg -i "$NAME".* -frames:v 1 "./Bild/$NAME.png"

   killall animated-wallpaper

  gsettings set org.gnome.desktop.background picture-uri "file://$Bilddir/$NAME.png"\
  && animated-wallpaper "$NAME".*  & exit 0


fi

# Enable Autostart

if [ "$INPUT" == "Enable Autostart" ]
then

    cp "$Appdir/awp-autostart.desktop" "$HOME/.config/autostart/" 
    sh "$Appdir/awp.sh"
        
fi

# Disable Autostart

if [ "$INPUT" == "Disable Autostart" ]
then

  rm -f "$HOME/.config/autostart/awp-autostart.desktop"
  sh "$Appdir/awp.sh"

fi

# Uninstall

if [ "$INPUT" == "Uninstall" ]
then
    sh "$Appdir/uninstall.sh"
fi

# About Animated Wallpaper and Animated Wallpaper Helper
if [ "$INPUT" == "About" ]
then
  
zenity --text-info \
       --title="About" \
       --filename=$FILEABOUT \
       --width=600 --height=500 \

        sh "$Appdir/awp.sh"
fi
