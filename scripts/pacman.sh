#!/bin/bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc - Pacman Yapılandırma Modülü                    ║
# ╚══════════════════════════════════════════════════════════╝

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

PACMAN_CONF="/etc/pacman.conf"

# ── 1. Color aktifleştir ─────────────────────────────────────

setup_color() {
    # Zaten aktifse atla (# olmadan "Color" satırı varsa)
    if grep -q "^Color" "$PACMAN_CONF"; then
        log_skip "Pacman Color"
        return 0
    fi

    # Yorum satırı olarak varsa aktifleştir
    if grep -q "^#Color" "$PACMAN_CONF"; then
        backup_file "$PACMAN_CONF"
        sudo sed -i 's/^#Color/Color/' "$PACMAN_CONF"
        if [[ $? -eq 0 ]]; then
            log_success "Pacman Color aktifleştirildi"
        else
            log_error "Pacman Color aktifleştirilemedi!"
            return 1
        fi
    else
        log_warning "pacman.conf'da Color satırı bulunamadı"
    fi
}

# ── 2. multilib reposu aktifleştir ───────────────────────────

setup_multilib() {
    # Zaten aktifse atla (# olmadan "[multilib]" satırı varsa)
    if grep -q "^\[multilib\]" "$PACMAN_CONF"; then
        log_skip "Pacman multilib"
        return 0
    fi

    # Yorum satırı olarak varsa aktifleştir ([multilib] ve altındaki Include satırı)
    if grep -q "^#\[multilib\]" "$PACMAN_CONF"; then
        backup_file "$PACMAN_CONF"
        sudo sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//}' "$PACMAN_CONF"
        if [[ $? -eq 0 ]]; then
            log_success "Pacman multilib reposu aktifleştirildi"

            # Paket veritabanını güncelle
            log_info "Paket veritabanı güncelleniyor..."
            sudo pacman -Sy
        else
            log_error "Pacman multilib aktifleştirilemedi!"
            return 1
        fi
    else
        log_warning "pacman.conf'da [multilib] satırı bulunamadı"
    fi
}

# ── Ana Akış ─────────────────────────────────────────────────

main() {
    if [[ ! -f "$PACMAN_CONF" ]]; then
        log_error "pacman.conf bulunamadı: $PACMAN_CONF"
        return 1
    fi

    ensure_root_warn
    setup_color
    setup_multilib
}

main
