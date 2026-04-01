#!/bin/bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc - Hyprland Post-Install Otomasyon Scripti      ║
# ║  Arch Linux için format sonrası otomatik kurulum         ║
# ╚══════════════════════════════════════════════════════════╝

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/utils.sh"

# ── Modül Tanımları ──────────────────────────────────────────
# Her modül: "dosya_adı|açıklama"

MODULLER=(
    "pacman.sh|🔧 Pacman Yapılandırma"
    "packages.sh|📦 Paket Kurulumu"
    "nvidia.sh|🎮 NVIDIA Ayarları"
    "services.sh|⚙️  Systemd Servisleri"
    "dotfiles.sh|🔍 Dotfile Doğrulama"
    "appearance.sh|🎨 Görünüm Ayarları (GTK/QT/Cursor)"
    "shell.sh|🐚 Zsh & Shell Yapılandırma"
    "user-dirs.sh|📁 Kullanıcı Dizinleri"
)

# ── Yardım Mesajı ────────────────────────────────────────────

show_help() {
    echo ""
    echo -e "${BOLD}${CYAN}thyprsc${NC} — Hyprland Post-Install Otomasyon Scripti"
    echo ""
    echo -e "${BOLD}Kullanım:${NC}"
    echo -e "  ./install.sh              İnteraktif menü"
    echo -e "  ./install.sh --auto       Tüm modülleri otomatik çalıştır"
    echo -e "  ./install.sh --help       Bu yardım mesajını göster"
    echo ""
    echo -e "${BOLD}Modüller:${NC}"
    for i in "${!MODULLER[@]}"; do
        local modul="${MODULLER[$i]}"
        local aciklama="${modul#*|}"
        echo -e "  $((i+1)). $aciklama"
    done
    echo ""
    echo -e "${BOLD}Log dosyası:${NC} ~/thyprsc.log"
    echo ""
}

# ── Banner ────────────────────────────────────────────────────

show_banner() {
    echo ""
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║                                              ║${NC}"
    echo -e "${BOLD}${CYAN}║          ▄▄▄▄▄ ▄  ▄ ▄   ▄ ▄▄▄▄               ║${NC}"
    echo -e "${BOLD}${CYAN}║            █   █▄▄█ █   █ █  █               ║${NC}"
    echo -e "${BOLD}${CYAN}║            █   █  █  █▄█  █▀▀                ║${NC}"
    echo -e "${BOLD}${CYAN}║            █   █  █   █   █  █               ║${NC}"
    echo -e "${BOLD}${CYAN}║                                              ║${NC}"
    echo -e "${BOLD}${CYAN}║     Hyprland Post-Install Otomasyon          ║${NC}"
    echo -e "${BOLD}${CYAN}║              Arch Linux                      ║${NC}"
    echo -e "${BOLD}${CYAN}║                                              ║${NC}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════╝${NC}"
    echo ""
}

# ── Modül Çalıştırıcı ────────────────────────────────────────

run_module() {
    local modul_dosya="$1"
    local modul_aciklama="$2"
    shift 2
    local extra_args=("$@")
    local script_path="$SCRIPT_DIR/scripts/$modul_dosya"

    if [[ ! -f "$script_path" ]]; then
        log_error "Modül bulunamadı: $script_path"
        return 1
    fi

    print_header "$modul_aciklama"
    bash "$script_path" "${extra_args[@]}"
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        log_success "${modul_aciklama} — tamamlandı"
    else
        log_error "${modul_aciklama} — hata oluştu (kod: $exit_code)"
    fi

    return $exit_code
}

# ── Dotfiles Alt-Menüsü ──────────────────────────────────────

show_dotfiles_menu() {
    echo ""
    echo -e "  ${BOLD}Dotfile işlemi seçin:${NC}"
    echo -e "    ${GREEN}1${NC}  🔍 Kontrol et (check)"
    echo -e "    ${YELLOW}2${NC}  📋 Farklılıkları göster (diff)"
    echo -e "    ${CYAN}3${NC}  🚀 Config'leri dağıt (deploy)"
    echo -e "    ${MAGENTA}4${NC}  ⬇️  Sistemden çek (pull)"
    echo -e "    ${RED}0${NC}  Atla"
    echo -en "  ${BOLD}Seçim: ${NC}"
    read -r df_secim

    case "$df_secim" in
        1) echo "check" ;;
        2) echo "diff" ;;
        3) echo "deploy" ;;
        4) echo "pull" ;;
        *) echo "" ;;
    esac
}

