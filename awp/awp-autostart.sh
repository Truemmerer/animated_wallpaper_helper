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
VIDEO_LIST="$Cachedir/videos.txt"


if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    zenity --notification\
        --window-icon="info" \
        --text="You use Wayland as a window manager. X11 is recommended for use."

fi

killall animated-wallpaper

read lastvid < "$VIDEO_LIST"

gsettings set org.gnome.desktop.background picture-uri "file://$Bilddir/$lastvid.png"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$Bilddir/$lastvid.png"
cd $Download && pwd\
&& animated-wallpaper "$lastvid".* & exit 0
