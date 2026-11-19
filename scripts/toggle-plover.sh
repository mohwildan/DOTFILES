#!/bin/bash
# ==============================================================================
# 🔀 Toggle Plover Stenotype Output with Audio & Visual Feedback
# ==============================================================================

PLOVER_APP="/Applications/Plover.app/Contents/MacOS/Plover"
STATE_FILE="/tmp/plover_toggle_state"

if [ ! -x "$PLOVER_APP" ]; then
    osascript -e 'display notification "Plover is not installed in /Applications" with title "Plover Error"'
    exit 1
fi

# Send toggle command to Plover
"$PLOVER_APP" -s plover_send_command toggle

# Determine new state
if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "ON" ]; then
    echo "OFF" > "$STATE_FILE"
    afplay /System/Library/Sounds/Pop.aiff &
    osascript -e 'display notification "Plover Output: SUSPENDED (Normal QWERTY)" with title "⌨️ Plover"'
else
    echo "ON" > "$STATE_FILE"
    afplay /System/Library/Sounds/Tink.aiff &
    osascript -e 'display notification "Plover Output: ENABLED (Steno Active)" with title "⌨️ Plover"'
fi
