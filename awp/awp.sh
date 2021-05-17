#!/bin/bash
Download="$HOME/Animated_Wallpapers"
Bilddir="$HOME/Animated_Wallpapers/Bild"

mkdir -p $Bilddir
cd $Download

INPUT=$(zenity --list --title "Animated Wallpaper Helper" --text "What do you want?"\
 --column "Selection" --column "Typ" --radiolist  TRUE "Existing" FALSE "New" FALSE "Start Animated Wallpapers" FALSE "Stop Animated Wallpapers"\
 --width=600 --height=250)


#Existierendes Wallpaper

if [ "$INPUT" == "Existing" ]
then

Video=$(zenity --file-selection --title "Choose the live wallpaper" --filename='$Download' --width=600 --file-filter=""*.mkv" "*.webm"")

echo $Video > lastvideo.txt 
cd Bild
Bild=$(zenity --file-selection --title "Select the corresponding still image" --filename='$Bilddir' --width=600 --file-filter=""*.png" "*.jpg" "*.jpeg"") 
cd ..
echo $Bild > lastpicture.txt

killall animated-wallpaper

gsettings set org.gnome.desktop.background picture-uri file://$Bild\
&& animated-wallpaper $Video & exit 0

fi

if [ "$INPUT" == "Start Animated Wallpapers" ]
then

killall animated-wallpaper

read lastvid < $HOME/Animated_Wallpapers/lastvideo.txt
read lastpic < $HOME/Animated_Wallpapers/lastpicture.txt

gsettings set org.gnome.desktop.background picture-uri file://$lastpic\
&& animated-wallpaper $lastvid & exit 0

fi

if [ "$INPUT" == "Stop Animated Wallpapers" ]
then

killall animated-wallpaper && exit 0

fi

if [ "$INPUT" == "New" ]
then

LINK=$(zenity --entry --title "Insert link" --text "Link to the video" --width=600)
NAME=$(zenity --entry --title "What should the wallpaper be called?" --text "Without file suffix" --width=600)

youtube-dl --restrict-filenames $LINK -o $NAME\
 | zenity --progress --title "Progress" --text "The download is running" --pulsate --width=200 --auto-close
ffmpeg -i $NAME.* -frames:v 1 ./Bild/$NAME.png

killall animated-wallpaper

gsettings set org.gnome.desktop.background picture-uri file://$Bilddir/$NAME.png\
 && animated-wallpaper $NAME.*  & exit 0



fi

