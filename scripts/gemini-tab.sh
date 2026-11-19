#!/bin/bash
# ==============================================================================
# Gemini Tab Navigator (macOS)
# Navigasi cepat dan presisi KHUSUS antar tab Google Gemini di Chrome
# Mendukung AeroSpace Window Manager & multi-window Chrome secara otomatis
#
# Usage:
#   gemini-tab.sh next            # Pindah ke tab Gemini berikutnya
#   gemini-tab.sh prev            # Pindah ke tab Gemini sebelumnya
#   gemini-tab.sh <angka>         # Lompat langsung ke tab Gemini ke-N (1, 2, 3...)
#   gemini-tab.sh first           # Lompat ke tab Gemini pertama (Batch 1)
#   gemini-tab.sh last            # Lompat ke tab Gemini terakhir
#   gemini-tab.sh move-right      # Geser urutan tab Gemini ke kanan
#   gemini-tab.sh move-left       # Geser urutan tab Gemini ke kiri
#   gemini-tab.sh next -f         # Pindah tab sekaligus fokuskan window Gemini
# ==============================================================================

TARGET="next"
FOCUS=false

for arg in "$@"; do
    if [ "$arg" = "-f" ] || [ "$arg" = "--focus" ]; then
        FOCUS=true
    elif [ "$arg" = "-b" ] || [ "$arg" = "--background" ]; then
        FOCUS=false
    elif [ -n "$arg" ]; then
        TARGET="$arg"
    fi
done

# Jika focus diminta, arahkan fokus AeroSpace ke window Gemini
if [ "$FOCUS" = "true" ]; then
    AEROSPACE_BIN="$(command -v aerospace || echo "/opt/homebrew/bin/aerospace")"
    if [ -x "$AEROSPACE_BIN" ]; then
        GEMINI_AERO_ID=$("$AEROSPACE_BIN" list-windows --all --format "%{window-id} | %{app-name} | %{window-title}" 2>/dev/null | grep -i "Google Chrome" | grep -i "Gemini" | head -n 1 | awk '{print $1}')
        if [ -n "$GEMINI_AERO_ID" ]; then
            "$AEROSPACE_BIN" focus --window-id "$GEMINI_AERO_ID" >/dev/null 2>&1
        fi
    fi
fi

osascript << EOF > /dev/null 2>&1
tell application "Google Chrome"
    if (count of windows) is 0 then
        return "No Chrome windows"
    end if
    
    -- Cari window yang memuat tab Gemini terbanyak secara akurat
    set targetWin to missing value
    set geminiIndices to {}
    
    repeat with w in windows
        set gList to {}
        repeat with i from 1 to (count of tabs of w)
            set u to URL of (tab i of w)
            if u contains "gemini.google.com" then
                set end of gList to i
            end if
        end repeat
        if (count of gList) > (count of geminiIndices) then
            set geminiIndices to gList
            set targetWin to w
        end if
    end repeat
    
    if targetWin is missing value or (count of geminiIndices) is 0 then
        return "No Gemini tabs found"
    end if
    
    set currentIdx to active tab index of targetWin
    set totalGemini to count of geminiIndices
    set targetInput to "$TARGET"
    set targetGeminiPos to 1
    
    -- Cari posisi tab aktif saat ini di antara tab-tab Gemini
    set currentGeminiPos to 0
    repeat with pos from 1 to totalGemini
        if (item pos of geminiIndices) is currentIdx then
            set currentGeminiPos to pos
            exit repeat
        end if
    end repeat
    
    -- Perintah memindahkan posisi fisik tab
    if targetInput is "move-next" or targetInput is "move-right" then
        tell targetWin
            if currentIdx < (count of tabs) then
                move tab currentIdx to after tab (currentIdx + 1)
            end if
        end tell
        if $FOCUS then activate
        return "Moved tab right"
    else if targetInput is "move-prev" or targetInput is "move-left" then
        tell targetWin
            if currentIdx > 1 then
                move tab currentIdx to before tab (currentIdx - 1)
            end if
        end tell
        if $FOCUS then activate
        return "Moved tab left"
    end if
    
    -- Perintah berpindah tab (next, prev, nomor batch)
    if targetInput is "next" then
        if currentGeminiPos is 0 then
            set targetGeminiPos to 1
        else
            set targetGeminiPos to currentGeminiPos + 1
            if targetGeminiPos > totalGemini then set targetGeminiPos to 1
        end if
    else if targetInput is "prev" or targetInput is "previous" then
        if currentGeminiPos is 0 then
            set targetGeminiPos to totalGemini
        else
            set targetGeminiPos to currentGeminiPos - 1
            if targetGeminiPos < 1 then set targetGeminiPos to totalGemini
        end if
    else if targetInput is "first" then
        set targetGeminiPos to 1
    else if targetInput is "last" then
        set targetGeminiPos to totalGemini
    else
        try
            set reqNum to targetInput as integer
            if reqNum < 1 then
                set targetGeminiPos to 1
            else if reqNum > totalGemini then
                set targetGeminiPos to totalGemini
            else
                set targetGeminiPos to reqNum
            end if
        on error
            set targetGeminiPos to 1
        end try
    end if
    
    set chosenChromeTab to item targetGeminiPos of geminiIndices
    set active tab index of targetWin to chosenChromeTab
    
    -- Pastikan window berada di layar jika sempat terparkir offscreen oleh AeroSpace
    set winBounds to bounds of targetWin
    if item 1 of winBounds < 0 then
        set bounds of targetWin to {0, 30, 1440, 900}
    end if
    set index of targetWin to 1
    
    if $FOCUS then
        activate
    end if
    
    return "Gemini Tab " & targetGeminiPos & " of " & totalGemini
end tell
EOF
exit 0
