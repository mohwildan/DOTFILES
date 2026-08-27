# ⚡ macOS Dotfiles & Environment Configurations

Clean, modular, secret-safe dotfiles with real-time symlink synchronization and automated Git sync.

---

## 🗂️ Architecture

```
~/.dotfiles/
├── install.sh                  # Safe symlinker & installer with automated backups
├── sync.sh                     # Auto-sync engine with pre-commit secret scanning
├── Brewfile                    # Homebrew bundle (taps, packages, and Mac casks)
├── .gitignore                  # Strict security barrier (blocks secrets, tokens, logs)
├── zsh/
│   ├── .zshrc                 # Interactive shell (aliases, plugins, prompts, dotsync)
│   ├── .zprofile              # Login shell (brew env, PATHs, Java, Android SDK)
│   └── .zshrc.local.example   # Template for local secrets & machine overrides
├── tmux/
│   └── .tmux.conf             # Decay Dark theme, vi mode, pbcopy integration
├── git/
│   ├── .gitconfig             # Git identity, credential helper, aliases
│   └── ignore                 # Global gitignore (~/.config/git/ignore)
├── aerospace/
│   ├── aerospace.tom          # AeroSpace tiling window manager config
│   └── toggle-chrome-rule.py  # Window rule toggle script
├── hammerspoon/
│   └── init.lua               # Hammerspoon macOS automation scripts
├── warp/
│   ├── settings.toml          # Warp terminal settings, themes, and fonts
│   └── tab_configs/           # Warp startup tab configurations
├── zed/
│   └── settings.json          # Zed editor configuration
├── waveterm/
│   ├── settings.json          # Wave terminal configuration
│   └── widgets.json           # Wave widgets
├── fish/
│   └── conf.d/                # Fish shell integration configs
└── scripts/
    ├── ipa-control.sh         # Custom shell control scripts
    └── raycast/               # Raycast custom script commands
```

---

## 🛡️ Secret & Security Architecture

To keep this repository safe to host on GitHub (even publicly), secrets and machine-specific variables are **strictly isolated**:

1. **`~/.zshrc.local`**:
   - Resides on your local machine only at `~/.zshrc.local`.
   - File permissions are restricted to `600` (`chmod 600 ~/.zshrc.local`).
   - Blocked by `.gitignore` so it can **never** be committed.
   - Contains your API keys (e.g. `DEEPSEEK_API_KEY`, `LITELLM_MASTER_KEY`).
2. **Pre-Commit Secret Scanner**:
   - `sync.sh` (and `dotsync`) automatically scans all modified files for secret patterns (OpenAI, DeepSeek, GitHub tokens, AWS keys, private keys) before committing.
   - If an unencrypted secret is detected, synchronization is immediately aborted with a security alert.

---

## 🚀 Quick Start & Installation

### 1. Installation on a New Mac
```bash
git clone git@github.com:mohwildan/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

To preview changes before applying them:
```bash
./install.sh --dry-run
```

The installer automatically:
- Creates a timestamped backup of any existing configs in `~/.dotfiles_backup/` before touching anything.
- Creates symlinks to the right system locations (`~/.zshrc`, `~/.config/...`, etc.).
- Sets up `~/.zshrc.local` from the example template if it doesn't already exist.

### 2. Restoring Homebrew Packages
```bash
brew bundle --file=~/.dotfiles/Brewfile
```

---

## 🔄 How Auto-Sync Works

### Real-Time Local Sync
Because your system files are **symbolic links** pointing into `~/.dotfiles/`, whenever you edit `~/.zshrc`, `~/.tmux.conf`, or `~/.config/aerospace/aerospace.tom` in any editor, **your changes are immediately saved inside this Git repo in real time**.

### Syncing to Git (`dotsync`)
Whenever you want to commit and push your updates to GitHub, run:
```bash
dotsync
```

Or run directly:
```bash
~/.dotfiles/sync.sh
```

What `dotsync` does:
1. **Scans** all staged/modified files for accidental API keys or secrets.
2. **Pulls** remote changes (`git pull --rebase origin main`).
3. **Stages & Commits** with an automatic timestamp and hostname.
4. **Pushes** cleanly to GitHub.

---

## ⏰ Background Auto-Sync (Optional)

If you want macOS to automatically run `dotsync` in the background periodically:

1. Copy the LaunchAgent plist:
```bash
mkdir -p ~/Library/LaunchAgents
cp ~/.dotfiles/com.user.dotfiles-sync.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.user.dotfiles-sync.plist
```
*(Runs once every 4 hours automatically)*

---

## 💻 Neovim Configuration

The Neovim config at `~/.config/nvim` is maintained in its own repository:
[mohwildan/nvim-chad-personal](https://github.com/mohwildan/nvim-chad-personal)

To set up Neovim on a new machine:
```bash
git clone git@github.com:mohwildan/nvim-chad-personal.git ~/.config/nvim
```
