#!/bin/bash
# IPA Extension Controller — System-wide shortcut bridge for Google Chrome
# Works with YouTube, Netflix, Coursera, Udemy, Vimeo, Bilibili, and any HTML5 video!
# Usage: ./ipa-control.sh [action]
# Actions:
#   save-caption  : Triggers the caption word picker for active video subtitles
#   play-pause    : Toggles video play/pause on active/playing video
#   rewind        : Rewinds video 10s
#   forward       : Forwards video 10s
#   translate     : Translates current text selection
#   select-element: Toggles element selection mode

ACTION="${1:-save-caption}"

osascript << EOF
tell application "Google Chrome"
    set targetTab to null
    set targetWindow to null
    
    -- Priority 1: Check active tab of front window (where the user currently is)
    if (count of windows) > 0 then
        set frontTab to active tab of front window
        set hasMedia to false
        try
            set checkRes to execute frontTab javascript "(function() { return !!(document.querySelector('video') || document.querySelector('iframe') || document.querySelector('[class*=\"player\"]') || document.querySelector('[id*=\"player\"]')); })()"
            if checkRes is "true" or checkRes is true then
                set hasMedia to true
            end if
        end try
        
        -- If current tab has a video or iframe player, ALWAYS stay on this tab!
        if hasMedia then
            set targetTab to frontTab
            set targetWindow to front window
        end if
    end if
    
    -- Priority 2: Only if current tab has no video/player, search for an actively playing video in background
    if targetTab is null and (count of windows) > 0 then
        repeat with w in windows
            repeat with t in tabs of w
                try
                    set isPlaying to execute t javascript "(function() { const v = document.querySelector('video'); return !!(v && !v.paused && v.currentTime > 0); })()"
                    if isPlaying is "true" or isPlaying is true then
                        set targetTab to t
                        set targetWindow to w
                        exit repeat
                    end if
                end try
            end repeat
            if targetTab is not null then exit repeat
        end repeat
    end if
    
    -- Priority 3: Fallback to the active tab of the front window (never switch tabs unexpectedly!)
    if targetTab is null and (count of windows) > 0 then
        set targetTab to active tab of front window
        set targetWindow to front window
    end if
    
    if targetTab is null then
        return "No Chrome window or video tab found"
    end if
    
    -- Perform requested action
    if "$ACTION" is "save-caption" or "$ACTION" is "save" or "$ACTION" is "caption" then
        execute targetTab javascript "(function() { window.dispatchEvent(new CustomEvent('ipa-quick-save-caption')); const fs = document.querySelectorAll('iframe'); for (let i = 0; i < fs.length; i++) { try { fs[i].contentWindow.postMessage({ type: 'IPA_VIDEO_ACTION', action: 'save-caption' }, '*'); } catch(e) {} } })();"
        return "Opened Caption Picker"
        
    else if "$ACTION" is "play-pause" or "$ACTION" is "play" or "$ACTION" is "toggle" then
        execute targetTab javascript "(function() { window.dispatchEvent(new CustomEvent('ipa-video-play-pause')); const v = document.querySelector('video'); if (v) { if (v.paused) v.play(); else v.pause(); } const fs = document.querySelectorAll('iframe'); for (let i = 0; i < fs.length; i++) { try { fs[i].contentWindow.postMessage({ type: 'IPA_VIDEO_ACTION', action: 'play-pause' }, '*'); } catch(e) {} } })();"
        return "Toggled Play/Pause"
        
    else if "$ACTION" is "rewind" or "$ACTION" is "back" or "$ACTION" is "prev" then
        execute targetTab javascript "(function() { window.dispatchEvent(new CustomEvent('ipa-video-rewind')); const fs = document.querySelectorAll('iframe'); for (let i = 0; i < fs.length; i++) { try { fs[i].contentWindow.postMessage({ type: 'IPA_VIDEO_ACTION', action: 'rewind' }, '*'); } catch(e) {} } })();"
        return "Rewound Subtitle"
        
    else if "$ACTION" is "forward" or "$ACTION" is "next" then
        execute targetTab javascript "(function() { window.dispatchEvent(new CustomEvent('ipa-video-forward')); const fs = document.querySelectorAll('iframe'); for (let i = 0; i < fs.length; i++) { try { fs[i].contentWindow.postMessage({ type: 'IPA_VIDEO_ACTION', action: 'forward' }, '*'); } catch(e) {} } })();"
        return "Forwarded Subtitle"
        
    else if "$ACTION" is "translate" or "$ACTION" is "translate-selection" then
        activate
        tell targetWindow to set index to 1
        execute targetTab javascript "window.dispatchEvent(new CustomEvent('ipa-translate-selection'));"
        return "Translating Selection"
        
    else if "$ACTION" is "select-element" or "$ACTION" is "element" then
        activate
        tell targetWindow to set index to 1
        execute targetTab javascript "window.dispatchEvent(new CustomEvent('ipa-reader-enable-selection'));"
        return "Enabled Element Selection"
        
    else
        return "Unknown action: $ACTION"
    end if
end tell
EOF
