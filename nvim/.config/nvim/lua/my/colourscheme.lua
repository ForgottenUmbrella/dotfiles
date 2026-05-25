-- Set colour scheme with a transparent background.

-- Use a global (static) variable that will persist across reloads
if my.term_bg == nil then
  my.term_bg = vim.opt.background:get()
end
local original_bg_hl

---Clear the background to use the terminal's background.
---Returns whether the operation succeeded.
local function clear_bg()
  -- Only set transparency if colour scheme matches terminal background
  if vim.opt.background:get() ~= my.term_bg then
    return false
  end
  original_bg_hl = vim.api.nvim_get_hl(0, { name = 'Normal' })
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
  callback = function() vim.opt.background = my.term_bg end,
})

vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
  group = my.augroup,
  desc = 'Make background transparent',
  -- Swallow return value so the autocmd doesn't get deleted
  callback = function() clear_bg() end,
})

vim.api.nvim_create_autocmd({ 'VimEnter' }, {
  group = my.augroup,
  desc = 'Set colourscheme when ready',
  callback = function()
    vim.cmd.colorscheme(my.term_bg == 'light' and 'wildcharm' or 'habamax')
  end,
  nested = true,
})
