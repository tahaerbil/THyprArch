#!/bin/bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc - Kullanıcı Dizinleri Modülü                    ║
# ╚══════════════════════════════════════════════════════════╝

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# ── XDG Kullanıcı Dizinleri ─────────────────────────────────

DIZINLER=(
    "$HOME/Belgeler"
    "$HOME/İndirilenler"
    "$HOME/Müzik"
    "$HOME/Resimler"
    "$HOME/Videolar"
    "$HOME/Masaüstü"
    "$HOME/Şablonlar"
    "$HOME/Genel"
)

# ── Ana Akış ─────────────────────────────────────────────────

main() {
    # xdg-user-dirs kurulu mu kontrol et
    if ! command -v xdg-user-dirs-update &>/dev/null; then
        log_error "xdg-user-dirs kurulu değil! Önce paket kurulumunu çalıştırın."
        return 1
    fi

    # Sistemde tr_TR locale desteği var mı kontrol et
    if ! locale -a 2>/dev/null | grep -qi "tr_TR"; then
        log_warning "Sisteminizde Türkçe ('tr_TR') dil desteği yüklü değil!"
        log_info "Kullanıcı dizinleri varsayılan sistem dilinde yapılandırılıyor..."
        xdg-user-dirs-update
        log_success "XDG kullanıcı dizinleri başarıyla yapılandırıldı."
        return 0
    fi

    local locale_file="$HOME/.config/user-dirs.locale"
    local hedef_locale="tr_TR"

    # 1. Locale ayarını kontrol et ve gerekirse düzelt
    if [[ ! -f "$locale_file" ]] || [[ "$(cat "$locale_file")" != "$hedef_locale" ]]; then
        log_info "Kullanıcı dizinleri dili '$hedef_locale' olarak ayarlanıyor..."
        mkdir -p "$HOME/.config"
        echo "$hedef_locale" > "$locale_file"
        
        # Dil değiştiği için force ile güncelliyoruz
        xdg-user-dirs-update --force
    else
        # Dil zaten doğruysa normal çalıştır 
        # (Eğer dizinler yoksa oluşturur, varsa bir şey yapmaz)
        xdg-user-dirs-update
    fi

    # 2. Dizinleri kontrol et (sadece log amaçlı, oluşturmuyoruz)
    local eksik=0
    for dizin in "${DIZINLER[@]}"; do
        if [[ ! -d "$dizin" ]]; then
            log_error "Dizin bulunamadı: $dizin"
            ((eksik++))
        fi
    done

    if [[ $eksik -eq 0 ]]; then
        log_success "Tüm XDG kullanıcı dizinleri (Türkçe) yapılandırıldı ve mevcut."
    else
        log_warning "Bazı dizinler oluşturulamadı! Lütfen '~/.config/user-dirs.dirs' dosyanızı kontrol edin."
    fi
}

main
