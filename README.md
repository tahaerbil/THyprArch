# thyprsc 🎨
Modern, minimal, and highly customizable Hyprland setup.

## ✨ Features
* **Hyprland** Window Manager configuration
* **Waybar** custom minimal 3-island design
* **Theme Switching Engine** (Support for various themes like Catppuccin, Nord, Tokyo Night, etc.)
* Automated Installation Scripts for Arch Linux (pacman configuration, dependencies, nvidia setup)
* Utility scripts for system management

## 🚀 Installation (Coming Soon)
The installation script is currently in testing and development phase. 
Once completed, you will be able to install this setup securely and easily on your Arch Linux system.

```bash
# Example command (WIP)
git clone https://github.com/yourusername/thyprsc.git
cd thyprsc
chmod +x install.sh
./install.sh
```

## 📂 Project Structure
* `config/` - The core configuration files that will be placed in `~/.config/`
  * `hypr/` - Hyprland configs, keybindings, and scripts (screenshot, theme-switch)
  * `waybar/` - Waybar configs (`config.jsonc`, `style.css`)
* `scripts/` - Modular installation/setup scripts
  * `pacman.sh` - Pacman mirror and configuration optimizations
  * `packages.sh` - Main system dependencies installer
  * `nvidia.sh` - Nvidia proprietary drivers and hooks setup
  * `dotfiles.sh` - Dotfiles deployment script
  * ...and more.
* `install.sh` - Main orchestrator script for the complete installation
* `TEST_STATUS.md` - Development tracking and script testing status

## 🖼️ Waybar Design
The Waybar features a modern, clean, transparent background with three distinct black "islands":
1. **Left:** Workspaces
2. **Center:** Clock and Date (Hover/Click functionality)
3. **Right:** System Icons (Brightness, Volume, Network)

## 🤝 Contributing
Feel free to open issues or submit pull requests. Any contributions you make are greatly appreciated.

---
*Created by [yourname]*
