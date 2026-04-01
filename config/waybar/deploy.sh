#!/bin/bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc — Waybar Dağıtım ve Başlatma Scripti            ║
# ╚══════════════════════════════════════════════════════════╝

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME/.config/waybar"

mkdir -p "$TARGET"

# 1. Proje dizinindeki tüm içerikleri hedefe temiz bir şekilde kopyala (Eskilerini silerek)
for item in "$SCRIPT_DIR"/*; do
    item_name=$(basename "$item")
    
    # Kendi kendini ana ayarlara atmasın diye deploy dosyasını atlıyoruz
    if [[ "$item_name" == "deploy.sh" ]]; then
        continue
    fi
    
    # Eğer hedef dizinde aynı isimde klasör veya dosya varsa tamamen temizle
    if [[ -e "$TARGET/$item_name" ]]; then
        rm -rf "$TARGET/$item_name"
    fi
    
    # Hiçbir çakışma riski kalmadığında klasörü/dosyayı güvenle içeri at
    cp -rf "$item" "$TARGET/"
done

# 2. Aktif Temayı Güncelle veya Varsayılan Temayı Kur
if [[ -f "$TARGET/.current_theme" ]]; then
    CURRENT_WAYBAR_THEME=$(cat "$TARGET/.current_theme")
    if [[ -d "$TARGET/themes/$CURRENT_WAYBAR_THEME" ]]; then
        cp "$TARGET/themes/$CURRENT_WAYBAR_THEME/config.jsonc" "$TARGET/config.jsonc"
        cp "$TARGET/themes/$CURRENT_WAYBAR_THEME/style.css" "$TARGET/style.css"
        echo "Aktif Waybar teması ($CURRENT_WAYBAR_THEME) başarıyla kopyalandı."
    fi
else
    # Eğer hafızada aktif bir tema yoksa, varsayılan olarak minimal-dynamic kurulumu:
    if [[ ! -f "$TARGET/config.jsonc" ]]; then
        if [[ -f "$TARGET/themes/minimal-dynamic/config.jsonc" ]]; then
            cp "$TARGET/themes/minimal-dynamic/config.jsonc" "$TARGET/config.jsonc"
        fi
    fi

    if [[ ! -f "$TARGET/style.css" ]]; then
        if [[ -f "$TARGET/themes/minimal-dynamic/style.css" ]]; then
            cp "$TARGET/themes/minimal-dynamic/style.css" "$TARGET/style.css"
        fi
    fi
    # Varsayılan temanın adını da kaydedelim
    echo "minimal-dynamic" > "$TARGET/.current_theme"
fi

# 3. Hyprland tema entegrasyonu (Opsiyonel: theme.css)
THEMES_DIR="$HOME/.config/hypr/themes"
CURRENT_THEME_FILE="$HOME/.config/hypr/.current-theme"

if [[ -f "$CURRENT_THEME_FILE" ]]; then
    theme=$(cat "$CURRENT_THEME_FILE" | tr -d '[:space:]')
    if [[ -f "$THEMES_DIR/$theme/theme.conf" ]]; then
        cp "$THEMES_DIR/$theme/theme.conf" "$TARGET/theme.css"
    fi
fi

# 4. Waybar'ı Yenile (SIGUSR2 sinyali ile)
if pgrep -x "waybar" > /dev/null; then
    pkill -SIGUSR2 waybar
else
    waybar > /dev/null 2>&1 &
fi

echo "Waybar temaları ve konfigürasyonu ~/.config/waybar/ altına kopyalandı."
