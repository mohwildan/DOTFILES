#!/usr/bin/env bash
# ==============================================================================
# 🚀 DOTFILES SAFE INSTALLER & SYMLINKER
# Idempotent, non-destructive installer with automatic safety backups.
# ==============================================================================

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${HOME}/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# ANSI Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

DRY_RUN=false
for arg in "$@"; do
    case "$arg" in
        --dry-run)
            DRY_RUN=true
            echo -e "${YELLOW}[DRY-RUN MODE ENABLED - No files will be modified or linked]${NC}"
            ;;
    esac
done

echo -e "${BLUE}${BOLD}==> Installing Dotfiles from: ${DOTFILES_DIR}${NC}"

# Ensure permissions
chmod +x "${DOTFILES_DIR}/install.sh" "${DOTFILES_DIR}/sync.sh" 2>/dev/null || true

# Function to link a single file safely
link_file() {
    local src="$1"
    local dest="$2"

    if [ ! -e "$src" ]; then
        echo -e "${RED}Error: Source file does not exist: ${src}${NC}"
        return 1
    fi

    local dest_dir
    dest_dir="$(dirname "$dest")"
    if [ ! -d "$dest_dir" ]; then
        if [ "$DRY_RUN" = false ]; then
            mkdir -p "$dest_dir"
        fi
        echo -e "  Created directory: ${dest_dir}"
    fi

    # Check if target already points to correct source
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo -e "  ${GREEN}✓ Already linked:${NC} ${dest} -> ${src}"
        return 0
    fi

    # If destination exists and is not our symlink, back it up
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ "$DRY_RUN" = false ]; then
            mkdir -p "$BACKUP_DIR"
            mv "$dest" "$BACKUP_DIR/"
        fi
        echo -e "  ${YELLOW}Backed up:${NC} ${dest} -> ${BACKUP_DIR}/$(basename "$dest")"
    fi

    if [ "$DRY_RUN" = false ]; then
        ln -sfn "$src" "$dest"
    fi
    echo -e "  ${GREEN}✓ Symlinked:${NC} ${dest} -> ${src}"
}

# ------------------------------------------------------------------------------
# 1. LINK CORE DOTFILES
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}==> [1/3] Creating symlinks...${NC}"

# Shell
link_file "${DOTFILES_DIR}/zsh/.zshrc" "${HOME}/.zshrc"
link_file "${DOTFILES_DIR}/zsh/.zprofile" "${HOME}/.zprofile"

# Tmux
link_file "${DOTFILES_DIR}/tmux/.tmux.conf" "${HOME}/.tmux.conf"

# Git
link_file "${DOTFILES_DIR}/git/.gitconfig" "${HOME}/.gitconfig"
link_file "${DOTFILES_DIR}/git/ignore" "${HOME}/.config/git/ignore"

# AeroSpace
link_file "${DOTFILES_DIR}/aerospace/aerospace.tom" "${HOME}/.config/aerospace/aerospace.tom"
link_file "${DOTFILES_DIR}/aerospace/toggle-chrome-rule.py" "${HOME}/.config/aerospace/toggle-chrome-rule.py"

# Hammerspoon
link_file "${DOTFILES_DIR}/hammerspoon/init.lua" "${HOME}/.hammerspoon/init.lua"

# Warp
link_file "${DOTFILES_DIR}/warp/settings.toml" "${HOME}/.warp/settings.toml"
link_file "${DOTFILES_DIR}/warp/tab_configs" "${HOME}/.warp/tab_configs"

# Zed Editor
link_file "${DOTFILES_DIR}/zed/settings.json" "${HOME}/.config/zed/settings.json"

# Waveterm
link_file "${DOTFILES_DIR}/waveterm/settings.json" "${HOME}/.config/waveterm/settings.json"
link_file "${DOTFILES_DIR}/waveterm/widgets.json" "${HOME}/.config/waveterm/widgets.json"

# Fish Shell
link_file "${DOTFILES_DIR}/fish" "${HOME}/.config/fish"

# Custom Scripts
link_file "${DOTFILES_DIR}/scripts" "${HOME}/scripts"

# ------------------------------------------------------------------------------
# 2. PRIVATE / LOCAL SECRETS SETUP
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}==> [2/3] Checking private environment configuration...${NC}"

if [ ! -f "${HOME}/.zshrc.local" ]; then
    if [ "$DRY_RUN" = false ]; then
        cp "${DOTFILES_DIR}/zsh/.zshrc.local.example" "${HOME}/.zshrc.local"
        chmod 600 "${HOME}/.zshrc.local"
    fi
    echo -e "  ${YELLOW}Created ~/.zshrc.local from template (permissions 600). Add any private keys there.${NC}"
else
    chmod 600 "${HOME}/.zshrc.local" 2>/dev/null || true
    echo -e "  ${GREEN}✓ ~/.zshrc.local is active with private (600) permissions.${NC}"
fi

# ------------------------------------------------------------------------------
# 3. NEOVIM & EXTERNAL REPOSITORIES
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}==> [3/3] Checking Neovim setup...${NC}"

if [ -d "${HOME}/.config/nvim/.git" ]; then
    echo -e "  ${GREEN}✓ Neovim config exists (~/.config/nvim, standalone repository).${NC}"
else
    echo -e "  ${YELLOW}Notice: ~/.config/nvim not found. To install your Neovim setup:${NC}"
    echo -e "    git clone git@github.com:mohwildan/nvim-chad-personal.git ~/.config/nvim"
fi

if [ -d "$BACKUP_DIR" ]; then
    echo -e "\n${YELLOW}📦 Any replaced files were safely preserved in:${NC} ${BACKUP_DIR}"
fi

echo -e "\n${GREEN}${BOLD}🎉 Installation Complete! Run 'dotsync' anytime to auto-sync your configs to Git.${NC}"
