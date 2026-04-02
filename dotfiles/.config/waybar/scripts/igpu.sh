#!/bin/bash

GPU_PATH="/sys/class/drm/card1/device/gpu_busy_percent"

if [ -r "$GPU_PATH" ]; then
    /usr/bin/cat "$GPU_PATH" | /usr/bin/awk '{print $1 "%"}'
fi
