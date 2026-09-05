#!/bin/bash
# ==============================================================================
# Chrome Tab Switcher (macOS)
# Fast & reliable tab navigation for Google Chrome, supporting tabs 1 to 10+
#
# Usage:
#   chrome-tab.sh <number>        # Switch to tab 1, 2, 3, 4, 5, 6, 10, etc.
#   chrome-tab.sh next            # Switch to next tab
#   chrome-tab.sh prev            # Switch to previous tab
#   chrome-tab.sh last            # Switch to last tab
#   chrome-tab.sh first           # Switch to tab 1
#   chrome-tab.sh <number> -b     # Switch tab in background (without focusing Chrome)
# ==============================================================================

TARGET="${1:-1}"
FOCUS=false

# Only focus Chrome if explicitly requested via -f or --focus
for arg in "$@"; do
    if [ "$arg" = "-f" ] || [ "$arg" = "--focus" ]; then
        FOCUS=true
    fi
done

osascript << EOF > /dev/null 2>&1
tell application "Google Chrome"
    if (count of windows) is 0 then
        return
    end if
    
    set frontWin to front window
    set totalTabs to count of tabs of frontWin
    set currentIdx to active tab index of frontWin
    set targetInput to "$TARGET"
    
    if targetInput is "next" then
        set targetIdx to currentIdx + 1
        if targetIdx > totalTabs then set targetIdx to 1
    else if targetInput is "prev" or targetInput is "previous" then
        set targetIdx to currentIdx - 1
        if targetIdx < 1 then set targetIdx to totalTabs
    else if targetInput is "last" or targetInput is "end" then
        set targetIdx to totalTabs
    else if targetInput is "first" then
        set targetIdx to 1
    else
        try
            set targetIdx to targetInput as integer
        on error
            set targetIdx to 1
        end try
    end if
    
    -- Clamp target tab index within valid range
    if targetIdx > totalTabs then
        set targetIdx to totalTabs
    else if targetIdx < 1 then
        set targetIdx to 1
    end if
    
    set active tab index of frontWin to targetIdx
    
    if $FOCUS then
        activate
    end if
end tell
EOF

exit 0
