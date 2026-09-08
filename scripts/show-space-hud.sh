#!/bin/bash
# ==============================================================================
# 🚀 AeroSpace Interactive Window Picker & Auto-Jumper
# Shows dropdown list of all windows in current space with 1-key auto-jump!
# ==============================================================================

export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"

PICKER_BIN="/Users/mac/scripts/aerospace-picker"
[ -f "$PICKER_BIN" ] || PICKER_BIN="/Users/mac/.dotfiles/scripts/aerospace-picker"

if [ -x "$PICKER_BIN" ]; then
    exec "$PICKER_BIN"
else
    # Fallback to HUD if picker not compiled
    HUD_BIN="/Users/mac/scripts/aerospace-hud"
    [ -f "$HUD_BIN" ] || HUD_BIN="/Users/mac/.dotfiles/scripts/aerospace-hud"
    [ -x "$HUD_BIN" ] && exec "$HUD_BIN"
fi
