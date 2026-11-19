#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Steno Lookup
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon ⌨️
# @raycast.packageName Stenography
# @raycast.argument1 { "type": "text", "placeholder": "Word or chord (e.g. apple or S-G)" }

python3 /Users/mac/.dotfiles/scripts/steno-lookup.py "$1"

