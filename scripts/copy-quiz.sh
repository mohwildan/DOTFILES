#!/bin/bash
# ==============================================================================
# SiberMu LMS Quiz Range Copier (100% Silent - No Notifications, No Dialogs)
# ==============================================================================

PYTHON_BIN="/Users/mac/project/sibermu-lms-scraping/venv/bin/python3"
PYTHON_SCRIPT="/Users/mac/project/sibermu-lms-scraping/copy_question.py"

TARGET_QUERY="$1"

# If no argument passed, check if text is selected in Chrome; otherwise default to 1-10
if [ -z "$TARGET_QUERY" ]; then
    CHROME_SEL=$(osascript << 'EOF'
    try
        tell application "System Events"
            if not ((name of processes) contains "Google Chrome") then return ""
        end tell
        tell application "Google Chrome"
            if (count of windows) is 0 then return ""
            return execute active tab of front window javascript "window.getSelection().toString().trim()"
        end tell
    on error
        return ""
    end try
EOF
    )

    CHROME_SEL="$(echo "$CHROME_SEL" | tr -d '\r\n' | xargs)"
    if [ -n "$CHROME_SEL" ]; then
        TARGET_QUERY="$CHROME_SEL"
    else
        TARGET_QUERY="1-10"
    fi
fi

# Run silently
"$PYTHON_BIN" "$PYTHON_SCRIPT" "$TARGET_QUERY" > /dev/null 2>&1
exit 0
