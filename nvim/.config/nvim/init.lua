-- vim: foldmethod=marker
-- For reference, see `:help lua-guide`.
-- Reload with `:luafile %`.

-- Set leader key for plugin keybindings
vim.g.mapleader = ' '

-- Plugins {{{1
-- Built-in plugins {{{2
vim.cmd.packadd('nvim.difftool')
vim.cmd.packadd('nvim.undotree')
-- Disable netrw (buggy) {{{3
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

-- External plugins {{{2
-- Dependencies {{{3
vim.pack.add({
  -- Required by: neo-tree.nvim
  'https://github.com/MunifTanjim/nui.nvim',
  -- Required by: nvim-lsp-file-operations, neo-tree.nvim, neogit
  'https://github.com/nvim-lua/plenary.nvim',
  -- Required by: nvim-dap-ui
  'https://github.com/nvim-neotest/nvim-nio',
})
-- Language Server Protocol {{{3
vim.pack.add({
  'https://github.com/neovim/nvim-lspconfig',
  -- Load neo-tree first so nvim-lsp-file-operations can support it
  'https://github.com/nvim-neo-tree/neo-tree.nvim',
  'https://github.com/antosha417/nvim-lsp-file-operations',
  -- Auto-detect code style
  'https://github.com/tpope/vim-sleuth',
})
require('lsp-file-operations').setup()
-- WhichKey {{{3
-- Not nvim-mini/mini.clue (doesn't support operator-pending mode)
vim.pack.add({ 'https://github.com/folke/which-key.nvim' })
local wk = require('which-key')
wk.setup({
  icons = {
    mappings = false,
    keys = {
      Up = "<Up>",
      Down = "<Down>",
      Left = "<Left>",
      Right = "<Right>",
      C = "C-",
      M = "M-",
      S = "S-",
      CR = "<CR>",
      Esc = "<Esc>",
      ScrollWheelDown = "<ScrollDown>",
      ScrollWheelUp = "<ScrollUp>",
      BS = "<BS>",
      Space = "<Space>",
      Tab = "<Tab>",
      F1 = "<F1>",
      F2 = "<F2>",
      F3 = "<F3>",
      F4 = "<F4>",
      F5 = "<F5>",
      F6 = "<F6>",
      F7 = "<F7>",
      F8 = "<F8>",
      F9 = "<F9>",
      F10 = "<F10>",
      F11 = "<F11>",
      F12 = "<F12>",
    },
  },
})
vim.keymap.set('n', '<Leader>?', function()
  wk.show({ global = false })
end, { desc = 'Buffer Local Keymaps (which-key)' })
-- mini.nvim {{{3
vim.pack.add({
  'https://github.com/nvim-mini/mini.ai',
  'https://github.com/nvim-mini/mini.pairs',
  'https://github.com/nvim-mini/mini.sessions',
  'https://github.com/nvim-mini/mini.surround',
})
require('mini.ai').setup()
require('mini.pairs').setup()
require('mini.sessions').setup({
  autoread = true,
})
require('mini.surround').setup({
  mappings = {
    add = 'ys',
    delete = 'ds',
    find = '',
    find_left = '',
    highlight = '',
    replace = 'cs',
  },
  search_method = 'cover_or_next',
})
vim.keymap.del('x', 'ys')
vim.keymap.set('x', 'S', [[<Cmd>lua MiniSurround.add('visual')<CR>]], { silent = true })
vim.keymap.set('n', 'yss', 'ys_', { remap = true, desc = 'Surround line' })
-- Magit {{{3
vim.pack.add({ 'https://github.com/NeogitOrg/neogit' })
require('neogit').setup({
  mappings = {
    popup = {
      ["F"] = "PullPopup",
      ["p"] = "PushPopup",
      ["P"] = false,
    },
  },
})
-- Org mode {{{3
vim.pack.add({ 'https://github.com/nvim-orgmode/orgmode' })
require('orgmode').setup()
vim.lsp.enable('org')
-- Debug Adapter Protocol {{{3
vim.pack.add({
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/theHamsta/nvim-dap-virtual-text',
})
require('nvim-dap-virtual-text').setup()

-- Clean up unused plugins {{{2
local plugins_to_delete = { }
for _, plugin in ipairs(vim.pack.get()) do
  if not plugin.spec.active then
    table.insert(plugins_to_delete, plugin.spec.name)
  end
end
if #plugins_to_delete > 0 then
  print('Run :PlugClean to remove unused plugins')
end
vim.api.nvim_create_user_command('PlugClean', function()
  vim.pack.del(plugins_to_delete)
end, { desc = 'Remove unused plugins' })

-- Built-in options {{{1
-- OS/terminal integration {{{2
-- Use system C-c C-v clipboard by default (but don't override selection '*)
vim.opt.clipboard = { 'unnamedplus' }
vim.opt.ttimeoutlen = 0 -- Don't ignore Esc immediately after keypress

-- Behaviour {{{2
vim.opt.gdefault = true -- Replace all occurrences by default
-- Context-dependent case sensitivity (disable with \C flag) {{{3
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- Default indentation (overridden by file convention/editorconfig) {{{3
vim.opt.expandtab = true -- Use spaces for indentation
vim.opt.shiftwidth = 4 -- Number of spaces to indent with
vim.opt.tabstop = 4 -- Render tabs as 4 spaces wide

-- UI {{{2
-- Windows {{{3
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.title = true

-- Lines {{{3
-- Line numbers {{{4
vim.opt.number = true
vim.opt.relativenumber = true
-- Folding {{{4
vim.opt.foldlevelstart = 99 -- Start unfolded
vim.opt.foldmethod = 'syntax'
-- Scrolling {{{4
vim.opt.scrolloff = 2 -- Always show some lines above/below the cursor
-- Line length {{{4
vim.opt.colorcolumn = { 80 }
vim.opt.textwidth = 79

-- Show whitespace {{{3
vim.opt.list = true

-- Spell-check {{{3
vim.opt.spell = true
vim.opt.spelloptions = { 'camel', 'noplainbuffer' }

-- Functions {{{1
-- Modify an existing highlight group without completely replacing it {{{2
local function mod_hl(hl_name, opts)
  old_hl = vim.api.nvim_get_hl(0, { name = hl_name })
  new_hl = vim.tbl_extend('force', old_hl, opts)
  vim.api.nvim_set_hl(0, hl_name, new_hl)
end

-- Autocommands {{{1
local config_group = vim.api.nvim_create_augroup('config_group', { })

-- Override colour scheme to use a transparent background {{{2
if my_term_bg == nil then
  my_term_bg = vim.opt.background:get()
end
vim.api.nvim_create_autocmd({ 'ColorSchemePre' }, {
  group = config_group,
  pattern = '*',
  callback = function()
    -- Reset background so colour schemes that support my_term_bg stick to it
    vim.opt.background = my_term_bg
  end,
})
vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
  group = config_group,
  pattern = '*',
  callback = function()
    -- Only set transparency if the colour scheme supports my_term_bg
    if vim.opt.background:get() == my_term_bg then
      mod_hl('Normal', { ctermbg = 'NONE', bg = 'NONE' })
    end
  end,
})
-- Only set colour scheme after setting up the autocmd
if my_term_bg == 'light' then
  vim.cmd.colorscheme('wildcharm')
else
  vim.cmd.colorscheme('habamax')
end


-- Format on save {{{2
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = config_group,
  pattern = '*',
  callback = vim.lsp.buf.format,
})

-- Don't resume commenting on new lines {{{2
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  group = config_group,
  pattern = '*.lua',
  callback = function()
    vim.opt.formatoptions:remove({ 'r', 'o' })
  end,
})

-- Use :help in this file (modeline does not support keywordprg) {{{2
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  group = config_group,
  pattern = 'init.lua', -- Can't use MYVIMRC because it's a symlink
  callback = function()
    vim.opt_local.keywordprg = ':help!'
  end,
})
