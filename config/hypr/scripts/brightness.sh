#!/usr/bin/env bash

# ╔════════════════════════════════════════════════════════════╗
# ║  thyprsc - Akıllı Parlaklık Kontrolü                       ║
# ║  Tüm monitörleri (Laptop ve Harici) aynı anda ayarlar      ║
# ╚════════════════════════════════════════════════════════════╝

LOCKFILE="/tmp/thyprsc_ddc.lock"

get_laptop_brightness() {
    local cur=$(brightnessctl get)
    local max=$(brightnessctl max)
    local percent=$(( (cur * 100 + max / 2) / max ))
    
    if [ "$percent" -lt 5 ] && [ "$cur" -gt 0 ]; then
        echo "5"
    else
        echo "$percent"
    fi
}

get_icon() {
    local current_val=$1
    if [ "$current_val" -lt 30 ]; then
        echo "notification-display-brightness-low"
    elif [ "$current_val" -lt 70 ]; then
        echo "notification-display-brightness-medium"
    else
        echo "notification-display-brightness-high"
    fi
}

notify_user() {
    local current_val=$1
    local icon_name=$(get_icon "$current_val")

    # Bildirimi arka planda gönder ki script anında kapansın, gecikme olmasın
    notify-send -h int:transient:1 \
        -h string:x-canonical-private-synchronous:brightness-osd \
        -u low -i "$icon_name" -h int:value:"$current_val" "Parlaklık: ${current_val}%" &
}

hw_laptop() {
    if [[ "$1" == "up" ]]; then
        brightnessctl set 5%+ >/dev/null
    else
        local min_val=$(( $(brightnessctl max) * 5 / 100 ))
        [[ "$min_val" -eq 0 ]] && min_val=1
        brightnessctl set 5%- --min-val="$min_val" >/dev/null
    fi
}

hw_external() {
    local target_percent=$1
    # Harici monitör (ddcutil) ayarı için i2c izni kontrolü (grep yerine bash regex kullandık, daha hızlı)
    if [[ ! " $(groups) " =~ " i2c " ]]; then
        return 1
    fi
    
    # flock -n: Eğer başka bir ddcutil işlemi arka planda sürüyorsa kuyruğa girme, iptal et.
    # Artık +/- yerine direkt laptopun o anki yüzdesini ($target_percent) monitöre eşitliyoruz!
    ( flock -n 9 || exit 1; ddcutil setvcp 10 $target_percent --noverify 2>/dev/null ) 9>"$LOCKFILE" &
}

case "$1" in
    all-up|up)
        hw_laptop "up"
        current_val=$(get_laptop_brightness)
        hw_external "$current_val"
        notify_user "$current_val"
        ;;
    all-down|down)
        hw_laptop "down"
        current_val=$(get_laptop_brightness)
        hw_external "$current_val"
        notify_user "$current_val"
        ;;
    *)
        echo "Kullanım: $0 {all-up|all-down}"
        exit 1
        ;;
esac
