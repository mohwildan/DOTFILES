#!/bin/bash
# ==============================================================================
# 🚀 AeroSpace Universal Gesture & CLI Controller
# Flexible wrapper supporting smart aliases, tools, and raw AeroSpace commands
# ==============================================================================

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

ACTION="${1:-next-workspace}"

case "$ACTION" in
    # --- WORKSPACE NAVIGATION ---
    next-workspace|workspace-next|next-space)
        aerospace list-workspaces --monitor all --empty no 2>/dev/null | aerospace workspace --wrap-around --stdin next 2>/dev/null
        ;;
    prev-workspace|workspace-prev|prev-space)
        aerospace list-workspaces --monitor all --empty no 2>/dev/null | aerospace workspace --wrap-around --stdin prev 2>/dev/null
        ;;
    space-back-and-forth|flip-workspace)
        aerospace workspace-back-and-forth 2>/dev/null
        ;;
    workspace|[0-9]|[a-zA-Z])
        WS="${2:-$1}"
        aerospace workspace "$WS" 2>/dev/null
        ;;

    # --- MULTI-MONITOR CONTROLS (With Auto-Mouse Follow) ---
    next-monitor|focus-next-monitor)
        aerospace focus-monitor --wrap-around next 2>/dev/null
        aerospace move-mouse window-force-center 2>/dev/null || aerospace move-mouse monitor-force-center 2>/dev/null
        ;;
    prev-monitor|focus-prev-monitor)
        aerospace focus-monitor --wrap-around prev 2>/dev/null
        aerospace move-mouse window-force-center 2>/dev/null || aerospace move-mouse monitor-force-center 2>/dev/null
        ;;
    move-to-next-monitor|move-monitor-next)
        aerospace move-node-to-monitor --wrap-around next 2>/dev/null
        aerospace move-mouse window-force-center 2>/dev/null || aerospace move-mouse monitor-force-center 2>/dev/null
        ;;
    move-to-prev-monitor|move-monitor-prev)
        aerospace move-node-to-monitor --wrap-around prev 2>/dev/null
        aerospace move-mouse window-force-center 2>/dev/null || aerospace move-mouse monitor-force-center 2>/dev/null
        ;;

    # --- LAYOUTS & SIZING ---
    fullscreen|toggle-fullscreen)
        aerospace fullscreen 2>/dev/null
        ;;
    accordion|toggle-accordion)
        aerospace layout tiles accordion 2>/dev/null
        ;;
    tiles)
        aerospace layout tiles horizontal vertical 2>/dev/null
        ;;
    all-horizontal|horizontal)
        aerospace flatten-workspace-tree 2>/dev/null
        aerospace layout h_tiles 2>/dev/null
        aerospace balance-sizes 2>/dev/null
        ;;
    all-vertical|vertical)
        aerospace flatten-workspace-tree 2>/dev/null
        aerospace layout v_tiles 2>/dev/null
        aerospace balance-sizes 2>/dev/null
        ;;
    floating|toggle-float)
        aerospace layout floating tiling 2>/dev/null
        ;;
    balance|balance-sizes)
        aerospace balance-sizes 2>/dev/null
        ;;
    flatten|reset-tree)
        aerospace flatten-workspace-tree 2>/dev/null
        ;;

    # --- DIRECTIONAL FOCUS (With Auto-Mouse Follow) ---
    focus-left)
        aerospace focus --boundaries all-monitors-outer-frame left 2>/dev/null
        aerospace move-mouse window-lazy-center 2>/dev/null
        ;;
    focus-right)
        aerospace focus --boundaries all-monitors-outer-frame right 2>/dev/null
        aerospace move-mouse window-lazy-center 2>/dev/null
        ;;
    focus-up)
        aerospace focus --boundaries all-monitors-outer-frame up 2>/dev/null
        aerospace move-mouse window-lazy-center 2>/dev/null
        ;;
    focus-down)
        aerospace focus --boundaries all-monitors-outer-frame down 2>/dev/null
        aerospace move-mouse window-lazy-center 2>/dev/null
        ;;

    # --- DIRECTIONAL MOVE WINDOW (With Auto-Mouse Follow) ---
    move-left)
        aerospace move --boundaries all-monitors-outer-frame left 2>/dev/null
        aerospace move-mouse window-lazy-center 2>/dev/null
        ;;
    move-right)
        aerospace move --boundaries all-monitors-outer-frame right 2>/dev/null
        aerospace move-mouse window-lazy-center 2>/dev/null
        ;;
    move-up)
        aerospace move --boundaries all-monitors-outer-frame up 2>/dev/null
        aerospace move-mouse window-lazy-center 2>/dev/null
        ;;
    move-down)
        aerospace move --boundaries all-monitors-outer-frame down 2>/dev/null
        aerospace move-mouse window-lazy-center 2>/dev/null
        ;;
    flip|focus-back-and-forth)
        aerospace focus-back-and-forth 2>/dev/null
        ;;
    close|close-window)
        aerospace close 2>/dev/null
        ;;

    # --- INTEGRATED TOOLS & SCRIPTS ---
    picker|hud|show-hud)
        exec /Users/mac/.dotfiles/scripts/show-space-hud.sh
        ;;
    summon-iphone|iphone)
        exec ~/.aerospace-summon-app.sh
        ;;

    # --- RAW PASSTHROUGH (Execute any AeroSpace CLI command directly) ---
    *)
        aerospace "$@" 2>/dev/null
        ;;
esac

exit 0
