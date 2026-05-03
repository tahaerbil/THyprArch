#!/bin/bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc - Görünüm Ayarları Modülü                       ║
# ║  GTK/QT tema, ikon, font ve cursor ayarları              ║
# ╚══════════════════════════════════════════════════════════╝

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# ── Tema Ayarları ────────────────────────────────────────────

GTK_THEME="catppuccin-mocha-sky-standard+default"
ICON_THEME="Papirus-Dark"
FONT="Noto Sans 11"
CURSOR_THEME="Bibata-Modern-Classic"
CURSOR_SIZE="24"

# ── GTK Ayarlarını Uygula (3.0 + 4.0) ──────────────────────

setup_gtk() {
    local changed=false

    # GTK ayar key-value çiftleri
    declare -A gtk_settings=(
        ["gtk-theme-name"]="$GTK_THEME"
        ["gtk-icon-theme-name"]="$ICON_THEME"
        ["gtk-font-name"]="$FONT"
        ["gtk-application-prefer-dark-theme"]="1"
        ["gtk-cursor-theme-name"]="$CURSOR_THEME"
        ["gtk-cursor-theme-size"]="$CURSOR_SIZE"
    )

    for ver in "gtk-3.0" "gtk-4.0"; do
        local conf_file="$HOME/.config/$ver/settings.ini"
        local ver_changed=false

        ensure_ini_file "$conf_file" "Settings"

        for key in "${!gtk_settings[@]}"; do
            local value="${gtk_settings[$key]}"

            # Zaten doğru değere sahipse atla
            if file_contains "$conf_file" "${key}=${value}"; then
                continue
            fi

            ini_set "$conf_file" "$key" "$value" "Settings"
            ver_changed=true
        done

        if $ver_changed; then
            log_success "$ver ayarları güncellendi"
            changed=true
        else
            log_skip "$ver ayarları"
        fi
    done

    return 0
}

# ── gsettings (dconf) ───────────────────────────────────────

setup_gsettings() {
    if ! command -v gsettings &>/dev/null; then
        log_warning "gsettings bulunamadı, atlanıyor"
        return 0
    fi

    local current_theme
    current_theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")

    local current_cursor
    current_cursor=$(gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null | tr -d "'")

    if [[ "$current_theme" == "$GTK_THEME" ]] && [[ "$current_cursor" == "$CURSOR_THEME" ]]; then
        log_skip "gsettings ayarları"
        return 0
    fi

    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" 2>/dev/null
    gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME" 2>/dev/null
    gsettings set org.gnome.desktop.interface font-name "$FONT" 2>/dev/null
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" 2>/dev/null
    gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME" 2>/dev/null
    gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE" 2>/dev/null

    log_success "gsettings ayarları güncellendi"
}

# ── Qt5ct / Qt6ct Ayarları ──────────────────────────────────

setup_qt() {
    # qt5ct
    local qt5_conf="$HOME/.config/qt5ct/qt5ct.conf"

    if [[ -f "$qt5_conf" ]] && file_contains "$qt5_conf" "icon_theme=$ICON_THEME"; then
        log_skip "qt5ct ayarları"
    else
        ensure_ini_file "$qt5_conf" "Appearance"

        ini_set "$qt5_conf" "icon_theme" "$ICON_THEME" "Appearance"
        ini_set "$qt5_conf" "style" "kvantum-dark" "Appearance"
        ini_set "$qt5_conf" "color_scheme_path" "" "Appearance"
        ini_set "$qt5_conf" "custom_palette" "false" "Appearance"

        # Interface bölümü yoksa ekle
        if ! grep -q "^\[Interface\]" "$qt5_conf" 2>/dev/null; then
            echo -e "\n[Interface]" >> "$qt5_conf"
        fi

        ini_set "$qt5_conf" "cursor_flash_time" "1000" "Interface"
        ini_set "$qt5_conf" "double_click_interval" "400" "Interface"
        ini_set "$qt5_conf" "keyboard_scheme" "2" "Interface"
        ini_set "$qt5_conf" "menus_have_icons" "true" "Interface"
        ini_set "$qt5_conf" "show_shortcuts_in_context_menus" "true" "Interface"
        ini_set "$qt5_conf" "toolbutton_style" "4" "Interface"

        log_success "qt5ct ayarları güncellendi"
    fi

    # qt6ct
    local qt6_conf="$HOME/.config/qt6ct/qt6ct.conf"

    if [[ -f "$qt6_conf" ]] && file_contains "$qt6_conf" "icon_theme=$ICON_THEME"; then
        log_skip "qt6ct ayarları"
    else
        ensure_ini_file "$qt6_conf" "Appearance"

        ini_set "$qt6_conf" "icon_theme" "$ICON_THEME" "Appearance"
        ini_set "$qt6_conf" "style" "kvantum-dark" "Appearance"
        ini_set "$qt6_conf" "color_scheme_path" "" "Appearance"
        ini_set "$qt6_conf" "custom_palette" "false" "Appearance"

        if ! grep -q "^\[Interface\]" "$qt6_conf" 2>/dev/null; then
            echo -e "\n[Interface]" >> "$qt6_conf"
        fi

        ini_set "$qt6_conf" "cursor_flash_time" "1000" "Interface"
        ini_set "$qt6_conf" "double_click_interval" "400" "Interface"
        ini_set "$qt6_conf" "keyboard_scheme" "2" "Interface"
        ini_set "$qt6_conf" "menus_have_icons" "true" "Interface"
        ini_set "$qt6_conf" "show_shortcuts_in_context_menus" "true" "Interface"
        ini_set "$qt6_conf" "toolbutton_style" "4" "Interface"

        log_success "qt6ct ayarları güncellendi"
    fi
}

# ── Ana Akış ─────────────────────────────────────────────────

main() {
    setup_gtk
    setup_gsettings
    setup_qt
}

main
