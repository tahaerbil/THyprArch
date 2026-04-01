#!/bin/bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc - Ortak Yardımcı Fonksiyonlar                  ║
# ║  Tüm modül scriptleri bu dosyayı source eder.           ║
# ╚══════════════════════════════════════════════════════════╝

# ── Renkler ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ── Genel Değişkenler ────────────────────────────────────────
THYPRSC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE="${HOME}/thyprsc.log"
AUTO_MODE="${AUTO_MODE:-false}"

# ── Log Fonksiyonları ────────────────────────────────────────

_log_to_file() {
    local level="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_FILE"
}

log_info() {
    local message="$1"
    echo -e "  ${BLUE}ℹ${NC}  ${message}"
    _log_to_file "INFO" "$message"
}

log_success() {
    local message="$1"
    echo -e "  ${GREEN}✔${NC}  ${message}"
    _log_to_file "OK" "$message"
}

log_warning() {
    local message="$1"
    echo -e "  ${YELLOW}⚠${NC}  ${message}"
    _log_to_file "WARN" "$message"
}

log_error() {
    local message="$1"
    echo -e "  ${RED}✘${NC}  ${message}"
    _log_to_file "ERROR" "$message"
}

log_skip() {
    local message="$1"
    echo -e "  ${DIM}⏭  ${message} (zaten yapılmış)${NC}"
    _log_to_file "SKIP" "$message"
}

# ── Bölüm Başlığı ───────────────────────────────────────────

print_header() {
    local title="$1"
    echo ""
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}  $title${NC}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    _log_to_file "SECTION" "=== $title ==="
}

# ── Onay Fonksiyonu ──────────────────────────────────────────

ask_confirm() {
    local message="$1"

    if [[ "$AUTO_MODE" == "true" ]]; then
        _log_to_file "AUTO" "Otomatik onay: $message"
        return 0
    fi

    echo -en "  ${YELLOW}${BOLD}⚠️  ${message} [E/h]${NC} "
    read -r answer
    answer=${answer:-E}

    if [[ "$answer" =~ ^[Ee]$ ]]; then
        return 0
    else
        log_warning "İptal edildi: $message"
        return 1
    fi
}

# ── Backup Fonksiyonu ────────────────────────────────────────

backup_file() {
    local filepath="$1"

    if [[ ! -e "$filepath" ]]; then
        return 0
    fi

    # Symlink ise sadece sil, backup almaya gerek yok
    if [[ -L "$filepath" ]]; then
        _log_to_file "BACKUP" "Symlink kaldırıldı: $filepath"
        return 0
    fi

    local timestamp
    timestamp=$(date '+%Y%m%d-%H%M%S')
    local backup_path="${filepath}.bak.${timestamp}"

    sudo cp -a "$filepath" "$backup_path"
    if [[ $? -eq 0 ]]; then
        log_info "Yedeklendi: ${DIM}${backup_path}${NC}"
        _log_to_file "BACKUP" "$filepath -> $backup_path"
    else
        log_error "Yedekleme başarısız: $filepath"
        return 1
    fi
}

# ── İdempotency Yardımcıları ────────────────────────────────

is_installed() {
    local package="$1"
    pacman -Qi "$package" &>/dev/null || yay -Qi "$package" &>/dev/null
}

is_flatpak_installed() {
    local app_id="$1"
    command -v flatpak &>/dev/null && flatpak info "$app_id" &>/dev/null
}

is_service_enabled() {
    local service="$1"
    systemctl is-enabled "$service" &>/dev/null
}

file_contains() {
    local filepath="$1"
    local content="$2"
    grep -qF "$content" "$filepath" 2>/dev/null
}

# ── INI Dosya Yardımcıları ───────────────────────────────────

# INI dosyası yoksa [Settings] başlığıyla oluştur
ensure_ini_file() {
    local filepath="$1"
    local section="${2:-Settings}"

    if [[ ! -f "$filepath" ]]; then
        mkdir -p "$(dirname "$filepath")"
        echo "[$section]" > "$filepath"
    fi
}

# INI dosyasında key=value ayarla (varsa güncelle, yoksa ekle)
# Kullanım: ini_set <dosya> <key> <value> [section]
ini_set() {
    local filepath="$1"
    local key="$2"
    local value="$3"
    local section="${4:-Settings}"

    ensure_ini_file "$filepath" "$section"

    if grep -q "^${key}=" "$filepath" 2>/dev/null; then
        # Key zaten var, değeri güncelle
        sed -i "s|^${key}=.*|${key}=${value}|" "$filepath"
    else
        # Key yok, section altına ekle
        sed -i "/^\[${section}\]/a ${key}=${value}" "$filepath"
    fi
}

# ── Script Başlatıcı ─────────────────────────────────────────
# Modüller hem bağımsız hem install.sh üzerinden çalışabilir.
# Bağımsız çalışırken utils.sh'yi kendileri source eder.

ensure_root_warn() {
    if [[ $EUID -ne 0 ]]; then
        log_warning "Bazı işlemler sudo gerektirir. Şifre istenebilir."
    fi
}
