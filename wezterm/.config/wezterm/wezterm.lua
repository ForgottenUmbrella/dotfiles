local wezterm = require 'wezterm'
local config = wezterm.config_builder()

local is_macos = wezterm.target_triple:find 'apple'

-- Appearance {{{1
-- Colour scheme {{{2
if wezterm.gui and wezterm.gui.get_appearance():find 'Light' then
  config.color_scheme = 'dayfox'
end
local scheme_def = wezterm.color.get_builtin_schemes()[config.color_scheme]
config.colors = {
  tab_bar = {
    background = scheme_def.cursor_bg,
    active_tab = {
      bg_color = scheme_def.background,
      fg_color = scheme_def.foreground,
    },
    inactive_tab = {
      bg_color = scheme_def.cursor_bg,
      fg_color = scheme_def.cursor_fg,
    },
    new_tab = {
      bg_color = scheme_def.cursor_bg,
      fg_color = scheme_def.cursor_fg,
    },
    inactive_tab_hover = {
      bg_color = scheme_def.selection_bg,
      fg_color = scheme_def.selection_fg,
    },
    new_tab_hover = {
      bg_color = scheme_def.selection_bg,
      fg_color = scheme_def.selection_fg,
    },
  },
}
config.command_palette_bg_color = scheme_def.background
config.command_palette_fg_color = scheme_def.foreground
-- }}}

if not is_macos then
  -- Apple doesn't have a monospace font alias
  config.font = wezterm.font_with_fallback {
    'monospace',
  }
end
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.window_background_opacity = 0.8
if is_macos then
  config.macos_window_background_blur = 20
end

-- Behaviour {{{1
config.window_close_confirmation = 'NeverPrompt'

-- Keybindings {{{1
local mod
if is_macos then
  mod = 'CMD'
  config.bypass_mouse_reporting_modifiers = 'CMD'
else
  mod = 'ALT'
end

wezterm.on('toggle-opacity', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if not overrides.window_background_opacity then
    overrides.window_background_opacity = config.window_background_opacity
  else
    overrides.window_background_opacity = nil
  end
  window:set_config_overrides(overrides)
end)

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
  {
    mods = mod .. '|CTRL',
    key = 't',
    action = wezterm.action.EmitEvent 'toggle-opacity',
  },
}
-- }}}

return config
-- vim: foldmethod=marker
