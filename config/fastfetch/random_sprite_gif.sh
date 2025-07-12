#!/bin/bash

echo "[`date`] Yeni terminal oturumu" >> ~/sprite_anim_debug.log

gifdir="$HOME/Desktop/ProjectZenh/katana-zero-terminal/sprite_gifs_fixed"

gif=$(find "$gifdir" -type f -iname "*.gif" | shuf -n 1)

echo "Gösterilen GIF: $gif" >> ~/sprite_anim_debug.log

kitty +kitten icat --place 40x20@0x0 "$gif" & disown
