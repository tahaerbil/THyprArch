#!/usr/bin/env bash

# ╔════════════════════════════════════════════════════════════╗
# ║  thyprsc - Akıllı Parlaklık Kontrolü                       ║
# ║  Hem Laptop (brightnessctl) hem Harici (ddcutil) destekler ║
# ╚════════════════════════════════════════════════════════════╝

# Kilit dosyası (DDC/CI bus çakışmalarını önlemek için)
LOCKFILE="/tmp/thyprsc_ddc.lock"

# --- Okuma Fonksiyonları ---

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

get_external_brightness() {
    if ! [ -w /dev/i2c-0 ] && ! groups | grep -q "\bi2c\b"; then
        return
    fi
    local val=$(ddcutil getvcp 10 -t 2>/dev/null | awk '{print $4}')
    [[ "$val" =~ ^[0-9]+$ ]] && echo "$val" || echo ""
}

# --- Görsel Yardımcılar ---

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
    local mode=$1
    (
        local current_val
        local title="Parlaklık"

        if [[ "$mode" == "laptop" ]]; then
            current_val=$(get_laptop_brightness)
            title="Laptop Parlaklığı"
        else
            current_val=$(get_external_brightness)
            title="Harici Monitör"
        fi

        [[ -z "$current_val" ]] && exit 0
        local icon_name=$(get_icon "$current_val")

        notify-send -h int:transient:1 \
            -h string:x-canonical-private-synchronous:brightness-osd \
            -u low -i "$icon_name" -h int:value:"$current_val" "$title: ${current_val}%"
    ) &
}

# --- Donanım İşlemleri ---

hw_laptop() {
    local dir=$1
    if [[ "$dir" == "up" ]]; then
        brightnessctl set 5%+ >/dev/null
    else
        local min_val=$(( $(brightnessctl max) * 5 / 100 ))
        [[ "$min_val" -eq 0 ]] && min_val=1
        brightnessctl set 5%- --min-val="$min_val" >/dev/null
    fi
}

hw_external() {
    local dir=$1
    if ! groups | grep -q "\bi2c\b"; then
        notify-send "Yetki Hatası" "i2c grubunda olmalısınız." -u critical
        return 1
    fi
    local op="+"
    [[ "$dir" == "down" ]] && op="-"
    
    # flock -n: Eğer başka bir ddcutil işlemi varsa bu işlemi iptal et (kuyruğa girmeyi önler)
    ( flock -n 9 || exit 1; ddcutil setvcp 10 $op 10 --noverify 2>/dev/null ) 9>"$LOCKFILE" &
}

# --- Ana Menü ---

case "$1" in
    up)
        hw_laptop "up"
        notify_user "laptop"
        ;;
    down)
        hw_laptop "down"
        notify_user "laptop"
        ;;
    ext-up)
        hw_external "up"
        notify_user "external"
        ;;
    ext-down)
        hw_external "down"
        notify_user "external"
        ;;
    all-up)
        hw_laptop "up"
        hw_external "up"
        notify_user "laptop" # Senkronize bildirim için en hızlı referans
        ;;
    all-down)
        hw_laptop "down"
        hw_external "down"
        notify_user "laptop"
        ;;
    *)
        echo "Kullanım: $0 {up|down|ext-up|ext-down|all-up|all-down}"
        exit 1
        ;;
esac
