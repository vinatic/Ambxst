#!/usr/bin/env bash

# Debug logging
exec 1> >(tee -a "/tmp/color_picker_debug.log") 2>&1
echo "--- Starting Color Picker at $(date) ---"
echo "PATH is: $PATH"

# Dependencies check
if ! command -v grim &> /dev/null || ! command -v slurp &> /dev/null || ! command -v magick &> /dev/null; then
    echo "Error: Missing dependencies"
    notify-send "Color Picker" "Error: Missing dependencies (grim, slurp, or imagemagick)" -u critical
    exit 1
fi

# Select point and capture 1x1 pixel
COORDS=$(slurp -p)
if [ -z "$COORDS" ]; then
    exit 0
fi

# Capture color info and preview
# Use a temp file for the image data to avoid re-running grim if possible, 
# but grim is fast enough. We pipe grim output to magick.
RAW_DATA=$(grim -g "$COORDS" -t ppm - | magick - -format "HEX:#%[hex:u]\nRGB:rgb(%[fx:int(r*255)], %[fx:int(g*255)], %[fx:int(b*255)])\nHSV:hsv(%[fx:int(h*360)], %[fx:int(s*100)]%, %[fx:int(v*100)]%)" info:-)

HEX=$(echo "$RAW_DATA" | grep "^HEX:" | cut -d':' -f2)
RGB=$(echo "$RAW_DATA" | grep "^RGB:" | cut -d':' -f2)
HSV=$(echo "$RAW_DATA" | grep "^HSV:" | cut -d':' -f2)

# Generate preview icon
ICON="/tmp/color_picker_preview.png"
magick -size 64x64 xc:"$HEX" "$ICON"

# Default copy (HEX)
echo -n "$HEX" | wl-copy

# Send notification with actions
# Using -u normal to ensure it stays long enough to be clicked if needed
ACTION=$(notify-send "Color Picked" "$HEX copied to clipboard" \
    -i "$ICON" \
    -a "ColorPicker" \
    -u normal \
    --action="hex=Copy HEX" \
    --action="rgb=Copy RGB" \
    --action="hsv=Copy HSV")

# Handle action
case "$ACTION" in
    "hex")
        echo -n "$HEX" | wl-copy
        notify-send "Color Picker" "HEX copied: $HEX" -i "$ICON" -u low
        ;;
    "rgb")
        echo -n "$RGB" | wl-copy
        notify-send "Color Picker" "RGB copied: $RGB" -i "$ICON" -u low
        ;;
    "hsv")
        echo -n "$HSV" | wl-copy
        notify-send "Color Picker" "HSV copied: $HSV" -i "$ICON" -u low
        ;;
esac
