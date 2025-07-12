#!/bin/bash

# Universal Rofi Launcher - Direct Command Style
# Kısayollar: .p power | .w wifi | .b bluetooth | .e emoji | .k keybinds | .c calc | :search | /file

THEME="squared-material-red"

# Webhook'a mesaj gönder
send_to_webhook() {
    MESSAGE="$1"
    
    if [ -n "$MESSAGE" ]; then
        # curl ile POST request gönder (sadece text olarak)
        RESPONSE=$(curl -s -X POST "http://localhost:5678/webhook/noteaiinput" \
                   -H "Content-Type: text/plain" \
                   -d "$MESSAGE" 2>&1)
        
        if [ $? -eq 0 ]; then
            notify-send "Note AI" "Message sent ✓" -i emblem-default -t 1500
        else
            notify-send "Note AI" "Failed to send message" -i dialog-error -t 2000
        fi
    fi
}

# Ana fonksiyon
main() {
    # Eğer argüman varsa direkt işle
    if [ -n "$1" ]; then
        INPUT="$1"
    else
        # Argüman yoksa rofi dmenu ile input al
        INPUT=$(echo "" | rofi -dmenu -p "" -theme ~/.config/rofi/themes/$THEME.rasi \
                -mesg '. → shortcuts | .p power | .w wifi | .e emoji | .s system | Type for apps')
        
        # Boş input'ta app launcher aç
        if [ -z "$INPUT" ]; then
            rofi -show drun -theme ~/.config/rofi/themes/$THEME.rasi
            exit 0
        fi
    fi
    
    # Kısayol komutları kontrol et (nokta ile başlayanlar)
    case "$INPUT" in
        # Sadece . yazılmışsa kısayol listesi göster
        .)
            show_shortcuts_list
            ;;
            
        # Note AI webhook - . ve boşluk ile başlıyorsa
        .\ *)
            MESSAGE="${INPUT#. }"
            send_to_webhook "$MESSAGE"
            ;;
            
        # Power menu kısayolu
        .p|power)
            show_power_menu
            ;;
            
        # WiFi kısayolu
        .w|wifi)
            show_wifi_menu
            ;;
            
        # Bluetooth kısayolu
        .b|blue)
            show_bluetooth_menu
            ;;
            
        # System info
        .s)
            show_system_info
            ;;
            
        # Updates
        .u)
            check_updates
            ;;
            
        # Tasks/Processes
        .t)
            show_tasks
            ;;
            
        # Screen recording
        .rec)
            toggle_screen_recording
            ;;
            
        # Translate
        .tr\ *|.tr)
            TEXT="${INPUT#.tr }"
            [ -z "$TEXT" ] && TEXT="${INPUT#.tr}"
            translate_text "$TEXT"
            ;;
            
        # Password manager (Bitwarden)
        .pass)
            bitwarden_menu
            ;;
            
        # Timer
        .timer\ *)
            TIME="${INPUT#.timer }"
            set_timer "$TIME"
            ;;
            
        # Disk usage
        .disk)
            show_disk_usage
            ;;
            
        # Color picker
        .color)
            pick_color
            ;;
            
        # Monitor
        .m|mon)
            show_monitor_menu
            ;;
            
        # Window switcher
        .win|win)
            rofi -show window -theme ~/.config/rofi/themes/$THEME.rasi
            ;;
            
        # Emoji kısayolu ve search
        .e)
            show_emoji_search ""
            ;;
        .e\ *|emoji\ *)
            SEARCH="${INPUT#.e }"
            [ -z "$SEARCH" ] && SEARCH="${INPUT#emoji }"
            show_emoji_search "$SEARCH"
            ;;
            
        # Keybind kısayolu ve search
        .k)
            show_keybind_search ""
            ;;
        .k\ *|key\ *)
            SEARCH="${INPUT#.k }"
            [ -z "$SEARCH" ] && SEARCH="${INPUT#key }"
            show_keybind_search "$SEARCH"
            ;;
            
        # Calculator kısayolu
        .c)
            # Boş calculator input
            CALC_INPUT=$(echo "" | rofi -dmenu -p "🧮 Calculator" -theme ~/.config/rofi/themes/$THEME.rasi)
            [ -n "$CALC_INPUT" ] && calculate "$CALC_INPUT"
            ;;
            
        # Web search
        :*)
            QUERY="${INPUT#:}"
            [ -n "$QUERY" ] && xdg-open "https://www.google.com/search?q=$(echo "$QUERY" | sed 's/ /+/g')"
            ;;
            
        # File search
        /*)
            PATH_SEARCH="${INPUT#/}"
            if [ -z "$PATH_SEARCH" ]; then
                # Boş ise home dizininden başla
                FILE=$(find ~ -maxdepth 3 -type f -o -type d 2>/dev/null | 
                       rofi -dmenu -p "📁 Browse" -theme ~/.config/rofi/themes/$THEME.rasi)
            else
                # Arama yap
                FILE=$(find ~ -iname "*$PATH_SEARCH*" 2>/dev/null | head -30 | 
                       rofi -dmenu -p "📁 Results" -theme ~/.config/rofi/themes/$THEME.rasi)
            fi
            
            if [ -n "$FILE" ]; then
                if [ -d "$FILE" ]; then
                    # Klasör ise terminal aç
                    kitty --directory="$FILE" &
                elif [ -f "$FILE" ]; then
                    # Dosya ise nano ile aç
                    kitty --directory="$(dirname "$FILE")" nano "$(basename "$FILE")" &
                fi
            fi
            ;;
            
        # Sayı ile başlıyorsa hesap makinesi
        [0-9]*|[\(\-]*)
            if [[ "$INPUT" =~ ^[0-9+\-*/().,\ ]+$ ]]; then
                calculate "$INPUT"
            else
                # Sayı içeriyor ama app adı da olabilir
                rofi -show drun -filter "$INPUT" -theme ~/.config/rofi/themes/$THEME.rasi
            fi
            ;;
            
        # Default - app search
        *)
            # App launcher'ı search modunda aç
            rofi -show drun -filter "$INPUT" -theme ~/.config/rofi/themes/$THEME.rasi
            ;;
    esac
}

