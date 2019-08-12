# Bootstrap fisher.
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end

# Key bindings.
bind \ck -M insert history-search-backward
bind \cj -M insert history-search-forward
# Avoid Emacs shell error messages about missing key bindings;
# call this yourself if bindings are wrong.
#fish_hybrid_key_bindings

# Disable greeting.
function fish_greeting
end

# Colours.
if test -e ~/.cache/wal/colors.fish
    source ~/.cache/wal/colors.fish
end
