----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        -- Görünüm (Premium ve Temiz bir his için varsayılan logoları kapatıyoruz)
        disable_hyprland_logo   = true,  -- Anime kızı / Hyprland logosunu kapatır
        force_default_wallpaper = 0,     -- Kendi wallpaper script'imiz olduğu için varsayılanları sıfırlıyoruz
        
        -- Performans ve Pil Tasarrufu ayarları Hyprland'in yeni sürümlerinde 'render' bloğuna taşındığı için buradan kaldırıldı.
        
        -- Pencere ve Kullanıcı Deneyimi (UX)
        focus_on_activate = true,        -- Arka planda bir uygulama odak istediğinde (örn: Discord'dan linke tıklayınca Tarayıcı) ona zıpla
        animate_manual_resizes = true,   -- Pencereleri mouse ile elle büyütüp küçültürken çok akıcı/pürüzsüz animasyon
        animate_mouse_windowdragging = true, -- Pencereleri mouse ile sürüklerken akıcı/yumuşak animasyon
        
        -- Ekran Uyku Yönetimi (DPMS)
        mouse_move_enables_dpms = true,  -- Ekran uyku modundayken mouse'u oynatınca ekran anında uyansın
        key_press_enables_dpms = true,   -- Ekran uyku modundayken klavyeye basınca ekran anında uyansın
    },
})
