#!/bin/bash

# CPU usage (average across cores)
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | awk '{printf "%.0f", $1}')

# RAM usage (used / total)
# RAM: Parse /proc/meminfo (like fastfetch does)
MEM_TOTAL_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM_AVAILABLE_KB=$(grep MemAvailable /proc/meminfo | awk '{print $2}')

# If MemAvailable is missing (old kernels), fall back to approximation
if [ -z "$MEM_AVAILABLE_KB" ]; then
    MEM_FREE_KB=$(grep MemFree /proc/meminfo | awk '{print $2}')
    BUFFERS_KB=$(grep Buffers /proc/meminfo | awk '{print $2}')
    CACHED_KB=$(grep -E 'Cached|SReclaimable' /proc/meminfo | awk '{sum += $2} END {print sum}')
    MEM_AVAILABLE_KB=$((MEM_FREE_KB + BUFFERS_KB + CACHED_KB))
fi

# Calculate used RAM in KiB
MEM_USED_KB=$((MEM_TOTAL_KB - MEM_AVAILABLE_KB))

# Convert to GiB with 1 decimal place using awk
RAM_USED=$(awk -v used="$MEM_USED_KB" 'BEGIN {printf "%.1f", used / 1024 / 1024}')
RAM_TOTAL=$(awk -v total="$MEM_TOTAL_KB" 'BEGIN {printf "%.1f", total / 1024 / 1024}')


# GPU usage - detects NVIDIA or AMD/Intel
if command -v nvidia-smi >/dev/null 2>&1; then
    GPU=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk '{print $1}')
    GPU_NAME="NVIDIA"
elif [ -d /sys/class/drm/card0 ] || [ -d /sys/class/drm/card1 ]; then
    # AMD/Intel via sysfs (amdgpu or i915 driver)
    for card in /sys/class/drm/card?; do
        if [ -f "$card/gt/gt0/radeon_pm_info" ] || [ -f "$card/device/gpu_busy_percent" ]; then
            GPU=$(cat "$card/device/gpu_busy_percent" 2>/dev/null || cat "$card/gt/gt0/radeon_pm_info" | grep "sclk" | awk '{print $NF}' | tr -d '%')
            GPU_NAME="AMD/Intel"
            break
        fi
    done
    GPU=${GPU:-0}
else
    GPU="N/A"
    GPU_NAME="Unknown"
fi

# Output JSON
echo "{\"text\": \"󰍛\", \"tooltip\": \"CPU: ${CPU}%\\nRAM: ${RAM_USED} GiB / ${RAM_TOTAL} GiB\\nGPU (${GPU_NAME}): ${GPU}%\"}"
#
# Example output
# {
#   "text": "󰍛",
#   "tooltip": "CPU: 12%\nRAM: 45%\nGPU (NVIDIA): 5%"
# }