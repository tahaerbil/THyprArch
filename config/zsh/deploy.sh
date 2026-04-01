#!/bin/bash

# ╔══════════════════════════════════════════════════════════╗
# ║  thyprsc - Zsh Deploy Script                             ║
# ║  config/zsh/ içindeki dosyaları anında sisteme kopyalar. ║
# ╚══════════════════════════════════════════════════════════╝

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_CONFIG_DIR="$HOME/.config/zsh"

echo "Zsh yapılandırmaları kopyalanıyor..."

# .config/zsh dizinini oluştur (eğer yoksa)
mkdir -p "$ZSH_CONFIG_DIR"

# 1. aliases.zsh dosyasını kopyala
if [[ -f "$SCRIPT_DIR/aliases.zsh" ]]; then
    cp "$SCRIPT_DIR/aliases.zsh" "$ZSH_CONFIG_DIR/aliases.zsh"
    echo "  -> aliases.zsh güncellendi ($ZSH_CONFIG_DIR/aliases.zsh)"
fi

# 2. zshrc dosyasını kopyala
if [[ -f "$SCRIPT_DIR/zshrc" ]]; then
    # Yedek almayı unutmayalım
    if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date '+%Y%m%d')"
    fi
    
    cp "$SCRIPT_DIR/zshrc" "$HOME/.zshrc"
    echo "  -> .zshrc güncellendi ($HOME/.zshrc)"
fi

# Zsh oturumunu yenileme uyarısı
echo ""
echo "✅ İşlem tamamlandı."
echo "Değişikliklerin anında etki etmesi için terminalde şu komutu çalıştır:"
echo "source ~/.zshrc   veya   exec zsh"
