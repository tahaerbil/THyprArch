#!/bin/bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc - NVIDIA Ayarları Modülü                        ║
# ╚══════════════════════════════════════════════════════════╝

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# ── 1. NVIDIA GPU Tespiti ────────────────────────────────────

detect_nvidia() {
    # Hata çıktılarını (/dev/null) gizle ve grep'i İngilizce locale'de çalıştır (Türkçe "i" ve "I" harf problemi için)
    if LC_ALL=C lspci -nnk 2>/dev/null | LC_ALL=C grep -i "vga\|3d\|display" | LC_ALL=C grep -iq "nvidia"; then
        return 0
    else
        return 1
    fi
}

# ── 2. NVIDIA Paket Kurulumu ─────────────────────────────────

NVIDIA_PAKETLER=(
    nvidia-open-dkms
    nvidia-utils
    lib32-nvidia-utils
)

install_nvidia_packages() {
    local eksik=""

    for paket in "${NVIDIA_PAKETLER[@]}"; do
        if ! is_installed "$paket"; then
            eksik="$eksik $paket"
        fi
    done

    if [[ -z "$eksik" ]]; then
        log_skip "NVIDIA sürücüleri → Tümü kurulu"
        return 0
    fi

    echo -e "  ${RED}✘${NC}  ${BOLD}NVIDIA Sürücüleri${NC} → Eksik:${YELLOW}$eksik${NC}"

    if ask_confirm "NVIDIA sürücüleri kurulsun mu?"; then
        local noconfirm_flag=""
        if [[ "$AUTO_MODE" == "true" ]]; then
            noconfirm_flag="--noconfirm"
        fi

        sudo pacman -S --needed $noconfirm_flag $eksik
        if [[ $? -eq 0 ]]; then
            log_success "NVIDIA sürücüleri kuruldu"
        else
            log_error "NVIDIA sürücü kurulumu başarısız!"
            return 1
        fi
    fi
}

# ── 3. GRUB NVIDIA kernel parametreleri ──────────────────────

NVIDIA_PARAMS=("nvidia_drm.modeset=1" "nvidia_drm.fbdev=1")

setup_grub() {
    local grub_conf="/etc/default/grub"

    if [[ ! -f "$grub_conf" ]]; then
        log_error "GRUB config bulunamadı: $grub_conf"
        return 1
    fi

    # Mevcut GRUB_CMDLINE_LINUX_DEFAULT satırını al
    local current_line
    current_line=$(grep "^GRUB_CMDLINE_LINUX_DEFAULT=" "$grub_conf")

    local needs_update=false
    for param in "${NVIDIA_PARAMS[@]}"; do
        if ! echo "$current_line" | grep -q "$param"; then
            needs_update=true
            break
        fi
    done

    if [[ "$needs_update" == "false" ]]; then
        log_skip "GRUB NVIDIA parametreleri"
        return 0
    fi

    if ask_confirm "GRUB'a NVIDIA parametreleri eklensin mi?"; then
        backup_file "$grub_conf"

        # Mevcut parametreleri al (tırnak içini çıkar)
        local current_params
        current_params=$(echo "$current_line" | sed 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/\1/')

        # Eksik parametreleri ekle
        for param in "${NVIDIA_PARAMS[@]}"; do
            if ! echo "$current_params" | grep -q "$param"; then
                current_params="$current_params $param"
            fi
        done

        # Baştaki/sondaki boşlukları temizle
        current_params=$(echo "$current_params" | xargs)

        sudo sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"$current_params\"/" "$grub_conf"
        if [[ $? -ne 0 ]]; then
            log_error "GRUB dosyası düzenlenemedi! Yetki sorunu olabilir."
            return 1
        fi
        log_success "GRUB parametreleri güncellendi: $current_params"

        # GRUB config'i yeniden oluştur
        log_info "GRUB config yeniden oluşturuluyor..."
        sudo grub-mkconfig -o /boot/grub/grub.cfg
        if [[ $? -eq 0 ]]; then
            log_success "GRUB config güncellendi"
        else
            log_error "GRUB config güncellenemedi!"
            return 1
        fi
    fi
}

# ── 4. mkinitcpio MODULES ayarı ──────────────────────────────

setup_mkinitcpio() {
    local conf="/etc/mkinitcpio.conf"
    local nvidia_modules="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
    local needs_update=false

    if [[ ! -f "$conf" ]]; then
        log_error "mkinitcpio.conf bulunamadı: $conf"
        return 1
    fi

    # MODULES satırında nvidia modülleri var mı kontrol et
    for mod in $nvidia_modules; do
        if ! grep -q "MODULES=.*$mod" "$conf"; then
            needs_update=true
            break
        fi
    done

    if [[ "$needs_update" == "false" ]]; then
        log_skip "mkinitcpio NVIDIA modülleri"
        return 0
    fi

    if ask_confirm "mkinitcpio.conf'a NVIDIA modülleri eklensin mi?"; then
        backup_file "$conf"

        # Mevcut MODULES satırını al
        local current_modules
        current_modules=$(grep "^MODULES=" "$conf" | sed 's/MODULES=(\(.*\))/\1/')

        # NVIDIA modüllerini ekle (zaten varsa ekleme)
        local new_modules="$current_modules"
        for mod in $nvidia_modules; do
            if ! echo "$new_modules" | grep -qw "$mod"; then
                new_modules="$new_modules $mod"
            fi
        done

        # Baştaki/sondaki boşlukları temizle
        new_modules=$(echo "$new_modules" | xargs)

        sudo sed -i "s/^MODULES=.*/MODULES=($new_modules)/" "$conf"
        log_success "mkinitcpio MODULES güncellendi: ($new_modules)"

        # initramfs'i yeniden oluştur
        log_info "initramfs yeniden oluşturuluyor..."
        sudo mkinitcpio -P
        if [[ $? -eq 0 ]]; then
            log_success "initramfs yeniden oluşturuldu"
        else
            log_error "initramfs oluşturma başarısız!"
            return 1
        fi
    fi
}


# ── Ana Akış ─────────────────────────────────────────────────

main() {
    # 1. Önce GPU tespiti
    if ! detect_nvidia; then
        log_warning "NVIDIA ekran kartı tespit edilemedi. Bu modül atlanıyor."
        return 0
    fi

    log_success "NVIDIA ekran kartı tespit edildi"
    ensure_root_warn

    # 2. Sürücü paketleri
    install_nvidia_packages

    # 3. Yapılandırma
    setup_grub
    setup_mkinitcpio
}

main
