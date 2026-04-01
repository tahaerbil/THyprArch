#!/bin/bash

# config/kitty/ içindeki dosyaları ~/.config/kitty/ altına kopyalar

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME/.config/kitty"

mkdir -p "$TARGET"

cp "$SCRIPT_DIR/kitty.conf" "$TARGET/"

echo "Kitty konfigürasyonu ~/.config/kitty/ altına kopyalandı."
