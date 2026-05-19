#!/bin/bash
# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc - Premium Ekran Görüntüsü Scripti               ║
# ║  Bağımlılıklar: grim, slurp, satty, wl-clipboard, jq     ║
# ╚══════════════════════════════════════════════════════════╝

DIR="$(xdg-user-dir PICTURES)/Screenshots"
mkdir -p "$DIR"

TMP_DIR="/tmp/screenshots"
mkdir -p "$TMP_DIR"

SLURP_ARGS="-b 1e1e2e66 -c 89b4faff -w 2"

cleanup() {
    [[ -n "$FREEZE_PID" ]] && kill "$FREEZE_PID" 2>/dev/null
}
trap cleanup EXIT

freeze_screen() {
    wayfreeze &
    FREEZE_PID=$!
    sleep 0.2
}

new_name() {
    echo "$DIR/$(date +%Y%m%d_%H%M%S).png"
}


# Pano içeriğini kontrol etmek için:
#   wl-paste --list-types
#   wl-paste --type "text/uri-list"
#   wl-paste --type "x-special/gnome-copied-files"

# Thunar'ın sağ tık → kopyala yaptığında panoya yazdığı formatın birebir aynısı:
#   text/uri-list                  → file:///tmp/screenshots/20260310_021029.png
#   x-special/gnome-copied-files  → copy\nfile://...
#   text/plain;charset=utf-8      → file:///tmp/...
#   UTF8_STRING                   → file:///tmp/...
copy_to_clipboard() {
    local file_path="$1"
    local uri="file://$file_path"

    # Görüntünün ham verisini kopyala (Discord, Web WhatsApp vb. yapıştırmak için)
    wl-copy --type "image/png" < "$file_path"
    
    # Dosya yollarını (URI) arkasına ekle (Thunar/Dolphin içine yapıştırmak için)
    printf "%s" "$uri"              | wl-copy --type "text/uri-list" --append
    printf "copy\n%s" "$uri"        | wl-copy --type "x-special/gnome-copied-files" --append
    printf "%s" "$uri"              | wl-copy --type "text/plain;charset=utf-8" --append
    printf "%s" "$uri"              | wl-copy --type "UTF8_STRING" --append
}

notify_view() {
    local file_path="$1"
    [[ ! -s "$file_path" ]] && return

    local file_name
    file_name=$(basename "$file_path")

    # Geçici klasöre kopyala
    rm -f "$TMP_DIR"/*.png
    local tmp_path="$TMP_DIR/$file_name"
    cp "$file_path" "$tmp_path"

    # Thunar formatında panoya kopyala
    copy_to_clipboard "$tmp_path"

    notify-send -i "$file_path" \
        "Ekran Görüntüsü" \
        "📁 $file_name\nKaydedildi ve panoya kopyalandı." \
        --action="view=Göster" | \
        xargs -I {} bash -c "[[ '{}' == 'view' ]] && xdg-open '$file_path'" &
}

case "$1" in
    full)
        NAME=$(new_name)
        grim "$NAME"
        notify_view "$NAME"
        ;;

    area)
        freeze_screen
        AREA=$(slurp $SLURP_ARGS)
        [[ -z "$AREA" ]] && { cleanup; exit 0; }
        sleep 0.2 # Slurp çerçevesinin ekrandan silinmesi için kısacık bir süre bekle
        NAME=$(new_name)
        grim -g "$AREA" "$NAME"
        cleanup
        notify_view "$NAME"
        ;;

    window)
        read -r X Y W H < <(hyprctl activewindow -j | jq -r '.at[0], .at[1], .size[0], .size[1]')
        WINDOW_GEOM="${X},${Y} ${W}x${H}"
        [[ -z "$X" ]] && exit 1
        NAME=$(new_name)
        grim -g "$WINDOW_GEOM" "$NAME"
        notify_view "$NAME"
        ;;

    edit)
        freeze_screen
        AREA=$(slurp $SLURP_ARGS)
        [[ -z "$AREA" ]] && { cleanup; exit 0; }
        sleep 0.2 # Slurp çerçevesinin ekrandan silinmesi için kısacık bir süre bekle
        TEMP_FILE="/tmp/screenshot_edit_$(date +%s).png"
        grim -g "$AREA" "$TEMP_FILE"
        cleanup
        if [[ -s "$TEMP_FILE" ]]; then
            NAME=$(new_name)
            satty --filename "$TEMP_FILE" --output-filename "$NAME"
            if [[ -f "$NAME" ]]; then
                notify_view "$NAME"
            fi
        fi
        rm -f "$TEMP_FILE"
        ;;

    menu)
        freeze_screen
        CHOICE=$(printf "󰍹  Tam Ekran\n󰒉  Alan Seç\n󱂬  Pencere\n󰏫  Düzenle (Satty)" | \
            rofi -dmenu -theme ~/.config/rofi/themes/launcher.rasi -p "Ekran Görüntüsü:" -i)
        cleanup
        case "$CHOICE" in
            *"Tam Ekran") $0 full ;;
            *"Alan Seç")  $0 area ;;
            *"Pencere")   $0 window ;;
            *"Düzenle")   $0 edit ;;
        esac
        ;;

    *)
        echo "Kullanım: $0 {full|area|window|edit|menu}"
        exit 1
        ;;
esac