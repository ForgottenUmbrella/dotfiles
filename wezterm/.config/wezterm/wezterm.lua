local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font_with_fallback {
  'monospace',
}
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.8

return config
