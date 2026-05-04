if pgrep wezterm
then
    wezterm start &
fi

osascript -e 'tell application "WezTerm" to activate'
