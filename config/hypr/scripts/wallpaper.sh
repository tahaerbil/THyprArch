#!/bin/bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc — Wallpaper Değiştirme Scripti (awww)           ║
# ║  Mevcut duvar kağıtları arasında rastgele geçiş yapar    ║
# ╚══════════════════════════════════════════════════════════╝

# Duvar kağıtlarının bulunduğu varsayılan dizinler
WALLPAPER_DIRS=(
    "$HOME/Pictures/Wallpapers"
    "$HOME/.config/hypr/themes/wallpapers"
    "$HOME/.config/hypr/wallpapers"
)

# awww daemon çalışmıyorsa başlat
if ! pgrep -x awww-daemon > /dev/null; then
    awww-daemon &
    sleep 0.5
fi

# Geçerli bir dizin bul
TARGET_DIR=""
for dir in "${WALLPAPER_DIRS[@]}"; do
    if [[ -d "$dir" ]] && [[ $(ls -A "$dir" | wc -l) -gt 0 ]]; then
        TARGET_DIR="$dir"
        break
    fi
done

if [[ -z "$TARGET_DIR" ]]; then
    #notify-send -t 3000 "Wallpaper Script" "Duvar kağıdı bulunamadı! Lütfen ${WALLPAPER_DIRS[0]} dizinine resim ekleyin."
    exit 1
fi

# Dizindeki resimleri listele
WALLPAPERS=($(find "$TARGET_DIR" -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png -o -iname \*.gif -o -iname \*.webp \)))

if [[ ${#WALLPAPERS[@]} -eq 0 ]]; then
    #notify-send -t 3000 "Wallpaper Script" "Klasörde uygun formatta duvar kağıdı bulunamadı."
    exit 1
fi

# Sıralı değişim için indeks dosyasını belirle
INDEX_FILE="$HOME/.config/hypr/.current_wallpaper_index"

# Eğer dosya yoksa 0'dan başla
if [[ ! -f "$INDEX_FILE" ]]; then
    echo 0 > "$INDEX_FILE"
fi

# Mevcut indeksi oku
CURRENT_INDEX=$(cat "$INDEX_FILE")

# Eğer indeks toplam sayıdan büyükse sıfırla (klasör değişmiş olabilir)
if [ "$CURRENT_INDEX" -ge "${#WALLPAPERS[@]}" ]; then
    CURRENT_INDEX=0
fi

# Duvar kağıdını seç
SELECTED_WALLPAPER="${WALLPAPERS[$CURRENT_INDEX]}"

# Bir sonraki indeks'i hesapla ve kaydet
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#WALLPAPERS[@]} ))
echo "$NEXT_INDEX" > "$INDEX_FILE"

# Rastgele bir resim seç (Devre dışı bırakıldı)
#RANDOM_INDEX=$((RANDOM % ${#WALLPAPERS[@]}))
#SELECTED_WALLPAPER="${WALLPAPERS[$RANDOM_INDEX]}"

# Duvar kağıdını awww ile uygula (geçiş efekti ile)
awww img "$SELECTED_WALLPAPER" \
    --transition-type grow \
    --transition-pos top \
    --transition-duration 0.5 \
    --transition-fps 60

#notify-send -t 2000 "Wallpaper" "Duvar kağıdı değiştirildi."
