#!/bin/bash

# Seçenekler
options="Lock\nLogout\nSuspend\nReboot\n<span color='#cc4444'>Shutdown</span>"

# Rofi ile göster
chosen="$(echo -e "$options" | rofi -dmenu -p "Power" -markup-rows -theme-str 'window {width: 200px;}')"

# Pango tag'lerini temizle
chosen=$(echo "$chosen" | sed 's/<[^>]*>//g')

case $chosen in
    Lock)
        swaylock ;;
    Logout)
        hyprctl dispatch exit ;;
    Suspend)
        systemctl suspend ;;
    Reboot)
        systemctl reboot ;;
    Shutdown)
        systemctl poweroff ;;
esac
