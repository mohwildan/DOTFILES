#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch Gemini Tab
# @raycast.mode silent
# @raycast.packageName Gemini Navigation

# Optional parameters:
# @raycast.icon 📑
# @raycast.argument1 { "type": "text", "placeholder": "Batch (1, 2, 3...)", "optional": false }

BATCH_NUM="$1"
/Users/mac/scripts/gemini-tab.sh "$BATCH_NUM" -f > /dev/null 2>&1
exit 0
