#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Scrape Quiz from Chrome
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🌐
# @raycast.packageName Sibermu Quiz

nohup /Users/mac/scripts/scrape-quiz.sh > /dev/null 2>&1 &
exit 0
