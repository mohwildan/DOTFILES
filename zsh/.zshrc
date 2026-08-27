# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

# Increase file descriptor limit for development tools, Neovim, and LSP servers
ulimit -n 65536 2>/dev/null || ulimit -n 10240 2>/dev/null

# Framework Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# ----------alias-------
alias php74="/opt/homebrew/opt/php@7.4/bin/php"
alias composer74="php74 $(which composer)"
alias php81="/opt/homebrew/opt/php@8.1/bin/php"
alias composer81="php81 $(which composer)"
# git
alias glog="git log --oneline --graph --decorate -n 10"

# Dotfiles management & auto-sync
alias dotsync="$HOME/.dotfiles/sync.sh"

# Node Version Manager (NVM)
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/share/nvm/nvm.sh" ] && \. "/opt/homebrew/share/nvm/nvm.sh"
[ -s "/opt/homebrew/share/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/share/nvm/etc/bash_completion.d/nvm"
export NVM_DIR="$HOME/.nvm"
# source $HOME/.cargo/env
[ -f "/opt/homebrew/Cellar/nvm/0.40.3/nvm.sh" ] && source /opt/homebrew/Cellar/nvm/0.40.3/nvm.sh

# Environment Paths
# Created by `pipx` on 2025-11-05 19:06:09
export PATH="$PATH:/Users/mac/.local/bin"
export CPPFLAGS="-I/opt/homebrew/include"
export LDFLAGS="-L/opt/homebrew/lib"

# ==============================================================================
# LOCAL SECRETS & ENVIRONMENT CONFIGURATION (GITIGNORED)
# ==============================================================================
if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi

# Homebrew
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# PHP 7.4 priority
#export PATH="/opt/homebrew/opt/php@7.4/bin:$PATH"
#export PATH="/opt/homebrew/opt/php@7.4/sbin:$PATH"

export PATH="$HOME/.composer/vendor/bin:$PATH"

# Custom cd for add list folder
cd() {
    builtin cd "$@" && ls
}

# JBR & Android SDK Environment
export JAVA_HOME=$(/usr/libexec/java_home -v 11 2>/dev/null || /usr/libexec/java_home 2>/dev/null)
export PATH="$JAVA_HOME/bin:$PATH"
export ANDROID_HOME="/Volumes/DevSSD/Android/sdk"
export ANDROID_SDK_ROOT="/Volumes/DevSSD/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"
export GRADLE_USER_HOME="/Volumes/DevSSD/Android/gradle/.gradle"
export KONAN_DATA_DIR="/Volumes/DevSSD/Android/konan"

# Added by Antigravity
export PATH="/Users/mac/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity IDE
export PATH="/Users/mac/.antigravity-ide/antigravity-ide/bin:$PATH"

# ---------- Homebrew Zsh Plugins Loader ----------
# Load Zsh Autosuggestions secara langsung dari Homebrew path
if [ -f "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    # Memaksa warna text saran menjadi abu-abu agar terlihat jelas
    export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
fi

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"

flyfile() {
    local TITLE="${1:-migration}"
    local TIMESTAMP
    local FILE_NAME

    TIMESTAMP="$(date +%Y%m%d%H%M%S)"
    FILE_NAME="V${TIMESTAMP}__${TITLE}.sql"
    printf '%s' "$FILE_NAME" | pbcopy

    echo "Copied file name: $FILE_NAME"
}

if [ -n "$GHOSTTY_RESOURCES_DIR" ]; then
    chpwd() {
        print -Pn "\e]7;file://%m%~ \e\\"
    }
    chpwd
fi

# Added by Antigravity CLI installer
export PATH="/Users/mac/.local/bin:$PATH"
