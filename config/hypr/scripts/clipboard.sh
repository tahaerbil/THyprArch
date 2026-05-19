#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc - Akıllı Pano Yöneticisi                        ║
# ║  cliphist seçimlerini işleyen ara betik                  ║
# ║  (Ekran görüntülerini silinseler bile yedekten kurtarır) ║
# ╚══════════════════════════════════════════════════════════╝

# Rofi menüsüne "Panoyu Temizle" seçeneğini en üste ekleyerek listeyi göster
selection=$( (echo "󰃢  Panoyu Temizle"; cliphist list) | rofi -dmenu -theme ~/.config/rofi/themes/launcher.rasi -p "Pano:" -i)

if [[ -z "$selection" ]]; then
    exit 0
fi

# Eğer kullanıcı temizlemeyi seçtiyse
if [[ "$selection" == "󰃢  Panoyu Temizle" ]]; then
    cliphist wipe
    notify-send -h string:x-canonical-private-synchronous:clipboard \
        -u low -i "edit-clear-all" "Pano" "Pano geçmişi tamamen temizlendi."
    exit 0
fi

# cliphist'ten seçilen öğeyi çıkar (decode et)
content=$(echo "$selection" | cliphist decode)

# Eğer içerik bir ekran görüntüsü yolu (file://...) ise
if [[ "$content" =~ ^file://(/.*\.png)$ ]]; then
    file_path="${BASH_REMATCH[1]}"
    file_name=$(basename "$file_path")
    
    # Kalıcı depolama yolu (Genelde ~/Resimler/Screenshots)
    PICTURES_DIR=$(xdg-user-dir PICTURES)
    PERMANENT_PATH="$PICTURES_DIR/Screenshots/$file_name"

    # EĞER: Seçilen dosya geçici (/tmp) klasörde yoksa (silinmişse), 
    # asıl yerinde (Resimler) duruyor mu kontrol et.
    if [[ ! -f "$file_path" && -f "$PERMANENT_PATH" ]]; then
        file_path="$PERMANENT_PATH"
    fi
    
    # Dosya sistemde var mı kontrol et (Geçici veya Kalıcı fark etmez)
    if [[ -f "$file_path" ]]; then
        # Görseli hem gerçek veri hem de dosya yolu olarak panoya koy
        wl-copy --type "image/png" < "$file_path"
        printf "%s" "file://$file_path" | wl-copy --type "text/uri-list" --append
        
        notify-send -h string:x-canonical-private-synchronous:clipboard \
            -u low -i "image-x-generic" "Pano" "Görsel yedekten geri kopyalandı."
        exit 0
    fi
fi

# Değilse normal şekilde panoya kopyala (Metin vb.)
echo "$content" | wl-copy
