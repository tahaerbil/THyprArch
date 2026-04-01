#!/bin/bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc - Locale (Dil/Bölge) Ayarları Modülü            ║
# ╚══════════════════════════════════════════════════════════╝

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# ── 1. Locale Ayarları ───────────────────────────────────────

setup_locales() {
    local locale_file="/etc/locale.gen"
    local target_locale="en_US.UTF-8 UTF-8"

    if [[ ! -f "$locale_file" ]]; then
        log_error "locale.gen dosyası bulunamadı: $locale_file"
        return 1
    fi

    # Zaten başındaki # kaldırılmışsa atla
    if grep -q "^${target_locale}" "$locale_file"; then
        log_skip "İngilizce (en_US.UTF-8) dil desteği → Zaten aktif"
        return 0
    fi

    echo -e "  ${YELLOW}⚠${NC}  İngilizce (en_US.UTF-8) dil desteği kapalı görünüyor."

    if ask_confirm "İngilizce (en_US.UTF-8) dil desteği aktif edilsin mi? (Önerilir)"; then
        backup_file "$locale_file"
        
        # Sed ile başındaki # karakterini kaldır
        sudo sed -i "s/^#\s*${target_locale}/${target_locale}/" "$locale_file"
        
        if [[ $? -eq 0 ]]; then
            log_success "$locale_file güncellendi"
            
            log_info "Yerel ayarlar yeniden oluşturuluyor (locale-gen)..."
            sudo locale-gen
            
            if [[ $? -eq 0 ]]; then
                log_success "Yerel ayarlar başarıyla oluşturuldu"
            else
                log_error "locale-gen çalıştırılırken sorun oluştu!"
                return 1
            fi
        else
            log_error "Dosya düzenlenemedi! Yetki sorunu olabilir."
            return 1
        fi
    fi
}

main() {
    ensure_root_warn
    setup_locales
}

main
