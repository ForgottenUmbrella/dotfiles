-- Set colour scheme with a transparent background.

local term_bg = vim.opt.background:get()
local original_hl = {}

---Modify a highlight group and remember the original definition.
---@param name string The highlight group to modify
---@param mods table The changes to apply to the highlight group
---@param override? bool Whether to completely replace the definition. Default
---false.
local function mod_hl(name, mods, override)
  original_hl[name] = vim.api.nvim_get_hl(0, { name = name })
  local full_hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  local new_hl = override and mods or vim.tbl_extend('force', full_hl, mods)
  vim.api.nvim_set_hl(0, name, new_hl)
end

---Clear the background to use the terminal's background.
---Returns whether the operation succeeded.
local function clear_bg()
  -- Only set transparency if colour scheme matches terminal background
  if vim.opt.background:get() ~= term_bg then
    return false
  end
  mod_hl('Normal', { ctermbg = 'NONE', bg = 'NONE' })
  mod_hl('NormalFloat', { link = 'Normal' }, true)
  local float_border_hl = vim.api.nvim_get_hl(0, {
    name = 'FloatBorder',
    link = false,
  })
  if float_border_hl.fg == float_border_hl.bg then
    -- Mode indicator colour from statusline
    local fg = vim.api.nvim_get_hl(0, { name = 'Type', link = false }).fg
    mod_hl('FloatBorder', {
      ctermbg = 'NONE',
      bg = 'NONE',
      fg = fg,
      bold = true,
    })
  end
  return true
end

---Set background back to original definition from colour scheme.
local function revert_bg()
  for name, def in pairs(original_hl) do
    vim.api.nvim_set_hl(0, name, def)
  end
  original_hl = {}
end

vim.keymap.set('n', '<Leader>tb', function()
  if #original_hl > 0 then
    revert_bg()
  elseif not clear_bg() then
    vim.notify(
      'Colour scheme is incompatible with terminal background',
      vim.log.levels.ERROR
    )
  end
end, { desc = 'Toggle background' })

vim.api.nvim_create_autocmd({ 'ColorSchemePre' }, {
  group = my.augroup,
  desc = 'Reset background option',
  -- Reset background option so that dynamic colour schemes follow the
  -- terminal's light/dark mode setting instead of whatever the previous
  -- colour scheme overrode the option to be.
  callback = function() vim.opt.background = term_bg end,
})

vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
  group = my.augroup,
  desc = 'Customise colourscheme',
  -- Swallow return value so it doesn't accidentally remove the autocmd
  callback = function() clear_bg() end,
})

vim.api.nvim_create_autocmd({ 'VimEnter' }, {
  group = my.augroup,
  desc = 'Set colourscheme when ready',
  callback = function()
    vim.cmd.colorscheme(term_bg == 'light' and 'wildcharm' or 'habamax')
  end,
  nested = true,
})
