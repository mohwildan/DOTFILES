-- ==================================
-- CONFIG
-- ==================================
local hyper = {"ctrl", "alt", "shift", "cmd"}
local currentTarget = "chrome"
local scrollTimer = nil

local SCROLL_SPEED = 140
local SCROLL_INTERVAL = 0.04

-- ==================================
-- ALERT
-- ==================================
local function showTargetAlert()
    local name = currentTarget == "chrome" and "Chrome / Web" or "Obsidian"
    hs.alert.closeAll()
    hs.alert.show("Target: " .. name, 0.6)
end

-- ==================================
-- THE ULTIMATE CHROME SCROLL
-- ==================================
local function scrollChrome(distance)
    local script = [[
        tell application "Google Chrome"
            if not (exists front window) then return
            execute front window's active tab javascript "
                (function () {
                    const url = location.href;

                    // 1. TIKTOK FIX
                    if (url.includes('tiktok.com')) {
                        const evt = new WheelEvent('wheel', {
                            deltaY: ]] .. (distance > 0 and "450" or "-450") .. [[,
                            bubbles: true, cancelable: true
                        });
                        document.dispatchEvent(evt);
                        return;
                    }

                    // 2. FIND SCROLLABLE TARGET
                    const getTarget = () => {
                        // Priority A: YouTube (Paksa Main Page)
                        if (url.includes('youtube.com') && !url.includes('shorts')) {
                            return document.scrollingElement || window;
                        }

                        // Priority B: Elemen tepat di bawah Mouse (Paling Akurat untuk Sidebar vs Content)
                        const hoveredEls = document.querySelectorAll(':hover');
                        for (let i = hoveredEls.length - 1; i >= 0; i--) {
                            const el = hoveredEls[i];
                            const style = getComputedStyle(el);
                            const isScrollable = el.scrollHeight > el.clientHeight &&
                                               (style.overflowY === 'auto' || style.overflowY === 'scroll');
                            if (isScrollable) return el;
                        }

                        // Priority C: AI Chat Containers (ChatGPT/Gemini)
                        const aiSelectors = ['main', 'div[class*=\"react-scroll-to-bottom\"]', 'article', '.chat-history'];
                        for (let s of aiSelectors) {
                            const el = document.querySelector(s);
                            if (el && el.scrollHeight > el.clientHeight) return el;
                        }

                        // Priority D: Default
                        return document.scrollingElement || window;
                    };

                    // 3. EXECUTE
                    const target = getTarget();
                    target.scrollBy({
                        top: ]] .. distance .. [[,
                        behavior: 'smooth'
                    });
                })();
            "
        end tell
    ]]
    hs.applescript.applescript(script)
end

-- ==================================
-- OBSIDIAN SCROLL
-- ==================================
local function scrollObsidian(distance)
    local obsidian = hs.application.get("md.obsidian")
    if not obsidian then return end
    local dir = distance > 0 and -4 or 4 -- Speed sedikit ditambah untuk Obsidian
    hs.eventtap.event.newScrollEvent({0, dir}, {}, "line"):post(obsidian)
end

-- ==================================
-- ENGINE
-- ==================================
local function routeScroll(distance)
    if currentTarget == "chrome" then
        scrollChrome(distance)
    elseif currentTarget == "obsidian" then
        scrollObsidian(distance)
    end
end

local function startScroll(distance)
    if scrollTimer then return end
    routeScroll(distance)
    scrollTimer = hs.timer.doEvery(SCROLL_INTERVAL, function() routeScroll(distance) end)
end

local function stopScroll()
    if scrollTimer then scrollTimer:stop(); scrollTimer = nil end
end

-- ==================================
-- BINDINGS
-- ==================================
hs.hotkey.bind(hyper, "h", function() currentTarget = "chrome"; showTargetAlert() end)
hs.hotkey.bind(hyper, "l", function() currentTarget = "obsidian"; showTargetAlert() end)
hs.hotkey.bind(hyper, "j", function() startScroll(SCROLL_SPEED) end, stopScroll)
hs.hotkey.bind(hyper, "k", function() startScroll(-SCROLL_SPEED) end, stopScroll)

hs.alert.show("All-In-One Scroll Active", 1)

-- ==================================
-- TOGGLE DOCK (HAMMERSPOON)
-- ==================================
hs.hotkey.bind(hyper, "2", function()
    local _, status = hs.applescript.applescript([[
        tell application "System Events"
            set autohideStatus to autohide menu bar of dock preferences
            set autohide menu bar of dock preferences to not autohideStatus
        end tell
    ]])
    hs.alert.show("Dock Toggled", 0.5)
end)

hs.hotkey.bind(hyper, "1", function()
    local _, status = hs.applescript.applescript([[
        tell application "System Events"
            tell dock preferences
                set isAutohide to autohide
                set autohide to not isAutohide
            end tell
        end tell
    ]])
    hs.alert.show("Dock Toggled", 0.5)
end)