local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font_with_fallback {
  'monospace',
}
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.8

-- NVIDIA doesn't work with WezTerm on Wayland.
-- https://github.com/wez/wezterm/issues/2011
config.enable_wayland = false

return config
