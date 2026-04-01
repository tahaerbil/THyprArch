#!/bin/bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc - Rofi Power Menu Script                        ║
# ╚══════════════════════════════════════════════════════════╝

# Seçenek ikonları (Nerd Fonts gerektirir)
shutdown="  Kapat"
reboot="󰜉  Yeniden Başlat"
lock="  Kilitle"
suspend="󰤄  Uyut"
logout="󰈆  Çıkış"

# Seçenekleri birleştir
options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"

# Temanın yolunu belirle
#THEME="$HOME/.config/rofi/themes/powermenu.rasi"

# Rofi'yi çalıştır ve seçimi al
chosen="$(echo -e "$options" | rofi -dmenu \
    -i \
    -p "Güç Menüsü")"

# Seçime göre işlemi yap
case $chosen in
    "$shutdown")
        systemctl poweroff
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$lock")
        hyprlock
        ;;
    "$suspend")
        hyprlock & sleep 0.1 && systemctl suspend
        ;;
    "$logout")
        hyprctl dispatch exit
        ;;
esac
