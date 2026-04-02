#!/bin/bash

GPU_PATH="/sys/class/drm/card0/device/gpu_busy_percent"

if [ -r "$GPU_PATH" ]; then
    usage=$(/usr/bin/cat "$GPU_PATH")
    printf '{"text":"%s%%","class":"connected"}\n' "$usage"
else
    printf '{"text":"","class":"disconnected"}\n'
fi
