#!/bin/sh
# Retrieve MPRIS data.
# From https://github.com/Alexays/Waybar/wiki/Module:-Custom.
playerctl -a metadata --format \
    '{
        "text": "{{playerName}}: {{artist}} - {{markup_escape(title)}}",
        "tooltip": "{{playerName}} : {{markup_escape(title)}}",
        "alt": "{{status}}",
        "class": "{{status}}"
    }' \
    -F | jq --unbuffered --compact-output
