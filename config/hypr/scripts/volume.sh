#!/bin/bash

# Ses OSD (On Screen Display) Scripti
# wpctl ile sesi ayarlar ve notify-send ile ekranda gösterge çıkarır

get_volume() {
    # wpctl status'ten o anki master ses yüzdesini çek, örn: 0.45 -> 45
    vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o '[0-9.]*' | awk '{print int($1 * 100)}')
    echo "$vol"
}

get_icon() {
    local current_val=$1
    if [ "$current_val" -eq 0 ]; then
        echo "audio-volume-muted"
    elif [ "$current_val" -lt 30 ]; then
        echo "audio-volume-low"
    elif [ "$current_val" -lt 70 ]; then
        echo "audio-volume-medium"
    else
        echo "audio-volume-high"
    fi
}

notify_user() {
    local current_val=$(get_volume)
    local is_muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -i 'MUTED')

    # Swaync/Mako için progress bar ekler (-h int:value). Ayrıca geçmişe kaydedilmemesi için transient flag'i eklendi.
    if [ -n "$is_muted" ]; then
        notify-send -h int:transient:1 -h string:x-canonical-private-synchronous:sys-notify -u low -i "audio-volume-muted" "Volume Muted" "Muted"
    else
        local icon_name=$(get_icon "$current_val")
        notify-send -h int:transient:1 -h string:x-canonical-private-synchronous:sys-notify -u low -i "$icon_name" -h int:value:"$current_val" "Volume: ${current_val}%" ""
    fi
}

case "$1" in
    (up)
        # Sesi maksimum %150'ye kadar arttırıyor (limit optional)
        wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
        notify_user
        ;;
    (down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        notify_user
        ;;
    (mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        notify_user
        ;;
    (*)
        echo "Kullanım: $0 {up|down|mute}"
        exit 1
        ;;
esac
