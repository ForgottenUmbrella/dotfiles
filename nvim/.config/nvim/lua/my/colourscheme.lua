-- Set colour scheme with a transparent background.

local term_bg = vim.opt.background:get()
local original_bg_hl

---Clear the background to use the terminal's background.
---Returns whether the operation succeeded.
local function clear_bg()
  -- Only set transparency if colour scheme matches terminal background
  if vim.opt.background:get() ~= term_bg then
    return false
  end
  original_bg_hl = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  local new_bg_hl = vim.tbl_extend('force', original_bg_hl, {
    ctermbg = 'NONE',
    bg = 'NONE',
  })
  vim.api.nvim_set_hl(0, 'Normal', new_bg_hl)
  return true
end

---Set background back to original definition from colour scheme.
local function revert_bg()
  vim.api.nvim_set_hl(0, 'Normal', original_bg_hl)
  original_bg_hl = nil
end

vim.keymap.set('n', '<Leader>tb', function()
  if original_bg_hl then
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
  callback = function()
    clear_bg()
    vim.api.nvim_set_hl(0, 'NormalFloat', { link = 'Normal' })
    local float_bg = vim.api.nvim_get_hl(0, {
      name = 'NormalFloat',
      link = false,
    }).bg
    local border_fg = vim.api.nvim_get_hl(0, {
      name = 'Type', -- Mode indicator colour from statusline
      link = false,
    }).fg
    vim.api.nvim_set_hl(0, 'FloatBorder', {
      bg = float_bg,
      fg = border_fg,
      bold = true,
    })
  end,
})

vim.api.nvim_create_autocmd({ 'VimEnter' }, {
  group = my.augroup,
  desc = 'Set colourscheme when ready',
  callback = function()
    vim.cmd.colorscheme(term_bg == 'light' and 'wildcharm' or 'habamax')
  end,
  nested = true,
})
