local wezterm = require 'wezterm'
local resurrect = wezterm.plugin.require 'https://github.com/MLFlexer/resurrect.wezterm'

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
config.enable_csi_u_key_encoding = true
if wezterm.run_child_process { 'infocmp', 'wezterm' } then
  config.term = 'wezterm'
else
  wezterm.log_warn 'wezterm terminfo entry not installed; TUIs may produce rendering artifacts'
end
config.window_close_confirmation = 'NeverPrompt'

resurrect.state_manager.periodic_save()
wezterm.on('gui-startup', resurrect.state_manager.resurrect_on_gui_startup)

-- Use a user var to trigger updates from CLI
wezterm.on('user-var-changed', function(window, pane, name, value)
  if name == 'update' then
    wezterm.plugin.update_all()
  end
end)

-- Keybindings {{{1
local mod
if is_macos then
  mod = 'CMD'
  config.bypass_mouse_reporting_modifiers = 'CMD'
else
  mod = 'ALT'
end

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
    action = wezterm.action.SplitVertical {},
  },
  {
    mods = mod .. '|SHIFT',
    key = 's',
    action = wezterm.action.SplitHorizontal {},
  },
  {
    mods = mod .. '|CTRL',
    key = 's',
    action = wezterm.action.SplitPane { direction = 'Down', top_level = true },
  },
  {
    mods = mod .. '|CTRL|SHIFT',
    key = 's',
    action = wezterm.action.SplitPane { direction = 'Right', top_level = true },
  },
  {
    mods = mod .. '|CTRL',
    key = 'n',
    action = wezterm.action_callback(function(window, pane)
      pane:move_to_new_window()
    end),
  },
  {
    mods = mod .. '|CTRL',
    key = 't',
    action = wezterm.action_callback(function(window, pane)
      pane:move_to_new_tab()
    end),
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
    mods = mod,
    key = 'x',
    action = wezterm.action.PaneSelect { mode = 'SwapWithActive' },
  },
  {
    mods = mod,
    key = 'o',
    action = wezterm.action_callback(function(window, pane)
      local overrides = window:get_config_overrides() or {}
      if not overrides.window_background_opacity then
        overrides.window_background_opacity = config.window_background_opacity
      else
        overrides.window_background_opacity = nil
      end
      window:set_config_overrides(overrides)
    end),
  },
}
-- }}}

return config
-- vim: foldmethod=marker
