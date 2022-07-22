#!/bin/bash


if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    zenity --info \
    --text="You use Wayland as a window manager. X11 is recommended for use."\
    --width=600\
    -- height=100
fi


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
VIDEO_LIST="$Cachedir/videos.txt"
VDownloaderSave="$Cachedir/vdownloader.txt"

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

if [ ! -f "$VDownloaderSave" ]; then
    echo "No Downloader selectet!"
    vdownloader=$(zenity --list --title "Animated Wallpaper Helper" --text "Which video downloader do you want to use?"\
    --column "Selection" --column "Typ" --radiolist  --column "Info"\
        TRUE yt-dlp "A fork of youtube-dl with more features and better performance" \
        FALSE youtube-dl "The Classic Downloader" \
    --width=800 --height=350)

    echo vdownloader > "$VDownloaderSave"

else

    read -a vdownloader < "$VDownloaderSave"
    echo "Video Downloader $vdownloader"

fi



# Go to the working folder
cd $Download

###############
# MAIN SCRIPT:
###############

INPUT=$(zenity --list --title "Animated Wallpaper Helper" --window-icon=/usr/local/share/awp/awp_wallpaper_icon.png --text "What do you want?"\
 --column "Selection" --column "Typ" --radiolist  FALSE "Existing" FALSE "New" TRUE "Start/Stop Animated Wallpapers" FALSE "Remove Wallpaper" FALSE "Enable/Disable Autostart" FALSE "Uninstall" FALSE About\
 --width=600 --height=350)


# Existing Wallpaper

if [ "$INPUT" == "Existing" ]
then

    read -a wallpaper_list_read < "$VIDEO_LIST"

    for (( i=0; i<${#wallpaper_list_read[*]}; ++i)); do
        data+=( "${wallpaper_list_read[$i]}")
    done

    wallpaper=$(zenity --list \
        --title="Select the name of the background set" \
        --height=350\
        --column="choose:"\
            "${data[@]}")

        case $? in 
            0) 
     
                echo $wallpaper > "$Cachedir/lastvideo.txt" 
                killall animated-wallpaper
                gsettings set org.gnome.desktop.background picture-uri "file://$Bilddir/$wallpaper.png"\
                && gsettings set org.gnome.desktop.background picture-uri-dark "file://$Bilddir/$wallpaper.png"\
                && cd $Download\
                && animated-wallpaper "$wallpaper".* & exit 0

                ;;
            1)
                exit 0
                ;;
            -1)
                zenity --info --width 500\
                    --text="Oops. This should not have happened...."
                exit 1
                ;;
        esac

fi

# Start Animated Wallpaper with the last image
if [ "$INPUT" == "Start/Stop Animated Wallpapers" ]
then


    if [ 'pidof animated-wallpaper' > 0 ]; then
    
        # Stop Animated Wallpaper
        killall animated-wallpaper && exit 0


    else

    # Start Animated Wallpaper
        killall animated-wallpaper

        read wallpaper < "$Cachedir/lastvideo.txt"


        if [ -f "$Cachedir/lastvideo.txt" ]; then
            
            echo "1" > "$StartStopStatus"

            gsettings set org.gnome.desktop.background picture-uri "file://$Bilddir/$wallpaper.png"\
            && gsettings set org.gnome.desktop.background picture-uri-dark "file://$Bilddir/$wallpaper.png"\
            && cd $Download && pwd\
            && animated-wallpaper "$wallpaper".* & exit 0

        else

            zenity --error \
            --text="No wallpaper has been used yet that can be called up."

            sh "/usr/local/share/awp/awp.sh"
        fi

    fi 


fi

# Download a new Animated Wallpaper
if [ "$INPUT" == "New" ]
then

    LINK=$(zenity --entry --title "Insert link" --text "Link to the video" --width=600)
    NAME=$(zenity --entry --title "What should the wallpaper be called?" --text "Without file suffix" --width=600)

   echo "Download $Link"
   $vdownloader --restrict-filenames "$LINK" -o "$NAME"-convert\
   | zenity --progress --title "Progress" --text "The download is running" --pulsate --width=200 --auto-close
   
   echo "Convert $Download/$NAME-convert to $Download/$NAME.mkv"
   ffmpeg -i "$Download/$NAME"-conver* -an "$Download/$NAME.mkv"\
   | zenity --progress --title "Progress" --text "Convert to mkv" --pulsate --width=200 --auto-close

   echo "remove $Download/$NAME"
   rm "$Download/$NAME-convert"
   
   echo "Generate Picture"
   ffmpeg -i "$NAME.mkv" -frames:v 1 "./Bild/$NAME.png"

   killall animated-wallpaper

    if [ -f "$VIDEO_LIST" ]; then
        echo "$VIDEO_LIST exists."
        read actual_list < "$VIDEO_LIST"
        echo $actual_list' '$NAME > "$VIDEO_LIST"

    else

        echo "create $VIDEO_LIST"
        echo $NAME > "$VIDEO_LIST"

    fi


    gsettings set org.gnome.desktop.background picture-uri "file://$Bilddir/$NAME.png"\
    && gsettings set org.gnome.desktop.background picture-uri-dark "file://$Bilddir/$NAME.png"\
    && animated-wallpaper "$NAME".* & exit 0


fi

# Remove Wallpaper
if [ "$INPUT" == "Remove Wallpaper" ]
then

    read -a wallpaper_list_read < "$VIDEO_LIST"

    for (( i=0; i<${#wallpaper_list_read[*]}; ++i)); do
        data+=( "${wallpaper_list_read[$i]}")
    done

    wallpaper_to_remove=$(zenity --list \
        --title="Select the name of the background set" \
        --height=350\
        --column="choose:"\
            "${data[@]}")

        case $? in 
            0) 
     
                echo "remove entry $wallpaper_to_remove in $VIDEO_LIST"
                
                for (( i=0; i<${#wallpaper_list_read[*]}; ++i)); do
                    
                    if [ "${wallpaper_list_read[$i]}" == "$wallpaper_to_remove" ]; then

                        echo "data hit $wallpaper_to_remove"

                    else 

                        newtxt="$newtxt ${wallpaper_list_read[$i]}"
                    fi

                done
                
                echo $newtxt > "$VIDEO_LIST"
                rm "$Bilddir/$wallpaper_to_remove.png"
                rm "$Download/$wallpaper_to_remove".*
                
                ;;
            1)
                ;;
            -1)
                zenity --info --width 500\
                    --text="Oops. This should not have happened...."
                exit 1
                ;;
        esac

fi

# Enable/Disable Autostart

if [ "$INPUT" == "Enable/Disable Autostart" ]
then

    if [ -f "$HOME/.config/autostart/awp-autostart.desktop" ]; then

        rm -f "$HOME/.config/autostart/awp-autostart.desktop"
        zenity --info \
            --text="Autostart disable"\
            --width=600\
            -- height=100

        sh "$Appdir/awp.sh"
    
    else
        mkdir -p "$HOME/.config/autostart/"
        cp "$Appdir/awp-autostart.desktop" "$HOME/.config/autostart/" 
        
        zenity --info \
            --text="Autostart enabled"\
            --width=600\
            -- height=100

        sh "$Appdir/awp.sh"

    fi         
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
