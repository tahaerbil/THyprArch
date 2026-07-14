#!/bin/bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc - Locale (Dil/Bölge) Ayarları Modülü            ║
# ╚══════════════════════════════════════════════════════════╝

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# ── 1. Locale Ayarları ───────────────────────────────────────

setup_locales() {
    local locale_file="/etc/locale.gen"
    local targets=("en_US.UTF-8 UTF-8" "tr_TR.UTF-8 UTF-8")
    local names=("İngilizce (en_US.UTF-8)" "Türkçe (tr_TR.UTF-8)")
    local needs_update=false
    local needs_gen=false

    if [[ ! -f "$locale_file" ]]; then
        log_error "locale.gen dosyası bulunamadı: $locale_file"
        return 1
    fi

    for i in "${!targets[@]}"; do
        local target="${targets[$i]}"
        local name="${names[$i]}"

        # Zaten başındaki # kaldırılmışsa atla
        if grep -q "^${target}" "$locale_file"; then
            log_skip "$name dil desteği → Zaten aktif"
        else
            needs_update=true
        fi
    done

    if [[ "$needs_update" == "false" ]]; then
        return 0
    fi

    if ask_confirm "Gerekli dil paketleri (İngilizce & Türkçe) aktif edilsin mi? (Önerilir)"; then
        backup_file "$locale_file"
        
        for i in "${!targets[@]}"; do
            local target="${targets[$i]}"
            local name="${names[$i]}"

            if ! grep -q "^${target}" "$locale_file"; then
                # Sed ile başındaki # karakterini kaldır (başındaki boşlukları da hesaba katarak)
                if sudo sed -i "s/^#\s*${target}/${target}/" "$locale_file"; then
                    log_success "$name dil desteği etkinleştirildi"
                    needs_gen=true
                else
                    log_error "$name dil desteği etkinleştirilemedi! Yetki sorunu olabilir."
                fi
            fi
        done
        
        if [[ "$needs_gen" == "true" ]]; then
            log_info "Yerel ayarlar yeniden oluşturuluyor (locale-gen)..."
            if sudo locale-gen; then
                log_success "Yerel ayarlar başarıyla oluşturuldu"
            else
                log_error "locale-gen çalıştırılırken sorun oluştu!"
                return 1
            fi
        fi
    fi
}

main() {
    ensure_root_warn
    setup_locales
}

main
