#!/bin/bash
KBD_DEVICE="asus::kbd_backlight"
RED_COLOR="0 0 255 0 0 1"
DEFAULT_COLOR="0 0 0 220 255 1"

echo "$RED_COLOR" | sudo -n /usr/bin/tee "/sys/class/leds/$KBD_DEVICE/kbd_rgb_mode" >/dev/null
sleep 0.2
echo "$DEFAULT_COLOR" | sudo -n /usr/bin/tee "/sys/class/leds/$KBD_DEVICE/kbd_rgb_mode" >/dev/null
