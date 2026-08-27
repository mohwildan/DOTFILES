#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Scroll Gemini Up
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ⬆️
# @raycast.packageName Gemini Navigation

osascript << 'EOF'
tell application "Google Chrome"
    set foundTab to false
    repeat with w in windows
        set tabIdx to 0
        repeat with t in tabs of w
            set tabIdx to tabIdx + 1
            if URL of t starts with "https://gemini.google.com" then
                if (active tab index of w) is not tabIdx then
                    set active tab index of w to tabIdx
                end if
                execute t javascript "(function() { const scroller = document.querySelector('infinite-scroller.chat-history') || document.querySelector('infinite-scroller') || document.querySelector('main') || document.querySelector('.conversation-container') || document.documentElement; if (scroller) { scroller.scrollTop -= 350; scroller.dispatchEvent(new Event('scroll', { bubbles: true })); } else { window.scrollBy(0, -350); } })();"
                set foundTab to true
                exit repeat
            end if
        end repeat
        if foundTab then exit repeat
    end repeat
    if not foundTab and (count of windows) > 0 then
        execute active tab of front window javascript "window.scrollBy(0, -350);"
    end if
end tell
EOF
