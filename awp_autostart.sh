#!/bin/bash

Download="$HOME/Animated_Wallpapers"
Bilddir="$HOME/Animated_Wallpapers/Bild"

killall animated-wallpaper

read lastvid < $HOME/Animated_Wallpapers/lastvideo.txt
read lastpic < $HOME/Animated_Wallpapers/lastpicture.txt

gsettings set org.gnome.desktop.background picture-uri file://$lastpic
animated-wallpaper $lastvid & exit 0
