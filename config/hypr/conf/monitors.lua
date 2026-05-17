------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/


-- Laptop ekranı her zaman en yüksekte kalsın
hl.monitor({
    output   = "eDP-1",
    mode     = "highres@high",
    position = "0x0",
    scale    = 1,
})

-- Harici monitör (hangisi takılırsa takılsın) en yüksekte çalışsın
hl.monitor({
    output   = "DP-1",
    mode     = "highres@high",
    position = "1920x0",
    scale    = 1,
})
