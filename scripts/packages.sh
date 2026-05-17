#!/bin/bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc - Düzenli Paket Kurulumu Modülü                 ║
# ╚══════════════════════════════════════════════════════════╝

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# ── Paket Listeleri (Alt Alta Düzen) ─────────────────────────

declare -A KATEGORILER

# Kernel Headerları - Dinamik Tespit
header_listesi=()
for kernel in "linux" "linux-lts" "linux-zen" "linux-hardened"; do
    is_installed "$kernel" && header_listesi+=("${kernel}-headers")
done
[[ ${#header_listesi[@]} -gt 0 ]] && KATEGORILER["Kernel Headerları"]="${header_listesi[*]}"

KATEGORILER["Hyprland"]=$(cat <<-EOF
    hyprland
    xorg-xwayland
    kitty
    waybar
    rofi
    rofi-calc
    rofimoji
    qt5-wayland
    qt6-wayland
    polkit-kde-agent
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
EOF
)

KATEGORILER["Dosya Yönetimi"]=$(cat <<-EOF
    thunar
    thunar-volman
    thunar-archive-plugin
    tumbler
    gvfs
    gvfs-mtp
    gvfs-gphoto2
    sshfs
    yazi
EOF
)

KATEGORILER["Araçlar"]=$(cat <<-EOF
    hyprlock
    hypridle
    wl-clipboard
    cliphist
    grim
    slurp
    satty
    awww
    brightnessctl
    pavucontrol
    swaync
    swayosd
    jq
    qt6-multimedia-ffmpeg
    kdeconnect
    hyprsunset
    bitwarden
    ollama-cuda
    neovim
    okular
    gwenview
    vlc
EOF
)

KATEGORILER["Geliştirme"]=$(cat <<-EOF
    nodejs
    npm
    typescript
    rust
    cargo
    rust-analyzer
    rust-src
EOF
)


KATEGORILER["AUR"]=$(cat <<-EOF
    zen-browser-bin
    catppuccin-gtk-theme-mocha
    bibata-cursor-theme
    wayfreeze-git
    vscodium-bin
    kvantum-theme-catppuccin-git
EOF
)

KATEGORILER["Görünüm"]=$(cat <<-EOF
    nwg-look
    gtk4
    qt5ct
    qt6ct
    kvantum
    kvantum-qt5
    papirus-icon-theme
EOF
)

KATEGORILER["Fontlar"]=$(cat <<-EOF
    ttf-jetbrains-mono-nerd
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra
    ttf-liberation
    woff2-font-awesome
EOF
)

KATEGORILER["Oyun"]=$(cat <<-EOF
    steam
    vulkan-tools
    vulkan-icd-loader
    lib32-vulkan-icd-loader
    lib32-fontconfig
    lib32-pango
    lib32-nss
    lib32-libxft
EOF
)

KATEGORILER["Sistem"]=$(cat <<-EOF
    timeshift
    btop
    fastfetch
    bluez
    bluez-utils
    blueman
    nm-connection-editor
    pipewire
    pipewire-alsa
    pipewire-pulse
    pipewire-jack
    wireplumber
    xdg-user-dirs
    pacman-contrib
    ddcutil
    tailscale
    networkmanager
    power-profiles-daemon
    flatpak
    sddm
EOF
)

KATEGORILER["Flatpak"]=$(cat <<-EOF
    app.fluxer.Fluxer
EOF
)

# Kurulum Sırası
SIRA=(
    "Kernel Headerları"
    "Sistem"
    "Hyprland"
    "Dosya Yönetimi"
    "Araçlar"
    "Geliştirme"
    "Görünüm"
    "Fontlar"
    "Oyun"
    "AUR"
    "Flatpak"
)

# ── Fonksiyonlar ─────────────────────────────────────────────

install_yay() {
    if command -v yay &>/dev/null; then return 0; fi
    log_info "yay kuruluyor..."
    sudo pacman -S --needed --noconfirm git base-devel || return 1
    local tmp_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay" && \
    (cd "$tmp_dir/yay" && makepkg -si --noconfirm)
    rm -rf "$tmp_dir"
}

# ── Ana Akış ─────────────────────────────────────────────────

main() {
    declare -A EKSIK_PAKETLER
    local noconfirm_flag=""
    [[ "$AUTO_MODE" == "true" ]] && noconfirm_flag="--noconfirm"

    if [[ $EUID -eq 0 ]]; then
        log_error "Root ile çalıştırılamaz!"
        exit 1
    fi

    log_info "Paketler taranıyor..."

    for kategori in "${SIRA[@]}"; do
        [[ -z "${KATEGORILER[$kategori]}" ]] && continue
        
        local eksik_dizisi=()
        for paket in ${KATEGORILER[$kategori]}; do
            if [[ "$kategori" == "Flatpak" ]]; then
                ! is_flatpak_installed "$paket" && eksik_dizisi+=("$paket")
            else
                ! is_installed "$paket" && eksik_dizisi+=("$paket")
            fi
        done

        if [[ ${#eksik_dizisi[@]} -gt 0 ]]; then
            echo -e "  ${RED}➜${NC} ${BOLD}$kategori:${NC} ${YELLOW}${eksik_dizisi[*]}${NC}"
            EKSIK_PAKETLER["$kategori"]="${eksik_dizisi[*]}"
        else
            log_skip "$kategori: Tamam"
        fi
    done

    [[ ${#EKSIK_PAKETLER[@]} -eq 0 ]] && { log_success "Her şey kurulu!"; exit 0; }

    ask_confirm "Eksik paketleri kurmak ister misin?" || exit 0

    for kategori in "${SIRA[@]}"; do
        local eksik="${EKSIK_PAKETLER[$kategori]}"
        [[ -z "$eksik" ]] && continue

        log_info "Kurulum: $kategori"

        case "$kategori" in
            "AUR") install_yay && yay -S --needed $noconfirm_flag $eksik ;;
            "Flatpak")
                command -v flatpak &>/dev/null || sudo pacman -S --needed $noconfirm_flag flatpak
                flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                flatpak install --user $noconfirm_flag flathub $eksik
                ;;
            *) sudo pacman -S --needed $noconfirm_flag $eksik ;;
        esac

        if [[ $? -ne 0 ]]; then
            log_error "$kategori başarısız!"
            ask_confirm "Devam edilsin mi?" || exit 1
        fi
    done

    log_success "İşlem tamamlandı!"
}

main "$@"