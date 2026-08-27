
# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.pre.zsh"

eval "$(/opt/homebrew/bin/brew shellenv)"
# Increase file descriptor limit for development tools, Neovim, and LSP servers
ulimit -n 65536 2>/dev/null || ulimit -n 10240 2>/dev/null
 export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8



# Created by `pipx` on 2025-11-05 19:06:09
export PATH="$PATH:/Users/mac/.local/bin"


# Added by Toolbox App
export PATH="$PATH:/Users/mac/Library/Application Support/JetBrains/Toolbox/scripts"

export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export PATH="$JAVA_HOME/bin:$PATH"
export ANDROID_HOME="/Volumes/DevSSD/Android/sdk"
export ANDROID_SDK_ROOT="/Volumes/DevSSD/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"
export GRADLE_USER_HOME="/Volumes/DevSSD/Android/gradle/.gradle/"
export KONAN_DATA_DIR="/Volumes/DevSSD/Android/konan"



# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.post.zsh"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :


# Added by Antigravity CLI installer
export PATH="/Users/mac/.local/bin:$PATH"
