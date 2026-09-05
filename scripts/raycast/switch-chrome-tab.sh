#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch Chrome Tab
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📑
# @raycast.packageName Chrome Navigation
# @raycast.argument1 { "type": "text", "placeholder": "Tab (1-10+)", "optional": false }

TAB_NUM="$1"
/Users/mac/scripts/chrome-tab.sh "$TAB_NUM"
