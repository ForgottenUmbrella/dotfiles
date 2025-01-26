local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font_with_fallback {
  'monospace',
}
config.hide_tab_bar_if_only_one_tab = true
config.keys = {
  {
    mods = 'ALT',
    key = 's',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    mods = 'ALT|SHIFT',
    key = 's',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    mods = 'ALT',
    key = 'w',
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },
  {
    mods = 'SUPER',
    key = 'w',
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },
  {
    mods = 'ALT',
    key = 'h',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    mods = 'ALT',
    key = 'j',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
  {
    mods = 'ALT',
    key = 'k',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    mods = 'ALT',
    key = 'l',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
}
config.window_background_opacity = 0.8
config.window_close_confirmation = 'NeverPrompt'

return config
