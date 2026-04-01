#!/usr/bin/env bash
# thyprsc — Yüzen Rofi Wi-Fi Menüsü
# Waybar network modülü üzerinden tetiklenerek şık animasyonlu ağ seçimi sağlar.

# Önce arkaplanda bir Wi-Fi tarama tetikleyelim ki liste güncel olsun
notify-send -t 1500 -h string:x-canonical-private-synchronous:sys-notify -u low -i network-wireless "Wi-Fi Menüsü" "Ağlar taranıyor..."

# nmcli üzerinden SSID, Güvenlik Durumu ve Sinyal Çubuklarını alıp temiz, estetik bir listeye dönüştürüyoruz
list=$(nmcli --fields "SSID,SECURITY,BARS" device wifi list | sed 1d | sed -E "s/WPA*.?\S/ /g" | sed "s/^--/ /g" | sed "s/  //g" | sed "/--/d" | awk '!a[$0]++' | sed 's/^ *//')

toggle_on="󰤨  Wi-Fi Aç"
toggle_off="󰖪  Wi-Fi Kapat"

wifi_state=$(nmcli radio wifi)
if [ "$wifi_state" = "enabled" ]; then
    menu="$toggle_off\n$list"
else
    menu="$toggle_on"
fi

# Rofi arayüzünü aç (-theme-str ile geçici yuvarlatılmış köşeli Avant-Garde görünüm)
chosen=$(echo -e "$menu" | rofi -dmenu -i -p "Ağ Seçin " -theme-str 'window {width: 450px; border-radius: 12px;} listview {lines: 8; scrollbar: false;} element {padding: 8px;}')

# Menü kapatıldıysa (Esc) hiçbir şey yapma
if [ -z "$chosen" ]; then
    exit
fi

if [ "$chosen" = "$toggle_on" ]; then
    nmcli radio wifi on
    notify-send -t 2000 -u low -i network-wireless "Wi-Fi" "Kablosuz ağ bağdaştırıcısı açıldı."
elif [ "$chosen" = "$toggle_off" ]; then
    nmcli radio wifi off
    notify-send -t 2000 -u low -i network-wireless-disconnected "Wi-Fi" "Kablosuz ağ bağdaştırıcısı kapatıldı."
else
    # Boşluklu isimleri bozmamak için kilit () veya açık-kilit () ikonuna kadar olan kısmı al
    ssid=$(echo "$chosen" | sed 's/\( \| \).*//' | xargs)
    
    # Sisteme kaydedilmiş eski bağlantıları denetle
    saved=$(nmcli -g NAME connection)
    if echo "$saved" | grep -qx "$ssid"; then
        notify-send -t 2000 -u low "Bağlanıyor..." "Kayıtlı ağ profili bulundu: $ssid"
        if nmcli connection up id "$ssid" > /dev/null 2>&1; then
            notify-send -t 3000 -u normal -i network-wireless "Wi-Fi Bağlandı" "$ssid ağına başarıyla bağlanıldı!"
        else
            notify-send -t 3000 -u critical -i network-wireless-disconnected "Bağlantı Hatası" "$ssid asılı kaldı veya erişilemiyor."
        fi
    else
        # Ağ simgesi içerisinde  (Açık kilit) varsa şifresiz ağdır
        if [[ "$chosen" == *""* ]]; then
            notify-send -t 2000 -u low "Bağlanıyor..." "$ssid şifresiz ağına giriş yapılıyor."
            if nmcli device wifi connect "$ssid" > /dev/null 2>&1; then
                notify-send -t 3000 -u normal -i network-wireless "Wi-Fi Bağlandı" "Açık ağ bağlantısı başarılı!"
            else
                notify-send -t 3000 -u critical -i network-wireless-disconnected "Hata" "Ağa katılınamadı."
            fi
        else
            # Kilitli bir ağ (), Wi-Fi şifresi penceresini yine zarif rofi ile sor
            password=$(rofi -dmenu -password -p "Şifre ( $ssid )" -theme-str 'window {width: 350px; border-radius: 12px;} login {padding: 10px;}')
            if [ -n "$password" ]; then
                notify-send -t 2000 -u low "Doğrulanıyor..." "$ssid ağı şifresi deneniyor."
                if nmcli device wifi connect "$ssid" password "$password" > /dev/null 2>&1; then
                    notify-send -t 3000 -u normal -i network-wireless "Wi-Fi Bağlandı" "$ssid şifre kabul edildi!"
                else
                    notify-send -t 3000 -u critical -i network-wireless-disconnected "Reddedildi" "Yanlış şifre ya da ağ erişimi koptu."
                fi
            fi
        fi
    fi
fi
