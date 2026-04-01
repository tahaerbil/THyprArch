# 🛠️ Script Test ve Geliştirme Takip Dosyası

Bu belge, projedeki scriptlerin mevcut durumunu, tespit edilen hataları ve yapılması gereken düzeltmeleri not almak için oluşturulmuştur.

## 📋 Durum Sembolleri
- 🟢 **Çalışıyor**: Hiçbir sorun yok, beklenen işlevi tam olarak yerine getiriyor.
- 🟡 **Kısmen Çalışıyor / Ufak Sorunlar**: Temel işlev çalışıyor ama iyileştirilmesi gereken yerler veya ufak bug'lar var.
- 🔴 **Hatalı / Çalışmıyor**: Script beklenen işlevi yerine getirmiyor, hata verip kapanıyor veya istenmeyen sonuçlar doğuruyor.
- ⚪ **Test Edilmedi**: Henüz test edilip onaylanmadı.

---

## 📂 Ana Kurulum Scriptleri

### `install.sh` (Ana Yükleyici)
- **Durum:** ⚪ Test Edilmedi
- **Notlar:** 
- **Yapılacaklar:** 

### `scripts/pacman.sh`
- **Durum:** 🟢 Çalışıyor
- **Notlar:** Test edildi, ayarları sorunsuz uyguluyor. Mevcut ayarlar zaten yapılmışsa işlem yapmadan atlıyor.
- **Yapılacaklar:** Şimdilik bir şey yok.

### `scripts/packages.sh`
- **Durum:** 🟢 Çalışıyor
- **Notlar:** Test edildi, gerekli paketlerin kurulumu sorunsuz çalışıyor.
- **Yapılacaklar:** Şimdilik bir şey yok.

### `scripts/user-dirs.sh`
- **Durum:** 🟢 Çalışıyor
- **Notlar:** Test edildi, kullanıcı dizinlerini sorunsuz bir şekilde oluşturuyor ve `tr_TR` olarak ayarlıyor. Mevcut ayarlar zaten yapılandırılmışsa işlem yapmadan atlıyor.
- **Yapılacaklar:** Şimdilik bir şey yok.

### `scripts/nvidia.sh`
- **Durum:** 🟢 Çalışıyor
- **Notlar:** Test edildi. Türkçe locale kaynaklı GPU algılama hatası düzeltildi. Pacman hook kısmı kullanıcının isteğiyle kaldırıldı.
- **Yapılacaklar:** Şimdilik bir şey yok.

### `scripts/services.sh`
- **Durum:** 🟢 Çalışıyor
- **Notlar:** Test edildi. NetworkManager, bluetooth ve fstrim servislerini başarıyla aktif ediyor. Ayrıca i2c-dev modülü ve i2c grup izinleri (ddcutil için) sorunsuz yapılandırılıyor.
- **Yapılacaklar:** Değişikliklerin aktif olması için bir kez logout/login yapılması önerilir.

### `scripts/dotfiles.sh`
- **Durum:** ⚪ Test Edilmedi
- **Notlar:** 
- **Yapılacaklar:** 

### `scripts/appearance.sh`
- **Durum:** 🟢 Çalışıyor
- **Notlar:** Test edildi, temalar, ikonlar, font ayarları ve GTK yapılandırması sorunsuz.
- **Yapılacaklar:** Şimdilik bir şey yok.

### `scripts/utils.sh`
- **Durum:** 🟢 Çalışıyor
- **Notlar:** Test edildi. Yedekleme (`backup_file`) işlemleri için sudo yetkisi düzeltildi, sorunsuz çalışıyor.
- **Yapılacaklar:** Şimdilik bir şey yok.

### `scripts/locale.sh`
- **Durum:** 🟢 Çalışıyor
- **Notlar:** Yeni eklendi ve test edildi. `en_US.UTF-8` dilini `#` sembolünü güvenli şekilde kaldırarak başarıyla aktif ediyor.
- **Yapılacaklar:** Şimdilik bir şey yok.

### `scripts/shell.sh`
- **Durum:** ⚪ Test Edilmedi
- **Notlar:** Zsh, Oh My Zsh ve eklentilerin kurulumunu gerçekleştiriyor. Katı hata kontrolleri ve güvenli kurulum akışı eklendi.
- **Yapılacaklar:** Sistem üzerinde sıfırdan test edilecek.

---

## 📂 Konfigürasyon Scriptleri (Çalışma Zamanı)

### `config/waybar/deploy.sh`
- **Durum:** 🟢 Çalışıyor
- **Notlar:** Waybar konfigürasyonu başarıyla uygulandı ve yeniden başlatıldı.
- **Yapılacaklar:** Şimdilik bir şey yok.

### `config/hypr/deploy.sh`
- **Durum:** 🟢 Çalışıyor
- **Notlar:** Hyprland konfigürasyonu uygulandı ve klavye kısayolu düzeltildi.
- **Yapılacaklar:** Şimdilik bir şey yok.

### `config/hypr/scripts/screenshot.sh`
- **Durum:** 🟡 Kısmen Çalışıyor
- **Notlar:** Script tetikleniyor ve çalışıyor, ancak ekran görüntüsü alınırken ekran (freeze) donmuyor. 
- **Yapılacaklar:** Ekran dondurma (freeze) özelliği eklenecek/düzeltilecek.

### `config/hypr/scripts/theme-switch.sh`
- **Durum:** ⚪ Test Edilmedi
- **Notlar:** 
- **Yapılacaklar:** 

### `config/hypr/scripts/brightness.sh`
- **Durum:** 🟢 Çalışıyor
- **Notlar:** Hem laptop (brightnessctl) hem de harici monitör (ddcutil) için senkronize kontrol sağlıyor. `flock` ile I2C çakışmaları önlendi, %5 alt sınır koruması ve hassas yüzde hesaplama eklendi.
- **Yapılacaklar:** Şimdilik bir şey yok.

### `config/hypr/scripts/volume.sh`
- **Durum:** 🟢 Çalışıyor
- **Notlar:** Ses seviyesi kontrolü ve OSD bildirimleri sorunsuz çalışıyor.
- **Yapılacaklar:** Şimdilik bir şey yok.
---
*Not: Bu dosya testler yapıldıkça güncellenecektir.*
