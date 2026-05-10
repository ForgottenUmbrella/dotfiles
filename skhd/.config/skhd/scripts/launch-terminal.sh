if pgrep wezterm
then
    wezterm cli spawn --new-window
else
    osascript -e 'tell application "WezTerm" to activate'
fi
