#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc - Gece Işığı (Mavi Işık Filtresi) Kontrolü       ║
# ║  hyprsunset aracını kullanır                              ║
# ╚══════════════════════════════════════════════════════════╗

# Ayarlar
TEMP=4000
ICON="night-light-symbolic"

# hyprsunset kurulu mu kontrol et
if ! command -v hyprsunset &> /dev/null; then
    notify-send -u critical "Hata" "hyprsunset bulunamadı! Lütfen scripts/packages.sh üzerinden kurun."
    exit 1
fi

# Geçiş İşlemi (Toggle)
if pgrep -x "hyprsunset" > /dev/null; then
    pkill -x "hyprsunset"
    notify-send -h string:x-canonical-private-synchronous:night-light \
        -u low -i "$ICON" "Gece Işığı" "Kapalı"
else
    hyprsunset --temperature $TEMP &
    notify-send -h string:x-canonical-private-synchronous:night-light \
        -u low -i "$ICON" "Gece Işığı" "Açık ($TEMP K)"
fi
