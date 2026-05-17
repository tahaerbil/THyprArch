---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout = "tr",
        numlock_by_default = true,
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",

        repeat_rate = 50,
        repeat_delay = 300,

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        -- Orta tık basılı tutularak fare hareketi ile sayfa kaydırmayı aktifleştir
        scroll_method = "on_button_down",
        scroll_button = 274, -- Orta tuşun Linux'taki varsayılan donanım kodu

        touchpad = {
            natural_scroll = true
        }
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5
})