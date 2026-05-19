-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Başlatılacak uygulamaların listesi
local autostart_apps = {
    -- Kritik Sistem Servisleri (Senkron çalışması daha güvenlidir)
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland",
    "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
    
    -- Arka Plan Servisleri (& ile)
    "/usr/lib/polkit-kde-authentication-agent-1 &",
    "awww-daemon &",
    "waybar &",
    "hypridle &",
    "swaync &",
    -- "nm-applet &",
    "/usr/lib/kdeconnectd &",
    
    -- Clipboard Yönetimi (Performans optimizasyonu: Maksimum 50 öğe saklanacak şekilde sınırlandırıldı)
    "wl-paste --type text --watch cliphist -max-items 50 store &",
    "wl-paste --type image --watch cliphist -max-items 50 store &",
}

hl.on("hyprland.start", function()
    for _, app in ipairs(autostart_apps) do
        hl.exec_cmd(app)
    end
end)