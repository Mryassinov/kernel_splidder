#!/bin/bash
for device in sweet tucana toco phoenix davinci; do
    echo "Building $device..."
    ./build.sh -c "$device" || echo "Failed: $device"
done
