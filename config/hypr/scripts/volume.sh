#!/bin/bash

# Ses OSD (On Screen Display) Scripti
# wpctl ile sesi ayarlar ve notify-send ile ekranda gösterge çıkarır

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
    # PipeWire/WirePlumber gecikmesini önlemek için status'ü SADECE BİR KERE alıyoruz
    local status=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

    # Swaync/Mako için progress bar ekler (-h int:value). Ayrıca geçmişe kaydedilmemesi için transient flag'i eklendi.
    if [[ "$status" == *MUTED* ]]; then
        notify-send -h int:transient:1 -h string:x-canonical-private-synchronous:sys-notify -u low -i "audio-volume-muted" "Volume Muted" "Muted"
    else
        # "Volume: 0.45" çıktısındaki ikinci sütunu (0.45) alıp 100 ile çarpıyoruz
        local current_val=$(echo "$status" | awk '{print int($2 * 100)}')
        local icon_name=$(get_icon "$current_val")
        
        # Bildirimi arka planda asenkron gönder (&) ki script anında sonlansın, gecikme hissettirmesin
        notify-send -h int:transient:1 -h string:x-canonical-private-synchronous:sys-notify -u low -i "$icon_name" -h int:value:"$current_val" "Volume: ${current_val}%" "" &
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
