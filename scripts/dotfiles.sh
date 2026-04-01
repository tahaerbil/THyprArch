#!/bin/bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc - Dotfile Doğrulama Modülü                      ║
# ║  Config dosyalarını kontrol eder, dağıtır ve senkronlar. ║
# ╚══════════════════════════════════════════════════════════╝

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

CONFIG_SOURCE="$THYPRSC_DIR/config"
CONFIG_TARGET="$HOME/.config"

# ── Yardımcılar ──────────────────────────────────────────────

# Dizinin boş olup olmadığını kontrol eder (.keep hariç)
is_empty_config_dir() {
    local dir="$1"
    local count
    count=$(find "$dir" -not -name '.keep' -not -path "$dir" | wc -l)
    [[ $count -eq 0 ]]
}

# Tek dosya karşılaştırması (0 = aynı, 1 = farklı)
files_match() {
    diff -q "$1" "$2" &>/dev/null
}

# Dizin karşılaştırması (.keep, deploy.sh vb. yoksayarak)
dirs_match() {
    diff -rq --exclude='.keep' --exclude='deploy.sh' --exclude='pull.sh' "$1" "$2" &>/dev/null
}

# Terminal'e mi yazılıyor kontrolü (pipe/dosya güvenliği)
_color_flag() {
    if [[ -t 1 ]]; then
        echo "--color=always"
    else
        echo "--color=never"
    fi
}

# ── Config Tarayıcı ──────────────────────────────────────────
# Tüm modlar aynı dizin+dosya tarama sırasını paylaşır.
# callback fonksiyonuna: tip (dir|file), kaynak yol, isim geçirilir.