# Show shortcuts list
show_shortcuts_list() {
    SHORTCUTS=".p → ⚡ Power Menu (lock, logout, shutdown...)
.w → 󰖩 WiFi Networks
.b → 󰂯 Bluetooth Devices
.m → 󰍹 Monitor Settings
.e → 😀 Emoji Search (.e smile)
.k → ⌨️ Keybinds Search (.k move)
.c → 🧮 Calculator
.s → 󰍛 System Info (CPU, RAM, Disk...)
.u → 󰏗 Check Updates (pacman/AUR)
.t → 󰓇 Tasks/Processes (click to kill)
.rec → 📹 Screen Recording (OBS)
.tr → 󰊿 Translate (.tr hello)
.pass → 󰌋 Bitwarden Password Manager
.timer → ⏲️ Set Timer (.timer 5m)
.disk → 󰋊 Disk Usage Details
.color → 󰏘 Color Picker
.win → 🪟 Window Switcher
. MSG → 📝 Send to Note AI
:query → 🔍 Web Search
/path → 📁 File Search
5+5 → 🧮 Quick Calculate
app → 📱 Launch Application"

    # Seçim yap
    SELECTED=$(echo "$SHORTCUTS" | rofi -dmenu -p "📋 Shortcuts" -theme ~/.config/rofi/themes/$THEME.rasi | awk '{print $1}')
    
    # Seçilen komutu çalıştır
    if [ -n "$SELECTED" ]; then
        # Kısayolu temizle ve tekrar çalıştır
        CLEAN_CMD=$(echo "$SELECTED" | sed 's/→.*//' | xargs)
        main "$CLEAN_CMD"
    fi
}

# Power Menu
show_power_menu() {
    OPTIONS=" Lock\n󰍃 Logout\n󰤄 Suspend\n󰜉 Reboot\n󰐥 Shutdown"
    CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "⚡ Power" -theme ~/.config/rofi/themes/$THEME.rasi)
    
    case "$CHOICE" in
        " Lock") swaylock ;;
        "󰍃 Logout") hyprctl dispatch exit ;;
        "󰤄 Suspend") systemctl suspend ;;
        "󰜉 Reboot") systemctl reboot ;;
        "󰐥 Shutdown") systemctl poweroff ;;
    esac
}

# WiFi Menu
show_wifi_menu() {
    notify-send "WiFi" "Scanning networks..." -t 1000
    
    if command -v nmcli &> /dev/null; then
        # WiFi durumu
        WIFI_STATUS=$(nmcli radio wifi)
        
        # Header ile birlikte göster
        echo -e "󰖩 Toggle WiFi (Current: $WIFI_STATUS)\n󰖩 Rescan Networks\n───────────────────" > /tmp/wifi_list
        
        # Ağları listele
        nmcli -t -f ACTIVE,SSID,SIGNAL,SECURITY dev wifi | 
        awk -F':' '{
            active = ($1 == "yes") ? "●" : " ";
            printf "%s %-25s %3s%% %s\n", active, $2, $3, $4
        }' | sort -k3 -nr >> /tmp/wifi_list
        
        CHOICE=$(cat /tmp/wifi_list | rofi -dmenu -p "󰖩 WiFi" -theme ~/.config/rofi/themes/$THEME.rasi)
        rm -f /tmp/wifi_list
        
        case "$CHOICE" in
            "󰖩 Toggle WiFi"*)
                if [ "$WIFI_STATUS" = "enabled" ]; then
                    nmcli radio wifi off
                    notify-send "WiFi" "Disabled" -i network-wireless-disabled
                else
                    nmcli radio wifi on
                    notify-send "WiFi" "Enabled" -i network-wireless
                fi
                ;;
            "󰖩 Rescan Networks")
                nmcli dev wifi rescan
                main "wifi"  # Tekrar göster
                ;;
            *)
                if [ -n "$CHOICE" ] && [[ ! "$CHOICE" =~ ^─+$ ]]; then
                    SSID=$(echo "$CHOICE" | awk '{print $2}')
                    notify-send "WiFi" "Connecting to $SSID..." -t 2000
                    nmcli dev wifi connect "$SSID" && \
                        notify-send "WiFi" "Connected to $SSID" -i network-wireless || \
                        notify-send "WiFi" "Failed to connect" -i dialog-error
                fi
                ;;
        esac
    else
        notify-send "Error" "NetworkManager not found" -i dialog-error
    fi
}

