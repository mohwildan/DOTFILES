#!/bin/bash
# ==============================================================================
# 📱 Move & Summon iPhone Mirroring Window (Without Stealing Focus)
# Positions:
#   tl | top-left
#   tc | top-center | top-middle
#   tr | top-right
#   bl | bottom-left
#   bc | bottom-center | bottom-middle
#   br | bottom-right
#   cycle | next
# ==============================================================================

export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"

POSITION="${1:-cycle}"
STATE_FILE="/tmp/iphone_mirror_pos.state"

# 1. Bring iPhone Mirroring into the current AeroSpace workspace so it never gets hidden
FOCUSED_WS=$(aerospace list-workspaces --focused 2>/dev/null)
if [ -n "$FOCUSED_WS" ]; then
    IPHONE_WIN_ID=$(aerospace list-windows --monitor all --app-bundle-id com.apple.ScreenContinuity --format "%{window-id}" 2>/dev/null | head -n 1)
    if [ -n "$IPHONE_WIN_ID" ]; then
        aerospace move-node-to-workspace --window-id "$IPHONE_WIN_ID" "$FOCUSED_WS" 2>/dev/null
    fi
fi

# 2. Position the floating window at the desired screen corner
osascript <<APPLESCRIPT
tell application "Finder"
    set screenBounds to bounds of window of desktop
    set screenW to item 3 of screenBounds
    set screenH to item 4 of screenBounds
end tell

tell application "System Events"
    if not (exists process "iPhone Mirroring") then
        return "not running"
    end if

    tell process "iPhone Mirroring"
        if (count of windows) = 0 then
            return "no window"
        end if

        set win to window 1
        set winSize to size of win
        set winW to item 1 of winSize
        set winH to item 2 of winSize

        -- Padding from screen edges & top menu bar
        set padX to 16
        set padTop to 38
        set padBottom to 16

        set targetPos to "$POSITION"

        -- Cycle mode logic
        if targetPos = "cycle" or targetPos = "next" then
            set currentPos to "$POSITION"
            try
                set lastPos to do shell script "cat $STATE_FILE 2>/dev/null || echo ''"
            on error
                set lastPos to ""
            end try

            if lastPos = "tr" then
                set targetPos to "br"
            else if lastPos = "br" then
                set targetPos to "bl"
            else if lastPos = "bl" then
                set targetPos to "tl"
            else if lastPos = "tl" then
                set targetPos to "tc"
            else if lastPos = "tc" then
                set targetPos to "bc"
            else
                set targetPos to "tr"
            end if
            do shell script "echo " & quoted form of targetPos & " > $STATE_FILE"
        end if

        -- Calculate coordinates
        set newX to padX
        set newY to padTop

        if targetPos = "tl" or targetPos = "top-left" then
            set newX to padX
            set newY to padTop
        else if targetPos = "tc" or targetPos = "top-center" or targetPos = "top-middle" then
            set newX to (screenW - winW) / 2
            set newY to padTop
        else if targetPos = "tr" or targetPos = "top-right" then
            set newX to screenW - winW - padX
            set newY to padTop
        else if targetPos = "bl" or targetPos = "bottom-left" then
            set newX to padX
            set newY to screenH - winH - padBottom
        else if targetPos = "bc" or targetPos = "bottom-center" or targetPos = "bottom-middle" then
            set newX to (screenW - winW) / 2
            set newY to screenH - winH - padBottom
        else if targetPos = "br" or targetPos = "bottom-right" then
            set newX to screenW - winW - padX
            set newY to screenH - winH - padBottom
        end if

        set position of win to {newX, newY}
        return "moved to " & targetPos
    end tell
end tell
APPLESCRIPT
