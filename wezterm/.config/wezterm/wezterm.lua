local wezterm = require 'wezterm'
local config = wezterm.config_builder()

local is_macos = wezterm.target_triple:find 'apple'
local mod
if is_macos then
  mod = 'CMD'
else
  mod = 'ALT'
end

if wezterm.gui and wezterm.gui.get_appearance():find 'Light' then
  config.color_scheme = 'dayfox'
end
if not is_macos then
  -- Apple doesn't have a monospace font alias
  config.font = wezterm.font_with_fallback {
    'monospace',
  }
end
config.hide_tab_bar_if_only_one_tab = true
config.keys = {
  -- Force C-[ to map to Esc for misbehaving programs
  {
    mods = 'CTRL',
    key = '[',
    action = wezterm.action.SendString '\x1b',
  },
  {
    mods = mod,
    key = 's',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    mods = mod .. '|SHIFT',
    key = 's',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    mods = mod,
    key = 'w',
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },
  {
    mods = 'SUPER',
    key = 'w',
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },
  {
    mods = mod,
    key = 'h',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    mods = mod,
    key = 'j',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
  {
    mods = mod,
    key = 'k',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    mods = mod,
    key = 'l',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
}
config.window_background_opacity = 0.8
config.macos_window_background_blur = 20
config.window_close_confirmation = 'NeverPrompt'

return config