# Bluetooth Menu
show_bluetooth_menu() {
    if command -v bluetoothctl &> /dev/null; then
        BT_POWER=$(bluetoothctl show | grep "Powered" | awk '{print $2}')
        
        echo -e "󰂯 Toggle Bluetooth (Current: $BT_POWER)\n Scan for Devices\n───────────────────" > /tmp/bt_list
        
        # Paired/Connected devices
        bluetoothctl devices | while read -r line; do
            MAC=$(echo "$line" | awk '{print $2}')
            NAME=$(echo "$line" | cut -d' ' -f3-)
            
            # Bağlantı durumunu kontrol et
            if bluetoothctl info "$MAC" | grep -q "Connected: yes"; then
                echo "● $NAME [$MAC]"
            else
                echo "  $NAME [$MAC]"
            fi
        done >> /tmp/bt_list
        
        CHOICE=$(cat /tmp/bt_list | rofi -dmenu -p "󰂯 Bluetooth" -theme ~/.config/rofi/themes/$THEME.rasi)
        rm -f /tmp/bt_list
        
        case "$CHOICE" in
            "󰂯 Toggle Bluetooth"*)
                if [ "$BT_POWER" = "yes" ]; then
                    bluetoothctl power off
                    notify-send "Bluetooth" "Disabled" -i bluetooth-disabled
                else
                    bluetoothctl power on
                    notify-send "Bluetooth" "Enabled" -i bluetooth-active
                fi
                ;;
            " Scan for Devices")
                notify-send "Bluetooth" "Scanning..." -t 3000
                bluetoothctl scan on &
                SCAN_PID=$!
                sleep 5
                kill $SCAN_PID 2>/dev/null
                main "blue"
                ;;
            *)
                if [[ "$CHOICE" =~ \[.*\] ]]; then
                    MAC=$(echo "$CHOICE" | grep -o '\[.*\]' | tr -d '[]')
                    NAME=$(echo "$CHOICE" | sed 's/ \[.*\]$//')
                    
                    if [[ "$CHOICE" =~ ^● ]]; then
                        # Bağlıysa, bağlantıyı kes
                        bluetoothctl disconnect "$MAC"
                        notify-send "Bluetooth" "Disconnected from $NAME" -i bluetooth-disabled
                    else
                        # Bağlı değilse, bağlan
                        notify-send "Bluetooth" "Connecting to $NAME..." -t 2000
                        bluetoothctl connect "$MAC" && \
                            notify-send "Bluetooth" "Connected to $NAME" -i bluetooth-active || \
                            notify-send "Bluetooth" "Failed to connect" -i dialog-error
                    fi
                fi
                ;;
        esac
    else
        notify-send "Error" "Bluetooth not available" -i dialog-error
    fi
}

# Monitor Settings  
show_monitor_menu() {
    OPTIONS="󰍹 Display Settings (wdisplays)\n󱎓 Mirror Displays\n󰶐 Extend Left\n󰶏 Extend Right\n Only Laptop\n Only External"
    CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "󰍹 Monitors" -theme ~/.config/rofi/themes/$THEME.rasi)
    
    case "$CHOICE" in
        "󰍹 Display Settings"*) 
            if command -v wdisplays &> /dev/null; then
                wdisplays &
            else
                notify-send "Error" "wdisplays not installed" -i dialog-error
            fi
            ;;
        "󱎓 Mirror Displays")
            hyprctl keyword monitor ",preferred,auto,1,mirror,eDP-1"
            ;;
        "󰶐 Extend Left")
            hyprctl keyword monitor "HDMI-A-1,preferred,0x0,1"
            hyprctl keyword monitor "eDP-1,preferred,1920x0,1"
            ;;
        "󰶏 Extend Right")
            hyprctl keyword monitor "eDP-1,preferred,0x0,1"
            hyprctl keyword monitor "HDMI-A-1,preferred,1920x0,1"
            ;;
        " Only Laptop")
            hyprctl keyword monitor "eDP-1,preferred,0x0,1"
            hyprctl keyword monitor "HDMI-A-1,disable"
            ;;
        " Only External")
            hyprctl keyword monitor "HDMI-A-1,preferred,0x0,1"
            hyprctl keyword monitor "eDP-1,disable"
            ;;
    esac
}

