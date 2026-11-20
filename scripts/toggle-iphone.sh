#!/bin/bash
# ==============================================================================
# 📱 Toggle Hide / Show iPhone Mirroring (Instant & Flicker-Free)
# ==============================================================================

export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"
SCRATCHPAD_WS="9"

CURRENT_WS=$(aerospace list-workspaces --focused 2>/dev/null)
[ -z "$CURRENT_WS" ] && exit 0

TARGET_INFO=$(aerospace list-windows --all --format "%{window-id}|%{app-bundle-id}|%{workspace}" 2>/dev/null | grep "com.apple.ScreenContinuity" | head -n 1)

if [ -z "$TARGET_INFO" ]; then
    open -a "iPhone Mirroring"
    exit 0
fi

TARGET_ID=$(echo "$TARGET_INFO" | cut -d'|' -f1)
TARGET_WS=$(echo "$TARGET_INFO" | cut -d'|' -f3)

if [ "$TARGET_WS" = "$SCRATCHPAD_WS" ]; then
    # Currently hidden on scratchpad 9 -> Summon to active workspace
    aerospace move-node-to-workspace --window-id "$TARGET_ID" "$CURRENT_WS" 2>/dev/null
else
    # Currently on an active workspace -> Move to scratchpad 9 to hide completely
    aerospace move-node-to-workspace --window-id "$TARGET_ID" "$SCRATCHPAD_WS" 2>/dev/null
fi
