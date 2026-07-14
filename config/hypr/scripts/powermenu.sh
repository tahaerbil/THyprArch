#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc - Akıllı Rofi Power Menu Script                 ║
# ╚══════════════════════════════════════════════════════════╝

# Seçenek ikonları (Nerd Fonts gerektirir)
shutdown="  Kapat"
reboot="󰜉  Yeniden Başlat"
lock="  Kilitle"
suspend="󰤄  Uyut"
logout="󰈆  Çıkış"
divider="────────────────"
prof_perf="󰓅  Performans Modu"
prof_bal="󰾆  Dengeli Mod"
prof_save="󰒋  Güç Tasarrufu Modu"

# Türk Kahvesi Modu Kontrolü (Caffeine)
if pgrep -x "hypridle" > /dev/null; then
    cafe="  Türk Kahvesi Modu: Pasif"
else
    cafe="  Türk Kahvesi Modu: Aktif"
fi

# Seçenekleri birleştir
options="$shutdown\n$reboot\n$lock\n$suspend\n$logout\n$divider\n$prof_perf\n$prof_bal\n$prof_save\n$cafe"

# Rofi'yi çalıştır ve seçimi al (Yeni Avant-Garde temamızı kullanıyoruz)
chosen="$(echo -e "$options" | rofi -dmenu \
    -i \
    -theme ~/.config/rofi/themes/launcher.rasi \
    -p "Sistem:")"

# Eğer seçim yapılmadan ESC ile çıkılırsa hemen scripti sonlandır
[[ -z "$chosen" || "$chosen" == "$divider" ]] && exit 0

# KRİTİK DÜZELTME: Rofi penceresinin ekrandan "görsel olarak" tamamen silinmesi için 0.4 saniye bekliyoruz.
sleep 0.4

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
        hyprlock & sleep 1 && systemctl suspend
        ;;
    "$logout")
        command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'
        ;;
    "$prof_perf")
        powerprofilesctl set performance
        notify-send -h string:x-canonical-private-synchronous:sys-notify -u normal -i "power-profile-performance" "Sistem" "Performans moduna geçildi."
        ;;
    "$prof_bal")
        powerprofilesctl set balanced
        notify-send -h string:x-canonical-private-synchronous:sys-notify -u normal -i "power-profile-balanced" "Sistem" "Dengeli moda geçildi."
        ;;
    "$prof_save")
        powerprofilesctl set power-saver
        notify-send -h string:x-canonical-private-synchronous:sys-notify -u normal -i "power-profile-power-saver" "Sistem" "Güç tasarrufu moduna geçildi."
        ;;
    *"Türk Kahvesi Modu: Pasif"*)
        killall hypridle
        notify-send -h string:x-canonical-private-synchronous:sys-notify -u normal -i "coffee" "Türk Kahvesi Modu" "Kahveniz hazır! Ekran kararmayacak ve kilitlenmeyecek. ☕"
        ;;
    *"Türk Kahvesi Modu: Aktif"*)
        hypridle &
        notify-send -h string:x-canonical-private-synchronous:sys-notify -u normal -i "hypridle" "Türk Kahvesi Modu" "Kahve bitti! Ekran koruyucu ve kilit tekrar aktif. 💤"
        ;;
esac