# Emoji Search - Genişletilmiş liste
show_emoji_search() {
    SEARCH="${1,,}"  # Küçük harfe çevir
    
    # Geniş emoji veritabanı
    EMOJI_DB="smile:😊 😄 😃 😀 😁 😆 😂 🤣 😇 🙂 🙃 😉 😌 😍 🥰 😘
happy:😊 😄 😃 😀 😁 😆 🥳 🤗 😺 😸 🎉 🎊
sad:😢 😭 😞 😔 😟 😕 😣 😖 😫 😩 🥺 😿
angry:😠 😡 🤬 😤 👿 💢 😾 🗯️
love:❤️ 💕 💖 💗 💓 💝 💘 💞 💟 ❣️ 🥰 😍 😘 💑 💏
heart:❤️ 🧡 💛 💚 💙 💜 🖤 🤍 🤎 💔 ❤️‍🔥 ❤️‍🩹
fire:🔥 🎆 🎇 ✨ 💥 🌋 🧨
star:⭐ ✨ 💫 🌟 🌠 ✴️ ⚡ 🌌
sun:☀️ 🌞 🌝 🌛 🌜 🌚 🌕 🌖 🌗 🌘 🌑 🌒 🌓 🌔
hand:👍 👎 👌 ✌️ 🤞 🤟 🤘 🤙 👈 👉 👆 👇 ☝️ ✋ 🤚 🖐️ 🖖 👋 🤝 👏 🙌 👐 🤲 🙏 ✊ 👊 🤛 🤜
face:😀 😃 😄 😁 😆 😅 🤣 😂 🙂 🙃 😉 😊 😇 🥰 😍 🤩 😘 😗 😚 😙 😋 😛 😜 🤪 😝 🤑 🤗 🤭 🤫 🤔 🤐 🤨 😐 😑 😶 😏 😒 🙄 😬 🤥 😌 😔 😪 🤤 😴 😷 🤒 🤕 🤢 🤮 🤧 😵 🤯 🤠 😎 🤓 🧐
food:🍕 🍔 🍟 🌭 🥪 🌮 🍗 🍖 🥓 🍳 🥘 🍲 🥗 🍿 🧂 🥫 🍱 🍘 🍙 🍚 🍛 🍜 🍝 🍠 🍢 🍣 🍤 🍥 🥮 🍡 🥟 🥠 🥡 🍦 🍧 🍨 🍩 🍪 🎂 🍰 🧁 🥧 🍫 🍬 🍭 🍮 🍯
drink:☕ 🍵 🥤 🍶 🍺 🍻 🥂 🍷 🥃 🍸 🍹 🍾 🧃 🧉
animal:🐶 🐱 🐭 🐹 🐰 🦊 🐻 🐼 🐨 🐯 🦁 🐮 🐷 🐸 🐵 🙈 🙉 🙊 🐒 🐔 🐧 🐦 🐤 🐣 🐥 🦆 🦅 🦉 🦇 🐺 🐗 🐴 🦄 🐝 🐛 🦋 🐌 🐞 🐜 🦟 🦗 🕷️ 🦂 🐢 🐍 🦎 🦖 🦕 🐙 🦑 🦐 🦞 🦀 🐡 🐠 🐟 🐬 🐳 🐋 🦈 🐊 🐅 🐆 🦓 🦍 🦧 🐘 🦛 🦏 🐪 🐫 🦒 🦘 🐃 🐂 🐄 🐎 🐖 🐏 🐑 🦙 🐐 🦌 🐕 🐩 🦮 🐕‍🦺 🐈 🐓 🦃 🦚 🦜 🦢 🦩 🕊️ 🐇 🦝 🦨 🦡 🦦 🦥 🐁 🐀 🐿️ 🦔
sport:⚽ 🏀 🏈 ⚾ 🥎 🎾 🏐 🏉 🥏 🎱 🪀 🏓 🏸 🏒 🏑 🥍 🏏 🥅 ⛳ 🪁 🏹 🎣 🤿 🥊 🥋 🎽 🛹 🛷 ⛸️ 🥌 🎿 ⛷️ 🏂 🪂 🏋️ 🤼 🤸 🤺 🤾 🏌️ 🏇 🧘 🏄 🏊 🤽 🚣 🧗 🚴 🏆 🥇 🥈 🥉 🏅 🎖️ 🏵️ 🎗️
music:🎵 🎶 🎼 🎹 🥁 🎸 🎺 🎷 🎻 🪕 🎤 🎧 🎚️ 🎛️ 🎙️ 📻
tech:💻 🖥️ 🖨️ ⌨️ 🖱️ 🖲️ 💾 💿 📀 📱 ☎️ 📞 📟 📠 📺 📷 📸 📹 📼 🔍 🔎 💡 🔦 🏮 🪔 📔 📕 📖 📗 📘 📙 📚 📓 📒 📃 📜 📄 📰 🗞️ 📑 🔖 🏷️ 💰 💴 💵 💶 💷 💸 💳 🧾 💹
flag:🏳️ 🏴 🏴‍☠️ 🏁 🚩 🏳️‍🌈 🏳️‍⚧️ 🇦🇫 🇦🇽 🇦🇱 🇩🇿 🇦🇸 🇦🇩 🇦🇴 🇦🇮 🇦🇶 🇦🇬 🇦🇷 🇦🇲 🇦🇼 🇦🇺 🇦🇹 🇦🇿 🇧🇸 🇧🇭 🇧🇩 🇧🇧 🇧🇾 🇧🇪 🇧🇿 🇧🇯 🇧🇲 🇧🇹 🇧🇴 🇧🇦 🇧🇼 🇧🇷 🇮🇴 🇻🇬 🇧🇳 🇧🇬 🇧🇫 🇧🇮 🇰🇭 🇨🇲 🇨🇦 🇮🇨 🇨🇻 🇧🇶 🇰🇾 🇨🇫 🇹🇩 🇨🇱 🇨🇳 🇨🇽 🇨🇨 🇨🇴 🇰🇲 🇨🇬 🇨🇩 🇨🇰 🇨🇷 🇨🇮 🇭🇷 🇨🇺 🇨🇼 🇨🇾 🇨🇿 🇩🇰 🇩🇯 🇩🇲 🇩🇴 🇪🇨 🇪🇬 🇸🇻 🇬🇶 🇪🇷 🇪🇪 🇪🇹 🇪🇺 🇫🇰 🇫🇴 🇫🇯 🇫🇮 🇫🇷 🇬🇫 🇵🇫 🇹🇫 🇬🇦 🇬🇲 🇬🇪 🇩🇪 🇬🇭 🇬🇮 🇬🇷 🇬🇱 🇬🇩 🇬🇵 🇬🇺 🇬🇹 🇬🇬 🇬🇳 🇬🇼 🇬🇾 🇭🇹 🇭🇳 🇭🇰 🇭🇺 🇮🇸 🇮🇳 🇮🇩 🇮🇷 🇮🇶 🇮🇪 🇮🇲 🇮🇱 🇮🇹 🇯🇲 🇯🇵 🎌 🇯🇪 🇯🇴 🇰🇿 🇰🇪 🇰🇮 🇽🇰 🇰🇼 🇰🇬 🇱🇦 🇱🇻 🇱🇧 🇱🇸 🇱🇷 🇱🇾 🇱🇮 🇱🇹 🇱🇺 🇲🇴 🇲🇰 🇲🇬 🇲🇼 🇲🇾 🇲🇻 🇲🇱 🇲🇹 🇲🇭 🇲🇶 🇲🇷 🇲🇺 🇾🇹 🇲🇽 🇫🇲 🇲🇩 🇲🇨 🇲🇳 🇲🇪 🇲🇸 🇲🇦 🇲🇿 🇲🇲 🇳🇦 🇳🇷 🇳🇵 🇳🇱 🇳🇨 🇳🇿 🇳🇮 🇳🇪 🇳🇬 🇳🇺 🇳🇫 🇰🇵 🇲🇵 🇳🇴 🇴🇲 🇵🇰 🇵🇼 🇵🇸 🇵🇦 🇵🇬 🇵🇾 🇵🇪 🇵🇭 🇵🇳 🇵🇱 🇵🇹 🇵🇷 🇶🇦 🇷🇪 🇷🇴 🇷🇺 🇷🇼 🇼🇸 🇸🇲 🇸🇹 🇸🇦 🇸🇳 🇷🇸 🇸🇨 🇸🇱 🇸🇬 🇸🇽 🇸🇰 🇸🇮 🇬🇸 🇸🇧 🇸🇴 🇿🇦 🇰🇷 🇸🇸 🇪🇸 🇱🇰 🇧🇱 🇸🇭 🇰🇳 🇱🇨 🇵🇲 🇻🇨 🇸🇩 🇸🇷 🇸🇿 🇸🇪 🇨🇭 🇸🇾 🇹🇼 🇹🇯 🇹🇿 🇹🇭 🇹🇱 🇹🇬 🇹🇰 🇹🇴 🇹🇹 🇹🇳 🇹🇷 🇹🇲 🇹🇨 🇹🇻 🇻🇮 🇺🇬 🇺🇦 🇦🇪 🇬🇧 🏴󐁧󐁢󐁥󐁮󐁧󐁿 🏴󐁧󐁢󐁳󐁣󐁴󐁿 🏴󐁧󐁢󐁷󐁬󐁳󐁿 🇺🇳 🇺🇸 🇺🇾 🇺🇿 🇻🇺 🇻🇦 🇻🇪 🇻🇳 🇼🇫 🇪🇭 🇾🇪 🇿🇲 🇿🇼
weather:☀️ 🌤️ ⛅ 🌥️ ☁️ 🌦️ 🌧️ ⛈️ 🌩️ 🌨️ ❄️ ☃️ ⛄ 🌬️ 💨 💧 💦 ☔ ☂️ 🌊 🌫️
ok:👌 ✅ ☑️ ✔️ ⭕ 🆗 🉑
no:❌ ⛔ 🚫 🚳 🚭 🚯 🚱 🚷 📵 🔞
arrow:⬆️ ↗️ ➡️ ↘️ ⬇️ ↙️ ⬅️ ↖️ ↕️ ↔️ ↩️ ↪️ ⤴️ ⤵️ 🔃 🔄 🔙 🔚 🔛 🔜 🔝
time:⏰ ⏱️ ⏲️ 🕐 🕑 🕒 🕓 🕔 🕕 🕖 🕗 🕘 🕙 🕚 🕛 🕜 🕝 🕞 🕟 🕠 🕡 🕢 🕣 🕤 🕥 🕦 🕧 ⌛ ⏳ ⌚
money:💵 💴 💶 💷 💰 💸 💳 🏦 💹
think:🤔 💭 🧠 💡 ❓ ❔ ❗ ❕
turkey:🇹🇷 🦃 🌍 🕌 ☪️
turk:🇹🇷 🦃 🌍 🕌 ☪️"

    # Arama yap
    if [ -n "$SEARCH" ]; then
        RESULTS=$(echo "$EMOJI_DB" | grep -i "^$SEARCH\|^[^:]*$SEARCH" | head -5)
        
        if [ -n "$RESULTS" ]; then
            # Sonuçları göster
            EMOJIS=$(echo "$RESULTS" | cut -d':' -f2 | tr ' ' '\n' | grep -v '^$')
            SELECTED=$(echo "$EMOJIS" | rofi -dmenu -p "😀 Emoji: $SEARCH" -theme ~/.config/rofi/themes/$THEME.rasi)
            
            if [ -n "$SELECTED" ]; then
                echo -n "$SELECTED" | wl-copy
                notify-send "Emoji" "Copied: $SELECTED" -t 1000
            fi
        else
            notify-send "Emoji" "No results for: $SEARCH" -i dialog-information -t 2000
        fi
    else
        # Kategori listesi göster
        CATEGORIES=$(echo "$EMOJI_DB" | cut -d':' -f1 | sort -u)
        SELECTED_CAT=$(echo "$CATEGORIES" | rofi -dmenu -p "😀 Emoji Categories" -theme ~/.config/rofi/themes/$THEME.rasi)
        
        if [ -n "$SELECTED_CAT" ]; then
            # Seçilen kategorinin emojilerini göster
            EMOJIS=$(echo "$EMOJI_DB" | grep "^$SELECTED_CAT:" | cut -d':' -f2 | tr ' ' '\n' | grep -v '^$')
            SELECTED=$(echo "$EMOJIS" | rofi -dmenu -p "😀 $SELECTED_CAT" -theme ~/.config/rofi/themes/$THEME.rasi)
            
            if [ -n "$SELECTED" ]; then
                echo -n "$SELECTED" | wl-copy
                notify-send "Emoji" "Copied: $SELECTED" -t 1000
            fi
        fi
    fi
}

