#!/bin/sh
# Retrieve MPRIS data.
# From https://github.com/Alexays/Waybar/wiki/Module:-Custom.
playerctl -a metadata --format \
    '{
        "text": "{{artist}} - {{markup_escape(title)}}",
        "tooltip": "{{markup_escape(title)}} ({{playerName}})",
        "alt": "{{status}}",
        "class": "{{status}}"
    }' \
    -F | jq --unbuffered --compact-output
