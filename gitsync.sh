#!/bin/bash

set -e

echo "🛠️  Dotfiles senkronizasyonu başlatılıyor..."

# Kopyalanacak config klasörleri
CONFIGS=(
  kitty
  rofi
  waybar
  swaync
  hypr
  wallust
  gtk-3.0
  gtk-4.0
  fastfetch
  wlogout
)

# .zshrc dosyasını da senkronize et
echo "🔁 .zshrc dosyası kopyalanıyor..."
cp ~/.zshrc ~/dotfiles/config/zsh/.zshrc 2>/dev/null || echo "⚠️ .zshrc bulunamadı"

# Her config klasörü için kopyalama yap
for config in "${CONFIGS[@]}"; do
  SRC="$HOME/.config/$config"
  DEST="$HOME/dotfiles/config/$config"

  if [ -d "$SRC" ]; then
    echo "🔁 $config klasörü kopyalanıyor..."
    rm -rf "$DEST"
    cp -r "$SRC" "$DEST"
  else
    echo "⚠️ $config klasörü bulunamadı, atlanıyor."
  fi
done

# Git işlemleri
cd ~/dotfiles
git add .
git commit -m "update: auto sync from system"
git push

echo "✅ Dotfiles yedekleme tamamlandı!"
