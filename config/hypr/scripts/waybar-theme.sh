#!/bin/bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc — Waybar Tema (UI) Değiştirici                  ║
# ║  JaKooLit ilhamıyla: Tam layout ve stil değişimi         ║
# ╚══════════════════════════════════════════════════════════╝

THEMES_DIR="$HOME/.config/waybar/themes"
WAYBAR_DIR="$HOME/.config/waybar"

# Temalar klasörü yoksa (henüz deploy edilmediyse) yerel dizini kullan
if [[ ! -d "$THEMES_DIR" ]]; then
    # Scriptin bulunduğu yerden projeye git (thyprsc/config/waybar/themes)
    THEMES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../config/waybar/themes" && pwd)"
fi

if [[ ! -d "$THEMES_DIR" ]]; then
    notify-send -t 3000 "Waybar" "Tema klasörü bulunamadı: $THEMES_DIR"
    exit 1
fi

# Temaları listele
list_themes() {
    find "$THEMES_DIR" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;
}

# Rofi ile tema seç
selected_theme=$(list_themes | rofi -dmenu -p "󰗊 Waybar Teması Seç" -i -no-custom)

if [[ -z "$selected_theme" ]]; then
    exit 0
fi

SELECTED_PATH="$THEMES_DIR/$selected_theme"

# Geçerlilik kontrolü
if [[ ! -f "$SELECTED_PATH/config.jsonc" ]] || [[ ! -f "$SELECTED_PATH/style.css" ]]; then
    notify-send -t 3000 "Waybar" "Hata: Seçilen temada gerekli dosyalar yok!"
    exit 1
fi

# Linkleme/Kopyalama İşlemi
# Not: JaKooLit yaklaşımı genellikle kopyalamadır ancak linkleme daha temizdir.
# Biz burada kopyalamayı tercih ediyoruz ki manuel müdahaleler ana temayı bozmasın.

mkdir -p "$WAYBAR_DIR"

cp "$SELECTED_PATH/config.jsonc" "$WAYBAR_DIR/config.jsonc"
cp "$SELECTED_PATH/style.css" "$WAYBAR_DIR/style.css"

# Hangi temanın aktif olduğunu kaydet ki deploy.sh güncellediğinde bilsin
echo "$selected_theme" > "$WAYBAR_DIR/.current_theme"

# Varsa ek dosyaları da kopyala (modüller vb.)
if [[ -d "$SELECTED_PATH/modules" ]]; then
    cp -rf "$SELECTED_PATH/modules" "$WAYBAR_DIR/"
fi

# Waybar'ı Yenile (SIGUSR2 sinyali ile)
if pgrep -x "waybar" > /dev/null; then
    pkill -SIGUSR2 waybar
else
    waybar > /dev/null 2>&1 &
fi

notify-send -t 2000 "Waybar" "Tema '$selected_theme' başarıyla uygulandı."
