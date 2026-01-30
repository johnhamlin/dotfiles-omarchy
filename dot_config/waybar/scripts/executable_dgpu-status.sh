#!/bin/bash

# Safe dGPU status script - does NOT wake or keep GPU awake
# Uses sysfs and /proc fd scanning ONLY - nvidia-smi keeps GPU active and prevents suspension

DGPU_PCI="0000:01:00.0"
RUNTIME_STATUS="/sys/bus/pci/devices/$DGPU_PCI/power/runtime_status"
STATUS=$(cat "$RUNTIME_STATUS" 2>/dev/null)

# Known passive GPU openers (compositor/system infrastructure)
# These open ALL GPUs on Wayland even when not actively rendering
PASSIVE_PROCS="Hyprland|swayosd|walker|xdg-desktop|pipewire|gjs|gnome-shell|kwin|mutter"

get_gpu_processes() {
    local active_procs=""
    local passive_count=0
    local seen_pids=""

    for pid_dir in /proc/[0-9]*/fd; do
        pid="${pid_dir%/fd}"
        pid="${pid##/proc/}"

        # Skip if already seen this pid
        case "$seen_pids" in
            *":$pid:"*) continue ;;
        esac

        # Check if process has nvidia devices open
        if ls -la "$pid_dir" 2>/dev/null | grep -qE 'nvidia|renderD129'; then
            name=$(cat "/proc/$pid/comm" 2>/dev/null)
            if [ -n "$name" ]; then
                seen_pids="$seen_pids:$pid:"
                if echo "$name" | grep -qE "$PASSIVE_PROCS"; then
                    ((passive_count++))
                else
                    active_procs="$active_procs• $name\n"
                fi
            fi
        fi
    done

    echo -e "$active_procs"
    echo "PASSIVE:$passive_count"
}

if [ "$STATUS" = "suspended" ]; then
    echo '{"text": "󰾂", "tooltip": "dGPU suspended (saving power)", "class": "suspended"}'
else
    RESULT=$(get_gpu_processes)
    PROCS=$(echo "$RESULT" | grep -v "^PASSIVE:" | grep -v "^$")
    PASSIVE=$(echo "$RESULT" | grep "^PASSIVE:" | cut -d: -f2)

    TOOLTIP="dGPU active"
    if [ -n "$PROCS" ]; then
        TOOLTIP="$TOOLTIP\n\nLikely using GPU:\n$PROCS"
    fi
    if [ "$PASSIVE" -gt 0 ] 2>/dev/null; then
        TOOLTIP="$TOOLTIP\n(+$PASSIVE compositor/system)"
    fi

    # Escape for JSON and convert newlines
    TOOLTIP=$(echo -e "$TOOLTIP" | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')
    echo "{\"text\": \"󰾅\", \"tooltip\": \"$TOOLTIP\", \"class\": \"active\"}"
fi
