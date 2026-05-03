# thyprsc 🎨

> **Modern, minimal ve yüksek düzeyde modüler Hyprland ekosistemi.**

`thyprsc`, Arch Linux sistemler için tasarlanmış, performansı ve estetiği ön planda tutan bir "post-install" otomasyon ve konfigürasyon projesidir. Sadece bir dotfiles deposu değil, aynı zamanda sisteminizi optimize eden akıllı bir kurulum aracıdır.

---

## 🌟 Öne Çıkan Özellikler

*   **📦 Akıllı Modüler Kurulum:** Pacman optimizasyonundan NVIDIA sürücülerine, Zsh yapılandırmasından servis yönetimine kadar her şeyi seçmeli olarak kurar.
*   **🏝️ 3-Island Waybar:** Modern, şeffaf ve fonksiyonel "üç ada" tasarımı (Workspace, Saat/Tarih, Sistem Durumu).
*   **🔄 Gelişmiş Dotfile Yönetimi:** `dotfiles.sh` motoru ile sistem ve repo arasında `check`, `diff`, `deploy` ve `pull` işlemleriyle tam senkronizasyon.
*   **🎮 Üst Düzey Donanım Kontrolü:** Hem laptop ekranı hem de harici monitörler (DDC/CI) için senkronize parlaklık ve ses yönetimi.
*   **🎨 Dinamik Tema Motoru:** Catppuccin, Nord ve Tokyo Night gibi popüler paletler arasında kolay geçiş desteği.

---

## 📂 Proje Mimarisi

Proje, yönetimi kolaylaştırmak için kesin sınırlarla ayrılmıştır:

| Dizin / Dosya | Açıklama |
| :--- | :--- |
| `scripts/` | **Motor Odası:** Kurulumu ve sistem ayarlarını yöneten modüler scriptler. |
| `config/` | **Görünüm:** `~/.config` altına dağıtılan Hyprland, Waybar, Kitty, Rofi vb. dosyaları. |
| `install.sh` | **Orkestra Şefi:** Tüm kurulum sürecini yöneten interaktif ana panel. |
| `STRUCTURE.md` | **Mimari Kılavuz:** AI ve geliştiriciler için detaylı kod haritası. |

---

## 🚀 Hızlı Başlangıç

Kurulum scripti interaktif bir menü sunar, böylece sadece ihtiyacınız olan modülleri seçebilirsiniz.

```bash
# Depoyu klonlayın
git clone https://github.com/tahaerbil/thyprsc.git
cd thyprsc

# Kurulumu başlatın
chmod +x install.sh
./install.sh
```

> [!TIP]
> Hiçbir soru sormadan tam kurulum yapmak için `./install.sh --auto` komutunu kullanabilirsiniz.

---

## 🛠️ Dotfile Senkronizasyonu

`thyprsc` kendi içinde güçlü bir senkronizasyon motoruyla gelir. Konfigürasyonlarınızı yönetmek için:

*   `./scripts/dotfiles.sh check`: Sistemdeki dosyaların güncelliğini kontrol eder.
*   `./scripts/dotfiles.sh diff`: Repo ile sistem arasındaki kod farklarını gösterir.
*   `./scripts/dotfiles.sh deploy`: Repodaki güncel ayarları sisteme uygular (yedek alarak).
*   `./scripts/dotfiles.sh pull`: Sistemde yaptığınız değişiklikleri repoya aktarır.

---

## 🖼️ Görsel Tasarım

*   **Hyprland:** Minimalist boşluklar, yumuşak animasyonlar ve fonksiyonel pencere kuralları.
*   **Waybar:** 
    *   **Sol:** Aktif iş alanları takibi.
    *   **Orta:** Saat, tarih ve ajanda etkileşimi.
    *   **Sağ:** Parlaklık, ses (farenin tekerleği ile kontrol edilebilir) ve ağ durumu.
*   **Terminal:** Kitty + Zsh (Oh My Zsh & Plugins) ile güçlendirilmiş hızlı ve okunaklı shell deneyimi.

---

## 🤝 Katkıda Bulunun

Hataları bildirmek, yeni özellikler önermek veya tema eklemek için Pull Request açabilir ya da Issue üzerinden iletişime geçebilirsiniz.

---
*Created with ❤️ by **tahaerbil***