iterate_configs() {
    local callback="$1"

    # nullglob ile boş glob'lar boş diziye dönüşür
    local _old_nullglob
    _old_nullglob=$(shopt -p nullglob 2>/dev/null)
    shopt -s nullglob

    # Dizinleri tara
    for item in "$CONFIG_SOURCE"/*/; do
        item="${item%/}"
        local name
        name=$(basename "$item")
        is_empty_config_dir "$item" && { log_skip "$name (boş dizin)"; continue; }
        "$callback" "dir" "$item" "$name"
    done

    # Tek dosyaları tara
    for item in "$CONFIG_SOURCE"/*; do
        [[ -d "$item" ]] && continue
        [[ ! -f "$item" ]] && continue
        local name
        name=$(basename "$item")
        [[ "$name" == ".keep" ]] && continue
        "$callback" "file" "$item" "$name"
    done

    # nullglob'u eski haline getir
    eval "$_old_nullglob"
}

# ── CHECK modu ───────────────────────────────────────────────
# Sadece raporlar, hiçbir şeyi değiştirmez.

_check_item() {
    local tip="$1" kaynak="$2" isim="$3"
    local hedef="$CONFIG_TARGET/$isim"

    if [[ "$tip" == "dir" ]]; then
        if [[ ! -d "$hedef" ]]; then
            log_error "$isim → dosya bulunamadı"
            ((_check_eksik++))
            _check_fark_var=true
            return
        fi
        if dirs_match "$kaynak" "$hedef"; then
            log_success "$isim → eşleşiyor"
            ((_check_eslesen++))
        else
            log_warning "$isim → farklılık var"
            ((_check_farkli++))
            _check_fark_var=true
        fi
    else
        if [[ ! -f "$hedef" ]]; then
            log_error "$isim → dosya bulunamadı"
            ((_check_eksik++))
            _check_fark_var=true
            return
        fi
        if files_match "$kaynak" "$hedef"; then
            log_success "$isim → eşleşiyor"
            ((_check_eslesen++))
        else
            log_warning "$isim → farklılık var"
            ((_check_farkli++))
            _check_fark_var=true
        fi
    fi
}

do_check() {
    print_header "🔍 Dotfile Doğrulama"

    _check_eslesen=0
    _check_farkli=0
    _check_eksik=0
    _check_fark_var=false

    iterate_configs _check_item

    echo ""
    log_info "Doğrulama özeti: $_check_eslesen eşleşen, $_check_farkli farklı, $_check_eksik eksik"

    if $_check_fark_var; then
        log_info "Farklılıkları görmek için: ${BOLD}dotfiles.sh diff${NC}"
        log_info "Config'leri yerleştirmek için: ${BOLD}dotfiles.sh deploy${NC}"
        return 1
    fi

    return 0
}

# ── DIFF modu ────────────────────────────────────────────────
# Farklılıkları detaylı gösterir.

_diff_item() {
    local tip="$1" kaynak="$2" isim="$3"
    local hedef="$CONFIG_TARGET/$isim"
    local cflag
    cflag=$(_color_flag)

    if [[ "$tip" == "dir" ]]; then
        if [[ ! -d "$hedef" ]]; then
            echo -e "\n${BOLD}${RED}── $isim (hedef dizin yok) ──${NC}"
            echo -e "${DIM}Tüm dosyalar eksik. Deploy ile oluşturulabilir.${NC}"
            _diff_bulundu=true
            return
        fi
        local diff_output
        diff_output=$(diff -r --exclude='.keep' --exclude='deploy.sh' --exclude='pull.sh' "$cflag" "$kaynak" "$hedef" 2>/dev/null) || true
        if [[ -n "$diff_output" ]]; then
            echo -e "\n${BOLD}${YELLOW}── $isim ──${NC}"
            echo "$diff_output"
            _diff_bulundu=true
        fi
    else
        if [[ ! -f "$hedef" ]]; then
            echo -e "\n${BOLD}${RED}── $isim (hedef dosya yok) ──${NC}"
            echo -e "${DIM}Dosya eksik. Deploy ile oluşturulabilir.${NC}"
            _diff_bulundu=true
            return
        fi
        local diff_output
        diff_output=$(diff "$cflag" "$kaynak" "$hedef" 2>/dev/null) || true
        if [[ -n "$diff_output" ]]; then
            echo -e "\n${BOLD}${YELLOW}── $isim ──${NC}"
            echo "$diff_output"
            _diff_bulundu=true
        fi
    fi
}

do_diff() {
    print_header "📋 Dotfile Farklılıkları"

    _diff_bulundu=false
    iterate_configs _diff_item

    if ! $_diff_bulundu; then
        echo ""
        log_success "Tüm config dosyaları eşleşiyor. Farklılık yok."
    fi
}

# ── DEPLOY modu ──────────────────────────────────────────────
# Repo'daki config'leri sisteme kopyalar (backup alarak).

_deploy_item() {
    local tip="$1" kaynak="$2" isim="$3"
    local hedef="$CONFIG_TARGET/$isim"

    if [[ "$tip" == "dir" ]]; then
        # Özel deploy script'i kontrolü
        if [[ -f "$kaynak/deploy.sh" ]]; then
            log_info "$isim → özel deploy script'i bulundu, çalıştırılıyor..."
            chmod +x "$kaynak/deploy.sh"
            
            # Özel script'i çalıştır
            if bash "$kaynak/deploy.sh"; then
                log_success "$isim → özel deploy başarılı"
                ((_deploy_basarili++))
            else
                log_error "$isim → özel deploy başarısız"
                ((_deploy_hata++))
            fi
            return
        fi

        # Zaten aynıysa ve force yoksa atla
        if [[ "$_deploy_force" != "true" ]] && [[ -d "$hedef" ]] && dirs_match "$kaynak" "$hedef"; then
            log_skip "$isim → zaten güncel"
            ((_deploy_atlanan++))
            return
        fi
    else
        if [[ "$_deploy_force" != "true" ]] && [[ -f "$hedef" ]] && files_match "$kaynak" "$hedef"; then
            log_skip "$isim → zaten güncel"
            ((_deploy_atlanan++))
            return
        fi
    fi

    # Hedef varsa: symlink ise kaldır, değilse backup al
    if [[ -e "$hedef" ]] || [[ -L "$hedef" ]]; then
        if [[ -L "$hedef" ]]; then
            log_info "$isim → eski symlink kaldırılıyor"
            rm -f "$hedef"
        else
            backup_file "$hedef" || {
                log_error "Yedekleme başarısız, atlanıyor: $isim"
                ((_deploy_hata++))
                return
            }
        fi
    fi

    # Kopyala (symlink değil, gerçek kopya)
    if cp -a "$kaynak" "$hedef"; then
        # Hedef dizinse .keep dosyalarını temizle
        if [[ -d "$hedef" ]]; then
            find "$hedef" -name '.keep' -delete 2>/dev/null
        fi
        log_success "$isim → kopyalandı"
        ((_deploy_basarili++))
    else
        log_error "Kopyalama başarısız: $isim"
        ((_deploy_hata++))
    fi
}

do_deploy() {
    local force_flag="${1:-}"

    print_header "🚀 Dotfile Dağıtım"

    mkdir -p "$CONFIG_TARGET"

    _deploy_basarili=0
    _deploy_atlanan=0
    _deploy_hata=0

    if [[ "$force_flag" == "--force" ]]; then
        _deploy_force=true
        log_info "Force modu aktif — tüm config'ler güncel olsa bile kopyalanacak"
    else
        _deploy_force=false
    fi

    iterate_configs _deploy_item

    echo ""
    log_info "Dağıtım özeti: $_deploy_basarili kopyalandı, $_deploy_atlanan atlandı, $_deploy_hata hata"
}

# ── PULL modu ────────────────────────────────────────────────
# Sistemdeki config'leri repo'ya çeker (ters yön).

_pull_item() {
    local tip="$1" kaynak="$2" isim="$3"

    if [[ "$tip" == "dir" ]]; then
        local sistem_kaynak="$CONFIG_TARGET/$isim"

        if [[ ! -d "$sistem_kaynak" ]]; then
            log_warning "$isim → sistemde bulunamadı, atlanıyor"
            ((_pull_atlanan++))
            return
        fi

        if dirs_match "$kaynak" "$sistem_kaynak"; then
            log_skip "$isim → zaten güncel"
            ((_pull_atlanan++))
            return
        fi

        if ! ask_confirm "$isim repo'ya çekilsin mi?"; then
            ((_pull_atlanan++))
            return
        fi

        # Mevcut .keep dosyalarını hatırla
        local keep_files=()
        while IFS= read -r -d '' f; do
            keep_files+=("${f#$kaynak/}")
        done < <(find "$kaynak" -name '.keep' -print0 2>/dev/null)

        # Güvenli kopyalama: önce geçici dizine kopyala, sonra atomik taşı
        local temp_dir
        temp_dir=$(mktemp -d) || {
            log_error "Geçici dizin oluşturulamadı: $isim"
            ((_pull_hata++))
            return
        }

        if cp -a "$sistem_kaynak" "$temp_dir/$isim"; then
            # Repo'daki mevcut config'i yedekle
            backup_file "$kaynak"
            rm -rf "$kaynak"
            mv "$temp_dir/$isim" "$kaynak"

            # .keep dosyalarını geri oluştur
            for keep in "${keep_files[@]}"; do
                local keep_parent
                keep_parent=$(dirname "$kaynak/$keep")
                mkdir -p "$keep_parent"
                touch "$kaynak/$keep"
            done

            log_success "$isim → repo'ya çekildi"
            ((_pull_basarili++))
        else
            log_error "Kopyalama başarısız: $isim"
            ((_pull_hata++))
        fi

        rm -rf "$temp_dir"
    else
        local sistem_dosya="$CONFIG_TARGET/$isim"

        if [[ ! -f "$sistem_dosya" ]]; then
            log_warning "$isim → sistemde bulunamadı, atlanıyor"
            ((_pull_atlanan++))
            return
        fi

        if files_match "$kaynak" "$sistem_dosya"; then
            log_skip "$isim → zaten güncel"
            ((_pull_atlanan++))
            return
        fi

        if ! ask_confirm "$isim repo'ya çekilsin mi?"; then
            ((_pull_atlanan++))
            return
        fi

        backup_file "$kaynak"
        if cp -a "$sistem_dosya" "$kaynak"; then
            log_success "$isim → repo'ya çekildi"
            ((_pull_basarili++))
        else
            log_error "Çekme başarısız: $isim"
            ((_pull_hata++))
        fi
    fi
}

do_pull() {
    print_header "⬇️  Dotfile Çekme (Sistem → Repo)"

    _pull_basarili=0
    _pull_atlanan=0
    _pull_hata=0

    iterate_configs _pull_item

    echo ""
    log_info "Çekme özeti: $_pull_basarili güncellendi, $_pull_atlanan atlandı, $_pull_hata hata"
}

# ── Ön Kontroller ────────────────────────────────────────────

preflight() {
    if [[ ! -d "$CONFIG_SOURCE" ]]; then
        log_warning "Config dizini bulunamadı: $CONFIG_SOURCE"
        log_info "Lütfen config/ dizinine dotfile'larınızı ekleyin."
        return 1
    fi

    local dizin_sayisi
    dizin_sayisi=$(find "$CONFIG_SOURCE" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
    local dosya_sayisi
    dosya_sayisi=$(find "$CONFIG_SOURCE" -maxdepth 1 -type f -not -name '.keep' 2>/dev/null | wc -l)

    if [[ $dizin_sayisi -eq 0 && $dosya_sayisi -eq 0 ]]; then
        log_warning "Config dizini boş. İşlenecek dosya yok."
        log_info "Lütfen config/ altına dotfile dizinlerinizi ekleyin (örn: config/hypr/, config/waybar/)"
        return 1
    fi

    return 0
}

# ── Ana Akış ─────────────────────────────────────────────────

main() {
    local mod="${1:-check}"
    local extra_args="${2:-}"

    preflight || return 0

    case "$mod" in
        check)
            do_check
            ;;
        diff)
            do_diff
            ;;
        deploy)
            do_deploy "$extra_args"
            ;;
        pull)
            do_pull
            ;;
        *)
            log_error "Bilinmeyen mod: $mod"
            echo ""
            echo -e "  ${BOLD}Kullanım:${NC}"
            echo -e "    dotfiles.sh [check|diff|deploy|pull] [seçenekler]"
            echo ""
            echo -e "  ${BOLD}Modlar:${NC}"
            echo -e "    ${GREEN}check${NC}   Config'lerin yerinde ve güncel olup olmadığını kontrol eder (varsayılan)"
            echo -e "    ${YELLOW}diff${NC}    Farklılıkları detaylı gösterir"
            echo -e "    ${CYAN}deploy${NC}  Config'leri repo'dan sisteme kopyalar"
            echo -e "    ${MAGENTA}pull${NC}    Config'leri sistemden repo'ya çeker"
            echo ""
            echo -e "  ${BOLD}Seçenekler:${NC}"
            echo -e "    ${DIM}--force${NC}  Deploy modunda güncel config'leri de zorla kopyalar"
            echo ""
            return 1
            ;;
    esac
}

main "$@"
