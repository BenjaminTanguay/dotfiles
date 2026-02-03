# Setup all workspaces with 2 Ghostty windows each (if < 2 exist)
function tsetup() {
    local titles=(
        "WS1 - Main Ticket"
        "WS2 - Secondary"
        "WS3 - Prototyping"
        "WS4 - Side Project"
        "WS5 - Team Tools"
    )

    # Create all windows first
    for ws in 1 2 3 4 5; do
        local count=$(aerospace list-windows --workspace "$ws" --app-bundle-id com.mitchellh.ghostty --count 2>/dev/null)
        local needed=$((2 - count))
        if (( needed > 0 )); then
            echo "Workspace $ws: $count windows, creating $needed..."
            for ((j = 0; j < needed; j++)); do
                open -na Ghostty --args --title="${titles[$ws]}"
                sleep 0.3
            done
        else
            echo "Workspace $ws: $count windows, skipping"
        fi
    done

    # Wait for all windows to be ready
    echo "Waiting for windows to initialize..."
    sleep 2

    # Now move windows based on their titles (must use --monitor all to see all windows)
    echo "Moving windows to correct workspaces..."
    aerospace list-windows --monitor all --app-bundle-id com.mitchellh.ghostty --format '%{window-id}|%{window-title}' 2>/dev/null | while IFS='|' read -r win_id win_title; do
        local target_ws=""
        case "$win_title" in
            *WS1*) target_ws="1" ;;
            *WS2*) target_ws="2" ;;
            *WS3*) target_ws="3" ;;
            *WS4*) target_ws="4" ;;
            *WS5*) target_ws="5" ;;
        esac

        if [[ -n "$target_ws" ]]; then
            echo "  Moving window $win_id to workspace $target_ws"
            aerospace move-node-to-workspace "$target_ws" --window-id "$win_id" 2>/dev/null
            aerospace layout --window-id "$win_id" tiling 2>/dev/null
        fi
    done

    # Flatten and balance all workspaces to fix tiling
    echo "Fixing layout for all workspaces..."
    for ws in 1 2 3 4 5; do
        aerospace flatten-workspace-tree --workspace "$ws" 2>/dev/null
        aerospace balance-sizes --workspace "$ws" 2>/dev/null
    done

    echo "Done. Use alt+1 through alt+5 to navigate workspaces."
}