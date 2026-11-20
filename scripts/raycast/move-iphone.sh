#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Move iPhone Mirroring
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📱
# @raycast.packageName Window Management
# @raycast.argument1 { "type": "dropdown", "placeholder": "Choose Position", "optional": true, "data": [{"title": "🔄 Cycle Next Corner", "value": "cycle"}, {"title": "↗️ Top Right", "value": "tr"}, {"title": "⬆️ Top Middle", "value": "tc"}, {"title": "↖️ Top Left", "value": "tl"}, {"title": "↘️ Bottom Right", "value": "br"}, {"title": "⬇️ Bottom Middle", "value": "bc"}, {"title": "↙️ Bottom Left", "value": "bl"}] }

POS="${1:-cycle}"
exec /Users/mac/.dotfiles/scripts/move-iphone.sh "$POS"
