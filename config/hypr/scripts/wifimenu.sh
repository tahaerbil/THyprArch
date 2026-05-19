#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc - Premium Wi-Fi Menüsü                          ║
# ║  Bağımlılıklar: nmcli, rofi, notify-send                 ║
# ╚══════════════════════════════════════════════════════════╝

set -euo pipefail

THEME="$HOME/.config/rofi/themes/launcher.rasi"
NOTIFY_TAG="string:x-canonical-private-synchronous:wifi-menu"
WIFI_DEV=$(nmcli -t -f DEVICE,TYPE dev | awk -F: '/wifi/{print $1; exit}')

# ── Yardımcı Fonksiyonlar ──────────────────────────────────

get_active_ssid() {
    nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '/^yes:/{print $2}'
}

get_signal_icon() {
    local s="$1"
    if   (( s >= 80 )); then echo "󰤨"
    elif (( s >= 60 )); then echo "󰤥"
    elif (( s >= 40 )); then echo "󰤢"
    elif (( s >= 20 )); then echo "󰤟"
    else                      echo "󰤯"
    fi
}

rofi_menu() {
    rofi -dmenu -theme "$THEME" -i "$@"
}

rofi_confirm() {
    local answer
    answer=$(printf "  Evet\n  Hayır" | rofi_menu -p "$1")
    [[ "$answer" == *"Evet"* ]]
}

notify() {
    notify-send -t "$1" -h "$NOTIFY_TAG" -u "$2" -i "$3" "Wi-Fi" "$4"
}

# ── Wi-Fi Kapalıysa ───────────────────────────────────────

wifi_state=$(nmcli radio wifi)

if [[ "$wifi_state" != "enabled" ]]; then
    chosen=$(printf "󰤨  Wi-Fi Aç" | rofi_menu -p "Wi-Fi Kapalı:")
    if [[ "$chosen" == *"Wi-Fi Aç"* ]]; then
        nmcli radio wifi on
        notify 2000 low network-wireless "Bağdaştırıcı açıldı, ağlar taranıyor..."
        sleep 3
        exec "$0"
    fi
    exit 0
fi

# ── Ağ Taraması ve Veri Toplama ────────────────────────────

nmcli device wifi rescan 2>/dev/null || true

active_ssid=$(get_active_ssid)

# Kayıtlı profil isimleri
declare -A saved_profiles=()
while IFS= read -r name; do
    [[ -n "$name" ]] && saved_profiles["$name"]=1
done < <(nmcli -t -f NAME,TYPE connection show | awk -F: '/802-11-wireless/{print $1}')

# Ağ listesini oku
declare -a ssid_list=()
declare -A signal_map=()
declare -A security_map=()

while IFS=: read -r ssid signal security _; do
    [[ -z "$ssid" || "$ssid" == "--" ]] && continue
    [[ -v "signal_map[$ssid]" ]] && continue

    ssid_list+=("$ssid")
    signal_map["$ssid"]="$signal"
    security_map["$ssid"]="$security"
done < <(nmcli -t -f SSID,SIGNAL,SECURITY device wifi list)

# ── Menü Yapısı ────────────────────────────────────────────
# Üst kısım: Durum + Eylemler
# Alt kısım: Kullanılabilir ağ listesi

menu=""

# ▸ Durum satırı
if [[ -n "$active_ssid" ]]; then
    sig="${signal_map[$active_ssid]:-0}"
    sig_icon=$(get_signal_icon "$sig")
    ip_addr=$(nmcli -t -f IP4.ADDRESS dev show "$WIFI_DEV" 2>/dev/null | head -1 | cut -d: -f2 | cut -d/ -f1)
    speed=$(nmcli -t -f GENERAL.CON-SPEED dev show "$WIFI_DEV" 2>/dev/null | cut -d: -f2)
    # Hızı Mbps'e çevir (nmcli kbit/s verir)
    if [[ -n "$speed" && "$speed" =~ ^[0-9]+$ && "$speed" -gt 0 ]]; then
        speed_mbps=$(( speed / 1000 ))
        status_line="$sig_icon  $active_ssid  │  $ip_addr  │  ${speed_mbps} Mbps  │  %${sig}"
    else
        status_line="$sig_icon  $active_ssid  │  $ip_addr  │  %${sig}"
    fi
    menu+="$status_line\n"
fi

# ▸ Eylemler (her zaman en üstte)
menu+="󰑓  Yeniden Tara\n"
if [[ -n "$active_ssid" ]]; then
    menu+="󰅗  Bağlantıyı Kes ($active_ssid)\n"
fi
menu+="  Kayıtlı Ağı Unut\n"
menu+="󰤭  Wi-Fi Kapat\n"

# ▸ Ayırıcı
menu+="─────────────────────────────\n"