# Keybind Search - jq olmadan
show_keybind_search() {
    SEARCH="${1,,}"
    
    # Hyprland keybind'lerini direkt parse et
    KEYBINDS=$(hyprctl binds | grep -E "^\s+bind" | 
               sed 's/bind\[0\] >> //' |
               sed 's/, exec,/ → /' |
               sed 's/SUPER/Super/g' |
               sed 's/SHIFT/Shift/g' |
               sed 's/CTRL/Ctrl/g' |
               sed 's/ALT/Alt/g' |
               column -t)
    
    if [ -n "$SEARCH" ]; then
        KEYBINDS=$(echo "$KEYBINDS" | grep -i "$SEARCH")
    fi
    
    if [ -n "$KEYBINDS" ]; then
        echo "$KEYBINDS" | rofi -dmenu -p "⌨️ Keybinds: $SEARCH" -theme ~/.config/rofi/themes/$THEME.rasi
    else
        notify-send "Keybinds" "No results for: $SEARCH" -i dialog-information -t 2000
    fi
}

# System Info
show_system_info() {
    INFO=""
    
    # CPU kullanımı
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    INFO+="󰻠 CPU: ${CPU}%\n"
    
    # RAM kullanımı
    MEM=$(free -h | awk '/^Mem:/ {printf "%.1f/%.1fG (%.0f%%)", $3, $2, ($3/$2)*100}')
    INFO+="󰍛 RAM: $MEM\n"
    
    # Disk kullanımı
    DISK=$(df -h / | awk 'NR==2 {printf "%s/%s (%s)", $3, $2, $5}')
    INFO+="󰋊 Disk: $DISK\n"
    
    # Uptime
    UPTIME=$(uptime -p | sed 's/up //')
    INFO+="󰔚 Uptime: $UPTIME\n"
    
    # Kernel
    KERNEL=$(uname -r)
    INFO+="󰌽 Kernel: $KERNEL\n"
    
    # CPU Temp (if available)
    if [ -f "/sys/class/thermal/thermal_zone0/temp" ]; then
        TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
        TEMP=$((TEMP/1000))
        INFO+="󰔐 Temp: ${TEMP}°C\n"
    fi
    
    echo -e "$INFO" | rofi -dmenu -p "󰍛 System Info" -theme ~/.config/rofi/themes/$THEME.rasi
}

