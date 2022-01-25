#!/bin/bash

Download="$HOME/Animated_Wallpapers"
Bilddir="$HOME/Animated_Wallpapers/Bild"
Cachedir="$HOME/.cache/Animated_Wallpapers"

killall animated-wallpaper

read lastvid < $Cachedir/lastvideo.txt
read lastpic < $Cachedir/lastpicture.txt

gsettings set org.gnome.desktop.background picture-uri "file://$lastpic"
animated-wallpaper $lastvid & exit 0
