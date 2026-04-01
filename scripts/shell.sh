#!/bin/bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc - Zsh & Shell Yapılandırma                       ║
# ║  Zsh kurulumu, Oh My Zsh ve temel eklentiler              ║
# ╚══════════════════════════════════════════════════════════╝

set -euo pipefail # Katı hata yönetimi (Hata bulursa durur, undefined değişkende durur, pipe hatasında durur)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

print_header "Zsh & Shell Yapılandırma"

# ── Bağımlılık Kontrolü (curl, git) ──────────────────────────
# Oh My Zsh yükleyici betiği için curl ve git gereklidir.
for deps in curl git; do
    if ! command -v "$deps" &> /dev/null; then
        log_info "$deps sistemde bulunamadı. Kuruluyor..."
        sudo pacman -S --noconfirm "$deps"
    fi
done

# ── Paket Kurulumu (Zsh ve Eklentiler) ───────────────────────

PACKAGES=(zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting ttf-jetbrains-mono-nerd)

for pkg in "${PACKAGES[@]}"; do
    if is_installed "$pkg"; then
        log_skip "$pkg zaten kurulu."
    else
        log_info "$pkg kuruluyor..."
        sudo pacman -S --noconfirm "$pkg"
    fi
done

# ── Oh My Zsh ────────────────────────────────────────────────

if [ -d "$HOME/.oh-my-zsh" ]; then
    log_skip "Oh My Zsh zaten kurulu."
else
    if ask_confirm "Oh My Zsh kurulsun mu?"; then
        log_info "Oh My Zsh kuruluyor..."
        if curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- "" --unattended; then
            log_success "Oh My Zsh başarıyla kuruldu."
        else
            log_error "Oh My Zsh kurulumu başarısız oldu. Lütfen internet bağlantınızı kontrol edin."
            exit 1
        fi
    fi
fi

# ── Powerlevel10k Teması ─────────────────────────────────────

P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ -d "$P10K_DIR" ]; then
    log_skip "Powerlevel10k zaten kurulu."
else
    log_info "Powerlevel10k teması kuruluyor..."
    if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"; then
        log_success "Powerlevel10k başarıyla indirildi."
    else
        log_error "Powerlevel10k indirilemedi."
    fi
fi

# ── Yapılandırma Dosyaları ──────────────────────────────────


# THYPRSC_DIR değişkeninin dolu ve geçerli olduğunu u ayarı nedeniyle garanti etmiş oluyoruz.
if [[ -z "${THYPRSC_DIR:-}" || ! -d "$THYPRSC_DIR" ]]; then
    log_error "THYPRSC_DIR tanımsız veya klasör bulunamıyor!"
    exit 1
fi

ZSH_CONFIG_DIR="$HOME/.config/zsh"
mkdir -p "$ZSH_CONFIG_DIR"

log_info "Zsh yapılandırma dosyaları yerleştiriliyor..."

# .zshrc
backup_file "$HOME/.zshrc" || true # Yedek başarısız olsa bile script devam etmeli, çünkü belki dosya zaten yok.
cp "$THYPRSC_DIR/config/zsh/zshrc" "$HOME/.zshrc"

# Aliases
cp "$THYPRSC_DIR/config/zsh/aliases.zsh" "$ZSH_CONFIG_DIR/aliases.zsh"

log_success "Yapılandırma dosyaları başarıyla taşındı."

# ── Varsayılan Kabuk (Zsh Yapma) ─────────────────────────────

ZSH_PATH=$(command -v zsh || echo "/usr/bin/zsh")
CURRENT_SHELL=$(basename "$SHELL")

if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    log_skip "Zsh zaten varsayılan kabuk."
elif ! grep -q "$ZSH_PATH" /etc/shells; then
    log_warning "Zsh geçerli shell'ler arasında tanımlı değil (/etc/shells). Lütfen bu dosyayı kontrol edin."
else
    if ask_confirm "Zsh varsayılan kabuk yapılsın mı?"; then
        if sudo chsh -s "$ZSH_PATH" "$USER"; then
            log_success "Varsayılan kabuk Zsh olarak değiştirildi. (Etki etmesi için çıkış-giriş yapın)"
        else
            log_error "Varsayılan kabuk Zsh yapılamadı."
        fi
    fi
fi

log_success "Zsh modülü başarıyla tamamlandı!"

