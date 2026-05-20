-- Override colour scheme to use a transparent background.

---Modify an existing highlight group without completely replacing it.
local function mod_hl(hl_name, opts)
  local old_hl = vim.api.nvim_get_hl(0, { name = hl_name })
  local new_hl = vim.tbl_extend('force', old_hl, opts)
  vim.api.nvim_set_hl(0, hl_name, new_hl)
end

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
  mod_hl('Normal', { ctermbg = 'NONE', bg = 'NONE' })
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
      vim.log.levels.WARN
    )
  end
end, { desc = 'Toggle background' })

vim.api.nvim_create_autocmd({ 'ColorSchemePre' }, {
  group = my.augroup,
  desc = 'Reset background option',
  callback = function()
    -- Reset background option so that dynamic colour schemes follow the
    -- terminal's light/dark mode setting instead of whatever the previous
    -- colour scheme overrode the option to be.
    vim.opt.background = my.term_bg
  end,
})

vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
  group = my.augroup,
  desc = 'Make background transparent',
  callback = clear_bg,
})

-- Only set colour scheme after setting up the autocommand
vim.cmd.colorscheme(my.term_bg == 'light' and 'wildcharm' or 'habamax')
