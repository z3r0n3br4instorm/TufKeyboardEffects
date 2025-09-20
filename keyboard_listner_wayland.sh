#!/bin/bash

# This script listens for various key combinations and changes the keyboard backlight color.
# It must be run with sudo.

# --- Configuration ---
KBD_DEVICE="asus::kbd_backlight"
# The input event device for your keyboard.
INPUT_DEVICE="/dev/input/event3"
# Define RGB values for different colors
# Format is: ? ? R G B ?
DEFAULT_COLOR="0 0 0 220 255 1"  # Default white-ish (actually bluish-cyan)
RED_COLOR="0 0 255 0 0 1"      # Red for backspace
YELLOW_COLOR="0 0 255 255 0 1" # Yellow for Ctrl+C
GREEN_COLOR="0 0 0 255 0 1"    # Green for Ctrl+V
ORANGE_COLOR="0 0 255 165 0 1" # Orange for Ctrl+Z
PURPLE_COLOR="0 0 128 0 128 1"   # Purple for Tab
WHITE_COLOR="0 0 255 255 255 1" # White for Ctrl+S
# --- End Configuration ---

cleanup() {
    echo "Exiting listener. Resetting keyboard color."
    echo "$DEFAULT_COLOR" | sudo -n /usr/bin/tee "/sys/class/leds/$KBD_DEVICE/kbd_rgb_mode" >/dev/null
    exit 0
}

trap cleanup SIGINT SIGTERM

# Function to blink the keyboard backlight
blink_light_blue() {
    current_brightness=$(brightnessctl -d "$KBD_DEVICE" g)
    max_brightness=$(brightnessctl -d "$KBD_DEVICE" m)
    echo "$GREEN_COLOR" | sudo -n /usr/bin/tee "/sys/class/leds/$KBD_DEVICE/kbd_rgb_mode" >/dev/null

    # Blink twice
    for i in {1..2}; do
        brightnessctl -d "$KBD_DEVICE" s 0
        sleep 0.05
        brightnessctl -d "$KBD_DEVICE" s "$max_brightness"
        sleep 0.05
    done
    echo "$DEFAULT_COLOR" | sudo -n /usr/bin/tee "/sys/class/leds/$KBD_DEVICE/kbd_rgb_mode" >/dev/null
    # Restore original brightness
    brightnessctl -d "$KBD_DEVICE" s "$current_brightness"
}

# Function to blink the keyboard backlight red
red_blink() {
    echo "$RED_COLOR" | sudo -n /usr/bin/tee "/sys/class/leds/$KBD_DEVICE/kbd_rgb_mode" >/dev/null
    sleep 0.1
    echo "$DEFAULT_COLOR" | sudo -n /usr/bin/tee "/sys/class/leds/$KBD_DEVICE/kbd_rgb_mode" >/dev/null
}

# Function to blink the keyboard backlight yellow
yellow_blink() {
    echo "$YELLOW_COLOR" | sudo -n /usr/bin/tee "/sys/class/leds/$KBD_DEVICE/kbd_rgb_mode" >/dev/null
    sleep 0.1
    echo "$DEFAULT_COLOR" | sudo -n /usr/bin/tee "/sys/class/leds/$KBD_DEVICE/kbd_rgb_mode" >/dev/null
}

# Function to blink the keyboard backlight green
green_blink() {
    echo "$GREEN_COLOR" | sudo -n /usr/bin/tee "/sys/class/leds/$KBD_DEVICE/kbd_rgb_mode" >/dev/null
    sleep 0.1
    echo "$DEFAULT_COLOR" | sudo -n /usr/bin/tee "/sys/class/leds/$KBD_DEVICE/kbd_rgb_mode" >/dev/null
}

# Function to blink the keyboard backlight orange
orange_blink() {
    echo "$ORANGE_COLOR" | sudo -n /usr/bin/tee "/sys/class/leds/$KBD_DEVICE/kbd_rgb_mode" >/dev/null
    sleep 0.1
    echo "$DEFAULT_COLOR" | sudo -n /usr/bin/tee "/sys/class/leds/$KBD_DEVICE/kbd_rgb_mode" >/dev/null
}

# Function to blink the keyboard backlight purple
purple_blink() {
    echo "$PURPLE_COLOR" | sudo -n /usr/bin/tee "/sys/class/leds/$KBD_DEVICE/kbd_rgb_mode" >/dev/null
    sleep 0.1
    echo "$DEFAULT_COLOR" | sudo -n /usr/bin/tee "/sys/class/leds/$KBD_DEVICE/kbd_rgb_mode" >/dev/null
}

# Function to blink the keyboard backlight white
white_blink() {
    echo "$WHITE_COLOR" | sudo -n /usr/bin/tee "/sys/class/leds/$KBD_DEVICE/kbd_rgb_mode" >/dev/null
    sleep 0.1
    echo "$DEFAULT_COLOR" | sudo -n /usr/bin/tee "/sys/class/leds/$KBD_DEVICE/kbd_rgb_mode" >/dev/null
}

echo "Listening for key presses on $INPUT_DEVICE... Press Ctrl+C to stop."
echo "$DEFAULT_COLOR" | sudo -n /usr/bin/tee "/sys/class/leds/$KBD_DEVICE/kbd_rgb_mode" >/dev/null

# Use evtest to listen for key press events.
stdbuf -o0 evtest "$INPUT_DEVICE" |
(
    ctrl_pressed=0
    while read -r line; do
        if echo "$line" | grep -q "type 4 (EV_MSC)" ; then
            continue
        fi
        if echo "$line" | grep -q "code 29 (KEY_LEFTCTRL), value 1"; then
            ctrl_pressed=1
        fi
        if echo "$line" | grep -q "code 29 (KEY_LEFTCTRL), value 0"; then
            ctrl_pressed=0
        fi

        if [[ $ctrl_pressed -eq 1 ]]; then
            if echo "$line" | grep -q "code 46 (KEY_C), value 1"; then
                yellow_blink &
            elif echo "$line" | grep -q "code 47 (KEY_V), value 1"; then
                green_blink &
            elif echo "$line" | grep -q "code 44 (KEY_Z), value 1"; then
                orange_blink &
            elif echo "$line" | grep -q "code 31 (KEY_S), value 1"; then
                white_blink &
            fi
        fi

        if echo "$line" | grep -q "code 28 (KEY_ENTER), value 1"; then
            blink_light_blue &
        elif echo "$line" | grep -q "code 14 (KEY_BACKSPACE), value 1"; then
            red_blink &
        elif echo "$line" | grep -q "code 15 (KEY_TAB), value 1"; then
            purple_blink &
        fi
    done
)