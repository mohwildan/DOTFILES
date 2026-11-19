#!/bin/bash
# ==============================================================================
# 🚀 Launch Native Swift Steno Floating HUD
# High-performance, native Cocoa translucent floating HUD with sound & alphabet
# ==============================================================================

HUD_BIN="/Users/mac/.dotfiles/scripts/steno-hud"

if [ -x "$HUD_BIN" ]; then
    exec "$HUD_BIN"
else
    # Fallback: recompile if binary is missing
    swiftc -O -o "$HUD_BIN" /Users/mac/.dotfiles/scripts/steno-hud.swift
    exec "$HUD_BIN"
fi
