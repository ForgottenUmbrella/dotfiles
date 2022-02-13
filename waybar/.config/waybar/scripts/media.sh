#!/bin/sh
# Retrieve MPRIS data.
# From https://github.com/Alexays/Waybar/wiki/Module:-Custom.
playerctl -aF metadata --format \
    '{
        "text": "{{artist}} - {{markup_escape(title)}}",
        "tooltip": "{{markup_escape(title)}} ({{playerName}})",
        "alt": "{{status}}",
        "class": "{{status}}"
    }' |
    sed -e 's/" - /"/' -e 's/ - "/"/' -e 's/" //' |
    jq --unbuffered --compact-output
