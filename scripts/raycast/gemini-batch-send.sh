#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Send Quiz Batches to Gemini (10/tab)
# @raycast.mode silent
# @raycast.packageName Gemini Quiz

# Optional parameters:
# @raycast.icon 🚀

nohup /Users/mac/scripts/gemini-batch-quiz.sh > /dev/null 2>&1 &
exit 0
