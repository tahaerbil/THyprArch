#!/bin/bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc - Force Kill Window & Background Processes      ║
# ╚══════════════════════════════════════════════════════════╝

# Aktif pencere verilerini JSON olarak al (Hata payını sıfırlar)
window_data=$(hyprctl activewindow -j)
pid=$(echo "$window_data" | jq -r '.pid')
class=$(echo "$window_data" | jq -r '.class')

# Eğer geçerli bir PID yoksa (boş masaüstü vb.) sessizce çık
if [ "$pid" == "null" ] || [ "$pid" -le 0 ]; then
    exit 0
fi

# Kritik sistem bileşenlerini koruma (Yanlışlıkla basarsan sistemi kapatmasın)
if [[ "$class" =~ ^(Hyprland|waybar|swaync|rofi|wofi|KDE)$ ]]; then
    exit 0
fi

# Hyprland'in kendi Process Group ID'sini (PGID) bul
# Hyprland'i yanlışlıkla öldürmemek için bu kontrolü kullanıyoruz.
hypr_pid=$(pgrep -u "$USER" -x Hyprland)
hypr_pgid=$(ps -o pgid= -p "$hypr_pid" | tr -d ' ')
pgid=$(ps -o pgid= -p "$pid" | tr -d ' ')

# 1. Aşama: Süreç Grubu (PGID) üzerinden kökten temizlik
# Eğer süreç bir grubun parçasıysa ve bu grup Hyprland değilse hepsini uçurur.
if [ -n "$pgid" ] && [ "$pgid" != "$hypr_pgid" ] && [ "$pgid" -gt 1 ]; then
    kill -9 -"$pgid" 2>/dev/null
else
    kill -9 "$pid" 2>/dev/null
fi

# 2. Aşama: Class adına göre ek temizlik (Steam vb. çok parçalı yapılar için)
# -i parametresi büyük/küçük harf duyarlılığını kaldırır.
if [ -n "$class" ] && [ "$class" != "null" ]; then
    pkill -9 -i "^${class}$" 2>/dev/null
fi