# ── İnteraktif Menü ──────────────────────────────────────────

show_menu() {
    echo -e "${BOLD}Çalıştırmak istediğiniz modülleri seçin:${NC}"
    echo ""

    for i in "${!MODULLER[@]}"; do
        local modul="${MODULLER[$i]}"
        local aciklama="${modul#*|}"
        echo -e "  ${BOLD}${GREEN}$((i+1))${NC}  $aciklama"
    done

    echo ""
    echo -e "  ${BOLD}${MAGENTA}A${NC}  Tümünü çalıştır"
    echo -e "  ${BOLD}${RED}Q${NC}  Çıkış"
    echo ""
    echo -en "${BOLD}Seçiminiz (örn: 1 3 5 veya A): ${NC}"
    read -r secim

    if [[ "$secim" =~ ^[Qq]$ ]]; then
        echo -e "${YELLOW}Çıkılıyor...${NC}"
        exit 0
    fi

    if [[ "$secim" =~ ^[Aa]$ ]]; then
        run_all_modules
        return
    fi

    # Seçilen modülleri çalıştır
    local basarili=0
    local basarisiz=0

    for num in $secim; do
        if [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num <= ${#MODULLER[@]} )); then
            local modul="${MODULLER[$((num-1))]}"
            local dosya="${modul%%|*}"
            local aciklama="${modul#*|}"

            # Dotfiles modülü için alt-menü göster
            if [[ "$dosya" == "dotfiles.sh" ]]; then
                local dotfiles_mod
                dotfiles_mod=$(show_dotfiles_menu)
                [[ -z "$dotfiles_mod" ]] && continue
                run_module "$dosya" "$aciklama" "$dotfiles_mod"
            else
                run_module "$dosya" "$aciklama"
            fi

            if [[ $? -eq 0 ]]; then
                ((basarili++)) || true
            else
                ((basarisiz++)) || true
            fi
        else
            log_warning "Geçersiz seçim: $num"
        fi
    done

    show_summary $basarili $basarisiz
}

# ── Tüm Modülleri Çalıştır ──────────────────────────────────

run_all_modules() {
    local basarili=0
    local basarisiz=0

    for modul in "${MODULLER[@]}"; do
        local dosya="${modul%%|*}"
        local aciklama="${modul#*|}"
        run_module "$dosya" "$aciklama"
        if [[ $? -eq 0 ]]; then
            ((basarili++)) || true
        else
            ((basarisiz++)) || true
        fi
    done

    show_summary $basarili $basarisiz
}

# ── Kurulum Özeti ────────────────────────────────────────────

show_summary() {
    local basarili=$1
    local basarisiz=$2

    echo ""
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}  Kurulum Özeti${NC}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${GREEN}✔ Başarılı:${NC}  $basarili modül"
    echo -e "  ${RED}✘ Başarısız:${NC} $basarisiz modül"
    echo -e "  ${BLUE}📄 Log:${NC}      $LOG_FILE"
    echo ""

    if [[ $basarisiz -eq 0 ]]; then
        echo -e "  ${GREEN}${BOLD}✅ Tüm modüller başarıyla tamamlandı!${NC}"
    else
        echo -e "  ${YELLOW}${BOLD}⚠️  Bazı modüller başarısız oldu. Log dosyasını kontrol edin.${NC}"
    fi
    echo ""
}

# ── Log Başlatma ─────────────────────────────────────────────

init_log() {
    echo "" >> "$LOG_FILE"
    echo "═══════════════════════════════════════════════════════" >> "$LOG_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] thyprsc başlatıldı (mod: ${AUTO_MODE})" >> "$LOG_FILE"
    echo "═══════════════════════════════════════════════════════" >> "$LOG_FILE"
}

# ── Ana Akış ─────────────────────────────────────────────────

main() {
    # Argüman kontrolü
    case "${1:-}" in
        --auto)
            export AUTO_MODE=true
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        "")
            export AUTO_MODE=false
            ;;
        *)
            echo -e "${RED}Bilinmeyen argüman: $1${NC}"
            show_help
            exit 1
            ;;
    esac

    show_banner
    init_log
    ensure_root_warn

    if [[ "$AUTO_MODE" == "true" ]]; then
        echo -e "${BOLD}${MAGENTA}🚀 Otomatik mod — tüm modüller sırayla çalıştırılacak${NC}"
        _log_to_file "MODE" "Otomatik mod aktif"
        echo ""
        run_all_modules
    else
        show_menu
    fi
}

main "$@"
