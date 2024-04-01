local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font_with_fallback {
  'monospace',
}
config.hide_tab_bar_if_only_one_tab = true
config.keys = {
  {
    mods = 'CTRL|ALT',
    key = 's',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    mods = 'CTRL|ALT|SHIFT',
    key = 's',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    mods = 'CTRL|SHIFT',
    key = 'w',
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },
  {
    mods = 'SUPER',
    key = 'w',
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },
}
config.window_background_opacity = 0.8
config.window_close_confirmation = 'NeverPrompt'

return config