# Check Updates
check_updates() {
    notify-send "Updates" "Checking for updates..." -t 2000
    
    # Pacman updates
    PACMAN_UPDATES=$(checkupdates 2>/dev/null | wc -l)
    
    # AUR updates
    AUR_UPDATES=$(yay -Qua 2>/dev/null | wc -l)
    
    TOTAL=$((PACMAN_UPDATES + AUR_UPDATES))
    
    if [ $TOTAL -eq 0 ]; then
        notify-send "Updates" "System is up to date! ✓" -i emblem-default
    else
        OPTIONS="󰏗 Update All\n󰏗 Pacman Updates ($PACMAN_UPDATES)\n󰏗 AUR Updates ($AUR_UPDATES)\n󰋔 View Updates"
        CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "󰏗 Updates Available: $TOTAL" -theme ~/.config/rofi/themes/$THEME.rasi)
        
        case "$CHOICE" in
            "󰏗 Update All")
                kitty -e bash -c "yay -Syu; echo 'Press enter to exit'; read" &
                ;;
            "󰏗 Pacman Updates"*)
                kitty -e bash -c "sudo pacman -Syu; echo 'Press enter to exit'; read" &
                ;;
            "󰏗 AUR Updates"*)
                kitty -e bash -c "yay -Sua; echo 'Press enter to exit'; read" &
                ;;
            "󰋔 View Updates")
                UPDATES=$(checkupdates 2>/dev/null; yay -Qua 2>/dev/null)
                echo "$UPDATES" | rofi -dmenu -p "󰏗 Available Updates" -theme ~/.config/rofi/themes/$THEME.rasi
                ;;
        esac
    fi
}

