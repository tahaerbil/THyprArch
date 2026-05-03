# Genel
alias c='clear'                                          # Terminal ekranını temizler
alias ram='free -m'                                      # Ram kullanımını gösterir
alias disk='df -h'                                       # Disk kullanımını gösterir
alias myalias='nvim ~/.config/zsh/aliases.zsh'           # Alias dosyasını düzenler

# Paket Yönetimi (Pacman/Yay)
alias i='yay -S'                                         # Kurulum başlatır
alias s='yay -Ss'                                        # Paketleri arar
alias u='yay -Syu'                                       # AUR + Sistem güncellemeyi başlatır
alias r='yay -Rsun'                                      # Kaldırır
alias cleanup='[ -n "$(pacman -Qtdq)" ] && sudo pacman -Rns $(pacman -Qtdq) || echo "Sistem temiz."' # Gereksiz yetim paketleri temizler
alias unlock='sudo rm /var/lib/pacman/db.lck'            # Pacman veritabanı kilidini kaldırır

# Modern Araçlar (Sisteminizde yüklü olanlar)
alias v='nvim'
alias y='yazi'
alias top='btop'
alias ff='fastfetch'

# Temel Git Kısayolları
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gpl='git pull'
alias gp='git push'
alias gl='git log --oneline --graph --all'
alias gacp='git add . && git commit -m "update" && git push'