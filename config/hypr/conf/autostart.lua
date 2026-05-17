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
    "swayosd-server &",
    -- "nm-applet &",
    "/usr/lib/kdeconnectd &",
    
    -- Clipboard Yönetimi
    "wl-paste --type text --watch cliphist store &",
    "wl-paste --type image --watch cliphist store &",
}

hl.on("hyprland.start", function()
    for _, app in ipairs(autostart_apps) do
        hl.exec_cmd(app)
    end
end)