# ▸ Ağ listesi (sinyal gücüne göre zaten sıralı)
for ssid in "${ssid_list[@]}"; do
    [[ "$ssid" == "$active_ssid" ]] && continue

    sig="${signal_map[$ssid]}"
    sec="${security_map[$ssid]}"
    icon=$(get_signal_icon "$sig")

    # Güvenlik ikonu
    if [[ -z "$sec" || "$sec" == "--" ]]; then
        lock="󰌿"
    else
        lock="󰌾"
    fi

    # Kayıtlı ağ işareti
    if [[ -v "saved_profiles[$ssid]" ]]; then
        saved_mark="★"
    else
        saved_mark=" "
    fi

    menu+="$icon  $ssid  $lock $saved_mark\n"
done

# ── Menüyü Göster ─────────────────────────────────────────

chosen=$(echo -e "$menu" | rofi_menu -p "Wi-Fi:")

[[ -z "$chosen" ]] && exit 0

# ── Seçim Yönlendirmesi ───────────────────────────────────

case "$chosen" in

    # Durum satırına tıklandı → detay göster
    *"$active_ssid"*"│"*)
        details=""
        details+="Ağ: $active_ssid\n"
        details+="IP: $(nmcli -t -f IP4.ADDRESS dev show "$WIFI_DEV" 2>/dev/null | head -1 | cut -d: -f2)\n"
        details+="Gateway: $(nmcli -t -f IP4.GATEWAY dev show "$WIFI_DEV" 2>/dev/null | cut -d: -f2)\n"
        details+="DNS: $(nmcli -t -f IP4.DNS dev show "$WIFI_DEV" 2>/dev/null | head -1 | cut -d: -f2)\n"
        details+="MAC: $(nmcli -t -f GENERAL.HWADDR dev show "$WIFI_DEV" 2>/dev/null | cut -d: -f2-)"
        notify 6000 low network-wireless "$(echo -e "$details")"
        ;;

    "─────────────────────────────")
        ;;

    *"Yeniden Tara"*)
        notify 1500 low network-wireless "Ağlar taranıyor..."
        nmcli device wifi rescan 2>/dev/null || true
        sleep 2
        exec "$0"
        ;;

    *"Bağlantıyı Kes"*)
        if rofi_confirm "Bağlantı kesilsin mi?"; then
            nmcli device disconnect "$WIFI_DEV" 2>/dev/null
            notify 2000 low network-wireless-disconnected "$active_ssid bağlantısı kesildi."
        fi
        ;;

    *"Kayıtlı Ağı Unut"*)
        saved_list=$(nmcli -t -f NAME,TYPE connection show | awk -F: '/802-11-wireless/{print $1}')
        if [[ -z "$saved_list" ]]; then
            notify 2000 low network-wireless "Kayıtlı ağ profili bulunamadı."
            exit 0
        fi
        forget=$(echo "$saved_list" | rofi_menu -p "Unutulacak Ağ:")
        if [[ -n "$forget" ]]; then
            if rofi_confirm "\"$forget\" silinsin mi?"; then
                nmcli connection delete "$forget" >/dev/null 2>&1
                notify 2000 low network-wireless "\"$forget\" profili silindi."
            fi
        fi
        ;;

    *"Wi-Fi Kapat"*)
        if rofi_confirm "Wi-Fi kapatılsın mı?"; then
            nmcli radio wifi off
            notify 2000 low network-wireless-disconnected "Bağdaştırıcı kapatıldı."
        fi
        ;;

    *)
        # Ağ seçildi → SSID ayıkla
        # Başındaki sinyal ikonunu ve sonundaki kilit/yıldız sembollerini temizle
        ssid=$(echo "$chosen" | sed 's/^[^ ]* *//' | sed 's/  [󰌾󰌿★ ]*$//' | xargs)

        [[ -z "$ssid" ]] && exit 0

        # Kayıtlı profil var mı?
        if [[ -v "saved_profiles[$ssid]" ]]; then
            notify 2000 low network-wireless "Kayıtlı profille bağlanılıyor: $ssid"
            if nmcli connection up id "$ssid" >/dev/null 2>&1; then
                notify 3000 normal network-wireless "Bağlandı: $ssid"
            else
                notify 3000 critical network-wireless-disconnected "Bağlantı başarısız: $ssid"
            fi
        else
            sec="${security_map[$ssid]:-}"
            if [[ -z "$sec" || "$sec" == "--" ]]; then
                # Açık ağ
                notify 2000 low network-wireless "Açık ağa bağlanılıyor: $ssid"
                if nmcli device wifi connect "$ssid" >/dev/null 2>&1; then
                    notify 3000 normal network-wireless "Bağlandı: $ssid"
                else
                    notify 3000 critical network-wireless-disconnected "Ağa katılınamadı."
                fi
            else
                # Şifreli ağ
                password=$(rofi_menu -p "  $ssid:" -password)
                if [[ -n "$password" ]]; then
                    notify 2000 low network-wireless "Doğrulanıyor: $ssid"
                    if nmcli device wifi connect "$ssid" password "$password" >/dev/null 2>&1; then
                        notify 3000 normal network-wireless "Bağlandı: $ssid"
                    else
                        notify 3000 critical network-wireless-disconnected "Şifre reddedildi veya ağ erişilemez."
                    fi
                fi
            fi
        fi
        ;;
esac
