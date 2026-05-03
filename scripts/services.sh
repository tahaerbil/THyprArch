#!/bin/bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc - Systemd Servisleri & Donanım Modülü           ║
# ╚══════════════════════════════════════════════════════════╝

# Beklenmedik bir hata olursa betiği güvenli şekilde durdur
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# ── Etkinleştirilecek Servisler ──────────────────────────────

SERVISLER=(
    "NetworkManager.service"
    "bluetooth.service"
    "fstrim.timer"
    "tailscaled.service"
    "power-profiles-daemon.service"
    "sddm.service"
)

# ── Servis Yönetimi ──────────────────────────────────────────

enable_services() {
    print_header "⚙️  Systemd Servisleri"

    local etkinlestirilen=0
    local atlanan=0

    for servis in "${SERVISLER[@]}"; do
        if is_service_enabled "$servis"; then
            log_skip "$servis"
            ((atlanan++)) || true
        else
            log_info "$servis etkinleştiriliyor..."
            # Arka plan çıktılarını gizleyerek terminali temiz tutuyoruz
            if sudo systemctl enable "$servis" > /dev/null 2>&1; then
                log_success "$servis etkinleştirildi"
                ((etkinlestirilen++)) || true
            else
                log_error "$servis etkinleştirilemedi!"
            fi
        fi
    done

    if [[ $etkinlestirilen -eq 0 && $atlanan -gt 0 ]]; then
        log_info "Tüm servisler zaten etkin."
    else
        log_info "$etkinlestirilen servis etkinleştirildi, $atlanan zaten aktifti."
    fi
}

# ── Donanım & Modül Ayarları ────────────────────────────────
setup_hardware() {
    print_header "🛠️  Donanım Yapılandırması"

    # 1. i2c-dev modülünü kalıcı yap
    if [[ ! -f "/etc/modules-load.d/i2c.conf" ]] || ! grep -qw "i2c-dev" "/etc/modules-load.d/i2c.conf"; then
        log_info "i2c-dev modülü kalıcı hale getiriliyor..."
        echo "i2c-dev" | sudo tee /etc/modules-load.d/i2c.conf > /dev/null
        log_success "i2c-dev yapılandırıldı"
    else
        log_skip "i2c-dev modül kaydı"
    fi

    # 2. Modülü hemen yükle
    if ! lsmod | grep -qw "i2c_dev"; then
        log_info "i2c-dev modülü yükleniyor..."
        if sudo modprobe i2c-dev; then
            log_success "i2c-dev yüklendi"
        else
            log_error "Kritik Hata: i2c-dev modülü yüklenemedi!"
            log_warning "Lütfen 'linux-headers' paketinin kurulu olduğundan emin olun ve sistemi yeniden başlatın."
            return 1
        fi
    fi

    # 3. Kullanıcıyı gerekli gruplara ekle
    local gruplar=("video" "render" "i2c")
    for grup in "${gruplar[@]}"; do
        if ! id -nG "$USER" | grep -qw "$grup"; then
            log_info "Kullanıcı $grup grubuna ekleniyor..."
            if sudo usermod -aG "$grup" "$USER"; then
                log_success "Kullanıcı $grup grubuna eklendi"
            else
                log_error "$grup grubuna ekleme başarısız!"
            fi
        else
            log_skip "$grup grup üyeliği"
        fi
    done

}

# ── Ana Akış ─────────────────────────────────────────────────

main() {
    ensure_root_warn
    enable_services
    setup_hardware
}

main