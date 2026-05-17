---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
terminal = "kitty"
-- fileManager = "thunar"
fileManager = "dolphin"
browser = "zen-browser"
menu = "rofi -show drun"
editor = "kate"
pdfViewer = "okular"

---------------------------------
---- DEFAULT APPS (.desktop) ----
---------------------------------

browserDesktop = "zen.desktop"
fileManagerDesktop = "org.kde.dolphin.desktop"
editorDesktop = "org.kde.kate.desktop"
pdfViewerDesktop = "org.kde.okular.desktop"

hl.on("hyprland.start", function()
    hl.exec_cmd("xdg-mime default " .. browserDesktop .. " x-scheme-handler/http")
    hl.exec_cmd("xdg-mime default " .. browserDesktop .. " x-scheme-handler/https")
    hl.exec_cmd("xdg-mime default " .. fileManagerDesktop .. " inode/directory")
    hl.exec_cmd("xdg-mime default " .. editorDesktop .. " text/plain")
    hl.exec_cmd("xdg-mime default " .. pdfViewerDesktop .. " application/pdf")
end)