# Show running tasks
show_tasks() {
    # Process listesi al
    TASKS=$(ps aux --sort=-%cpu | head -20 | awk 'NR>1 {printf "%-8s %5s %5s %-15s %s\n", $2, $3, $4, $11, substr($0, index($0,$11))}' | column -t)
    
    # Header ekle
    HEADER="PID      CPU%  MEM%  COMMAND"
    ALL_TASKS="$HEADER\n────────────────────────────────\n$TASKS"
    
    # Seçim yap
    SELECTED=$(echo -e "$ALL_TASKS" | rofi -dmenu -p "󰓇 Tasks (click to kill)" -theme ~/.config/rofi/themes/$THEME.rasi)
    
    # PID al ve öldür
    if [ -n "$SELECTED" ] && [[ ! "$SELECTED" =~ ^PID ]] && [[ ! "$SELECTED" =~ ^─+ ]]; then
        PID=$(echo "$SELECTED" | awk '{print $1}')
        PNAME=$(echo "$SELECTED" | awk '{print $4}')
        
        # Onay iste
        CONFIRM=$(echo -e "Yes\nNo" | rofi -dmenu -p "Kill $PNAME (PID: $PID)?" -theme ~/.config/rofi/themes/$THEME.rasi)
        
        if [ "$CONFIRM" = "Yes" ]; then
            kill -9 "$PID" 2>/dev/null && \
                notify-send "Process Killed" "$PNAME (PID: $PID)" -i process-stop || \
                notify-send "Error" "Failed to kill process" -i dialog-error
        fi
    fi
}

# Toggle screen recording with OBS
toggle_screen_recording() {
    # OBS çalışıyor mu kontrol et
    if pgrep -x "obs" > /dev/null; then
        # OBS websocket veya basit kill
        killall obs
        notify-send "Screen Recording" "Recording stopped" -i media-record
    else
        # OBS başlat (minimized ve auto-start recording)
        obs --startrecording --minimize-to-tray &
        notify-send "Screen Recording" "Recording started with OBS" -i media-record
    fi
}

# Translate text
translate_text() {
    TEXT="$1"
    
    if [ -z "$TEXT" ]; then
        # Boşsa input al
        TEXT=$(echo "" | rofi -dmenu -p "󰊿 Translate" -theme ~/.config/rofi/themes/$THEME.rasi)
    fi
    
    if [ -n "$TEXT" ]; then
        # URL encode
        ENCODED=$(echo "$TEXT" | sed 's/ /%20/g')
        xdg-open "https://translate.google.com/?sl=auto&tl=tr&text=$ENCODED"
    fi
}

# Bitwarden menu
bitwarden_menu() {
    # Login durumu kontrol et
    STATUS=$(bw status 2>/dev/null | jq -r '.status' 2>/dev/null || echo "unauthenticated")
    
    if [ "$STATUS" != "unlocked" ]; then
        OPTIONS="🔐 Login to Bitwarden\n🔓 Unlock Bitwarden"
        CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "󰌋 Bitwarden Locked" -theme ~/.config/rofi/themes/$THEME.rasi)
        
        case "$CHOICE" in
            "🔐 Login to Bitwarden")
                kitty -e bash -c "bw login; echo 'Press enter to exit'; read" &
                ;;
            "🔓 Unlock Bitwarden")
                PASSWORD=$(echo "" | rofi -dmenu -password -p "󰌋 Master Password" -theme ~/.config/rofi/themes/$THEME.rasi)
                if [ -n "$PASSWORD" ]; then
                    SESSION=$(echo "$PASSWORD" | bw unlock --raw 2>/dev/null)
                    if [ -n "$SESSION" ]; then
                        export BW_SESSION="$SESSION"
                        notify-send "Bitwarden" "Unlocked successfully" -i dialog-password
                        bitwarden_menu  # Tekrar çağır
                    else
                        notify-send "Bitwarden" "Failed to unlock" -i dialog-error
                    fi
                fi
                ;;
        esac
        return
    fi
    
    # Items listesi - jq hatalarını yakala
    ITEMS=$(bw list items 2>/dev/null | jq -r '.[] | select(.type == 1) | "\(.name) [\(.login.username // "no username")]"' 2>/dev/null || echo "")
    
    if [ -z "$ITEMS" ]; then
        notify-send "Bitwarden" "No items found or parse error" -i dialog-information
        return
    fi
    
    # Seçim yap
    SELECTED=$(echo "$ITEMS" | rofi -dmenu -p "󰌋 Bitwarden" -theme ~/.config/rofi/themes/$THEME.rasi)
    
    if [ -n "$SELECTED" ]; then
        # Item adını al - sed yerine parametre expansion kullan
        ITEM_NAME="${SELECTED%% \[*}"
        
        # Alt menü
        OPTIONS="📋 Copy Password\n👤 Copy Username\n🌐 Open URL\n📝 View Details"
        ACTION=$(echo -e "$OPTIONS" | rofi -dmenu -p "󰌋 $ITEM_NAME" -theme ~/.config/rofi/themes/$THEME.rasi)
        
        case "$ACTION" in
            "📋 Copy Password")
                PASSWORD=$(bw get password "$ITEM_NAME" 2>/dev/null)
                if [ -n "$PASSWORD" ]; then
                    echo -n "$PASSWORD" | wl-copy
                    notify-send "Bitwarden" "Password copied" -i dialog-password -t 2000
                fi
                ;;
            "👤 Copy Username")
                USERNAME=$(bw get username "$ITEM_NAME" 2>/dev/null)
                if [ -n "$USERNAME" ]; then
                    echo -n "$USERNAME" | wl-copy
                    notify-send "Bitwarden" "Username copied" -i dialog-password -t 2000
                fi
                ;;
            "🌐 Open URL")
                URL=$(bw get uri "$ITEM_NAME" 2>/dev/null)
                if [ -n "$URL" ]; then
                    xdg-open "$URL"
                fi
                ;;
            "📝 View Details")
                DETAILS=$(bw get item "$ITEM_NAME" 2>/dev/null | jq -r '. | "Name: \(.name)\nUsername: \(.login.username // "N/A")\nURL: \(.login.uris[0].uri // "N/A")\nNotes: \(.notes // "N/A")"' 2>/dev/null || echo "Parse error")
                echo "$DETAILS" | rofi -dmenu -p "󰌋 Details: $ITEM_NAME" -theme ~/.config/rofi/themes/$THEME.rasi
                ;;
        esac
    fi
}

