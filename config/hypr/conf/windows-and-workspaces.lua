--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move = "20 monitor_h-120",
    float = true,
})

hl.window_rule({
    name = "float-satty",
    match = { class = "com.gabm.satty" },
    float = true,
})

hl.window_rule({
    name = "float-xdg-gtk",
    match = { class = "xdg-desktop-portal-gtk" },
    float = true,
})

hl.window_rule({
    name = "float-xdg-hyprland",
    match = { class = "xdg-desktop-portal-hyprland" },
    float = true,
})

hl.window_rule({
    name = "float-pavucontrol",
    match = { class = "pavucontrol" },
    float = true,
})

hl.window_rule({
    name = "float-pavucontrol-org",
    match = { class = "org.pulseaudio.pavucontrol" },
    float = true,
})

hl.window_rule({
    name = "float-blueman",
    match = { class = "blueman-manager" },
    float = true,
})

hl.window_rule({
    name = "float-polkit",
    match = { class = "org.kde.polkit-kde-authentication-agent-1" },
    float = true,
})

hl.window_rule({
    name = "float-calculator",
    match = { class = "org.gnome.Calculator" },
    float = true,
})

