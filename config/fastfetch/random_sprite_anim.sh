#!/bin/bash

# Hata log dosyası
logfile=~/sprite_anim_debug.log
echo "[$(date)] Yeni terminal oturumu" >> "$logfile"

# Animasyon klasörlerini al
animation_dirs=(~/sprite_animations/*)
echo "Klasör sayısı: ${#animation_dirs[@]}" >> "$logfile"

# Rastgele bir klasör seç
random_dir="${animation_dirs[RANDOM % ${#animation_dirs[@]}]}"
echo "Seçilen klasör: $random_dir" >> "$logfile"

# Klasördeki PNG karelerini sırala
frames=("$random_dir"/*.png)
echo "Toplam kare sayısı: ${#frames[@]}" >> "$logfile"

# Eğer hiç PNG yoksa çık
if [ "${#frames[@]}" -eq 0 ]; then
    echo "HATA: Klasörde PNG bulunamadı!" >> "$logfile"
    exit 1
fi

# Ekrana animasyon ismini yaz
animation_name=$(basename "$random_dir")
tput cup 0 30
echo -e "\e[35mAnimation: $animation_name\e[0m"

# Animasyonu döndür
while true; do
    for frame in "${frames[@]}"; do
        if [[ -f "$frame" ]]; then
            echo "Gösteriliyor: $frame" >> "$logfile"
            kitty +kitten icat --align left "$frame" 2>>"$logfile"
            sleep 0.08
        else
            echo "Uyarı: Kare dosyası bulunamadı → $frame" >> "$logfile"
        fi
    done
done