# Set timer
set_timer() {
    TIME_STR="$1"
    
    if [ -z "$TIME_STR" ]; then
        notify-send "Timer" "Usage: .timer 5m or .timer 30s" -i dialog-information
        return
    fi
    
    # Parse time (5m, 30s, 1h gibi)
    if [[ "$TIME_STR" =~ ^([0-9]+)([smh])$ ]]; then
        NUM="${BASH_REMATCH[1]}"
        UNIT="${BASH_REMATCH[2]}"
        
        case "$UNIT" in
            s) SECONDS=$NUM ;;
            m) SECONDS=$((NUM * 60)) ;;
            h) SECONDS=$((NUM * 3600)) ;;
        esac
        
        notify-send "Timer Set" "Timer set for $TIME_STR" -i alarm-clock
        
        # Background timer
        (
            sleep "$SECONDS"
            notify-send "Timer Expired!" "Your $TIME_STR timer has finished" -u critical -i alarm-clock
            # Ses çal (opsiyonel)
            paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null
        ) &
    else
        notify-send "Timer" "Invalid format. Use: 5m, 30s, 1h" -i dialog-error
    fi
}

# Show disk usage
show_disk_usage() {
    # Tüm mount pointleri için disk kullanımı
    DISK_INFO=$(df -h | grep -E '^/dev/' | awk '{printf "%-20s %5s %5s %5s %5s\n", $6, $2, $3, $4, $5}' | column -t)
    
    # Header ekle
    HEADER="MOUNT                SIZE  USED  AVAIL USE%"
    ALL_INFO="$HEADER\n────────────────────────────────────────\n$DISK_INFO"
    
    # Detaylı bilgi için seçim
    SELECTED=$(echo -e "$ALL_INFO" | rofi -dmenu -p "󰋊 Disk Usage" -theme ~/.config/rofi/themes/$THEME.rasi)
    
    # Eğer bir mount point seçildiyse, o dizinin içeriğini göster
    if [ -n "$SELECTED" ] && [[ ! "$SELECTED" =~ ^MOUNT ]] && [[ ! "$SELECTED" =~ ^─+ ]]; then
        MOUNT=$(echo "$SELECTED" | awk '{print $1}')
        
        # du ile en büyük klasörleri göster
        notify-send "Disk Usage" "Analyzing $MOUNT..." -t 2000
        
        USAGE=$(du -h "$MOUNT" --max-depth=1 2>/dev/null | sort -hr | head -20)
        echo "$USAGE" | rofi -dmenu -p "󰋊 Disk Usage: $MOUNT" -theme ~/.config/rofi/themes/$THEME.rasi
    fi
}

# Color picker
pick_color() {
    notify-send "Color Picker" "Click on any pixel to pick color" -t 2000
    
    # grim ve slurp ile renk seç
    COLOR=$(grim -g "$(slurp -p)" -t ppm - | convert - -format '%[pixel:p{0,0}]' txt:- | tail -n1 | awk '{print $3}')
    
    if [ -n "$COLOR" ]; then
        # Hex formatına çevir
        HEX=$(echo "$COLOR" | sed 's/srgb/rgb/' | convert xc:"$COLOR" -format "#%[hex:s]\n" info:- | head -n1)
        
        # Kopyala
        echo -n "$HEX" | wl-copy
        
        # Renk önizlemesi ile bildirim
        notify-send "Color Picked" "Color $HEX copied to clipboard" -i color-picker
        
        # Renk bilgilerini göster
        echo -e "Hex: $HEX\nRGB: $COLOR" | rofi -dmenu -p "󰏘 Color Info" -theme ~/.config/rofi/themes/$THEME.rasi
    fi
}

# Calculator - 2>/dev/null ekledik font uyarısı için
calculate() {
    INPUT="$1"
    
    # bc için düzeltmeler
    CALC_INPUT=$(echo "$INPUT" | sed 's/×/*/g' | sed 's/÷/\//g' | sed 's/,/./g')
    
    # Hesapla (stderr'i yok say)
    RESULT=$(echo "scale=10; $CALC_INPUT" | bc -l 2>/dev/null | sed 's/\.0*$//')
    
    if [ $? -eq 0 ] && [ -n "$RESULT" ]; then
        # Sonucu göster ve kopyala (font uyarısını bastır)
        echo "$INPUT = $RESULT" | rofi -dmenu -p "🧮 Result (copied)" -theme ~/.config/rofi/themes/$THEME.rasi 2>/dev/null
        echo -n "$RESULT" | wl-copy
        notify-send "Calculator" "Result copied: $RESULT" -t 2000
    else
        notify-send "Calculator" "Invalid expression" -i dialog-error -t 2000
    fi
}

# Ana fonksiyonu çalıştır
main "$@"
