#!/bin/bash

# config/hypr/ içindeki dosyaları ~/.config/hypr/ altına kopyalar

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TARGET="$HOME/.config/hypr"

mkdir -p "$TARGET/conf" "$TARGET/scripts" "$TARGET/themes"

cp "$SCRIPT_DIR/hyprland.conf" "$TARGET/"
cp "$SCRIPT_DIR/hyprlock.conf" "$TARGET/" 2>/dev/null
cp "$SCRIPT_DIR/conf/"* "$TARGET/conf/"
cp "$SCRIPT_DIR/scripts/"* "$TARGET/scripts/"
chmod +x "$TARGET/scripts/"*.sh

# Temaları kopyala
if [[ -d "$REPO_ROOT/config/themes" ]]; then
    cp -r "$REPO_ROOT/config/themes/"* "$TARGET/themes/"
fi

# Duvar kağıtlarını kopyala (Taha klasörü)
if [[ -d "$REPO_ROOT/config/hypr/themes/wallpapers/taha" ]]; then
    mkdir -p "$TARGET/themes/wallpapers"
    cp -r "$REPO_ROOT/config/hypr/themes/wallpapers/taha" "$TARGET/themes/wallpapers/"
fi

# Eğer colors.conf yoksa varsayılan temayı uygula
if [[ ! -f "$TARGET/conf/colors.conf" ]]; then
    if [[ -f "$TARGET/themes/catppuccin-mocha/colors.conf" ]]; then
        cp "$TARGET/themes/catppuccin-mocha/colors.conf" "$TARGET/conf/colors.conf"
        echo "catppuccin-mocha" > "$TARGET/.current-theme"
    fi
fi

hyprctl reload 2>/dev/null
echo "Hyprland konfigürasyonu ~/.config/hypr/ altına kopyalandı ve yeniden yüklendi."
