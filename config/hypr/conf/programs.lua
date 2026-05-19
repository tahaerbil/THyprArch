---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
terminal = "kitty"
-- fileManager = "thunar"
fileManager = "dolphin"
browser = "zen-browser"
menu = "rofi -show drun -theme ~/.config/rofi/themes/launcher.rasi"
editor = "kate"
pdfViewer = "okular"

---------------------------------
---- DEFAULT APPS (.desktop) ----
---------------------------------

browserDesktop = "zen.desktop"
fileManagerDesktop = "org.kde.dolphin.desktop"
editorDesktop = "org.kde.kate.desktop"
pdfViewerDesktop = "org.kde.okular.desktop"
imageViewerDesktop = "org.kde.gwenview.desktop" -- Görsel görüntüleyici eklendi

hl.on("hyprland.start", function()
    -- Tarayıcı varsayılanları (Sadece linkler değil, inen .html dosyaları için de)
    hl.exec_cmd("xdg-mime default " .. browserDesktop .. " x-scheme-handler/http")
    hl.exec_cmd("xdg-mime default " .. browserDesktop .. " x-scheme-handler/https")
    hl.exec_cmd("xdg-mime default " .. browserDesktop .. " text/html")
    
    -- Dosya ve Metin yöneticisi
    hl.exec_cmd("xdg-mime default " .. fileManagerDesktop .. " inode/directory")
    hl.exec_cmd("xdg-mime default " .. editorDesktop .. " text/plain")
    
    -- Medya ve Belgeler
    hl.exec_cmd("xdg-mime default " .. pdfViewerDesktop .. " application/pdf")
    hl.exec_cmd("xdg-mime default " .. imageViewerDesktop .. " image/jpeg")
    hl.exec_cmd("xdg-mime default " .. imageViewerDesktop .. " image/png")
end)
