# 🏗️ thyprsc Project Structure (AI Guide)

This document provides a detailed breakdown of the `thyprsc` project structure, designed to help AI models navigate, understand, and modify the codebase efficiently.

---

## 📂 Root Directory

- **[install.sh](file:///home/taha/Belgeler/projeler/coding/thyprsc/install.sh):** The main entry point and orchestrator. It manages the installation flow, provides an interactive menu, and triggers modular scripts.
- **[README.md](file:///home/taha/Belgeler/projeler/coding/thyprsc/README.md):** High-level project overview, features, and installation instructions.
- **[TEST_STATUS.md](file:///home/taha/Belgeler/projeler/coding/thyprsc/TEST_STATUS.md):** Real-time tracking of script stability and testing progress. **Always check this before modifying scripts.**
- **[STRUCTURE.md](file:///home/taha/Belgeler/projeler/coding/thyprsc/STRUCTURE.md):** (This file) Detailed architectural guide for AI navigation.

---

## 🛠️ scripts/ — Modular System Components

Installation and system management scripts. Most scripts source `utils.sh` for common functions.

| File | Purpose | Key Details |
| :--- | :--- | :--- |
| **[utils.sh](file:///home/taha/Belgeler/projeler/coding/thyprsc/scripts/utils.sh)** | Shared Utilities | Colors, logging, `backup_file`, `ini_set`, `ask_confirm`. Essential for all modules. |
| **[dotfiles.sh](file:///home/taha/Belgeler/projeler/coding/thyprsc/scripts/dotfiles.sh)** | Config Manager | Multi-mode sync engine: `check`, `diff`, `deploy` (to system), `pull` (from system). |
| **[packages.sh](file:///home/taha/Belgeler/projeler/coding/thyprsc/scripts/packages.sh)** | Package Installer | Handles pacman/yay dependencies. |
| **[nvidia.sh](file:///home/taha/Belgeler/projeler/coding/thyprsc/scripts/nvidia.sh)** | Nvidia Setup | Proprietary driver installation and optimizations (locale-aware). |
| **[appearance.sh](file:///home/taha/Belgeler/projeler/coding/thyprsc/scripts/appearance.sh)** | UI Theming | GTK/QT themes, icons, cursors, and font configurations. |
| **[pacman.sh](file:///home/taha/Belgeler/projeler/coding/thyprsc/scripts/pacman.sh)** | System Optimization| Mirrorlist and pacman configuration tweaks. |
| **[services.sh](file:///home/taha/Belgeler/projeler/coding/thyprsc/scripts/services.sh)** | Service & Hardware | Enables systemd services and configures hardware modules (i2c etc.). |
| **[locale.sh](file:///home/taha/Belgeler/projeler/coding/thyprsc/scripts/locale.sh)** | Localization | System language and region settings. |
| **[shell.sh](file:///home/taha/Belgeler/projeler/coding/thyprsc/scripts/shell.sh)** | Shell Setup | Zsh installation, Oh My Zsh, and plugins. |
| **[user-dirs.sh](file:///home/taha/Belgeler/projeler/coding/thyprsc/scripts/user-dirs.sh)** | Home Setup | Manages XDG user directories (Documents, Downloads, etc.). |

---

## 🎨 config/ — Desktop Environment Files

These files are deployed to `~/.config/` via `dotfiles.sh deploy`.

### [hypr/](file:///home/taha/Belgeler/projeler/coding/thyprsc/config/hypr/) - Hyprland Lua Config 🚀
- `hyprland.lua`: The elegant Lua-based main orchestrator that boots the WM and loads modular configs from `conf/`.
- `conf/`: Contains modular Lua settings (`monitors.lua`, `programs.lua`, `environment.lua`, `permissions.lua`, `look-and-feel.lua`, `misc.lua`, `input.lua`, `keybindings.lua`, `windows-and-workspaces.lua`, `autostart.lua`).
- `scripts/`: Premium runtime shell scripts (`screenshot.sh`, `brightness.sh`, `volume.sh`, `clipboard.sh`, etc.) triggered via Lua keybindings.

### [waybar/](file:///home/taha/Belgeler/projeler/coding/thyprsc/config/waybar/) - Status Bar
- `config.jsonc`: Layout definition (3-island design).
- `style.css`: Visual styling and animations for the bar.

### Other Folders
- `kitty/`: Terminal emulator configuration.
- `rofi/`: App launcher, custom calculator, and emoji menus.
- `swaync/`: Notification center configuration and styles.
- `zsh/`: Zsh shell configurations and aliases.

---

## 🚦 Architectural Patterns

1. **Idempotency:** Scripts should check if a change is already applied before executing (e.g., `is_installed`, `file_contains`).
2. **Safety First:** Always use `backup_file` from `utils.sh` before overwriting user configurations.
3. **Modularity:** Keep logic separated by function. `install.sh` should remain a high-level orchestrator.
4. **Environment Awareness:** Scripts should respect `$AUTO_MODE` for non-interactive execution.

---

## ⚠️ AI Modification Rules (Strict)

1. **Scope:** ONLY modify files within the `/home/taha/Belgeler/projeler/coding/thyprsc/` directory.
2. **Absolute Paths:** Always use the absolute paths provided in this document.
3. **No External Changes:** Never attempt to modify system files (like `/usr/` or `/etc/`) or home directory files (like `~/.config/`) directly. All changes must be made inside the `config/` or `scripts/` folders of this project.
4. **Deployment:** To apply changes to the system, update the file in this project first, then remind the user to run `install.sh` or `dotfiles.sh deploy`.
