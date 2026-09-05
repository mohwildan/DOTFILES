#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Scroll Gemini Up
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ⬆️
# @raycast.packageName Gemini Navigation

osascript > /dev/null 2>&1 << 'EOF'
tell application "Google Chrome"
    set found to false
    set targetW to 1
    set targetIdx to 1
    set maxScore to -1
    
    set w_idx to 0
    repeat with w in windows
        set w_idx to w_idx + 1
        set t_idx to 0
        repeat with t in tabs of w
            set t_idx to t_idx + 1
            set u to URL of t
            if u contains "gemini.google.com" then
                set score to 10
                if (active tab index of w) is t_idx then set score to score + 20
                if w_idx is 1 then set score to score + 10
                if u contains "/u/" then set score to score + 15
                if score > maxScore then
                    set maxScore to score
                    set targetW to w_idx
                    set targetIdx to t_idx
                    set found to true
                end if
            end if
        end repeat
    end repeat
    
    if found then
        if (active tab index of window targetW) is not targetIdx then
            set active tab index of window targetW to targetIdx
        end if
        execute tab targetIdx of window targetW javascript "(function() { const scroller = document.querySelector('infinite-scroller.chat-history') || document.querySelector('infinite-scroller') || document.querySelector('main') || document.querySelector('.conversation-container') || document.documentElement; if (scroller) { scroller.scrollTop -= 350; scroller.dispatchEvent(new Event('scroll', { bubbles: true })); } else { window.scrollBy(0, -350); } })();"
    else if (count of windows) > 0 then
        execute active tab of front window javascript "window.scrollBy(0, -350);"
    end if
end tell
EOF
