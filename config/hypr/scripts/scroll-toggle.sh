#!/usr/bin/env bash
# Orta tık oto-scroll toggle

cur=$(hyprctl getoption input:scroll_method -j | jq -r '.str')

if [ "$cur" = "on_button_down" ]; then
    hyprctl eval 'hl.config({input = {scroll_method = "no_scroll"}})'
    notify-send -h string:x-canonical-private-synchronous:scroll-toggle \
        -u low -t 1500 "Fare" "Oto-Scroll: Kapalı"
else
    hyprctl eval 'hl.config({input = {scroll_method = "on_button_down", scroll_button = 274}})'
    notify-send -h string:x-canonical-private-synchronous:scroll-toggle \
        -u low -t 1500 "Fare" "Oto-Scroll: Açık"
fi
