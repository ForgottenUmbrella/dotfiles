-- vim: nospell
-- For reference, see `:help lua-guide`

-- Bootstrap lazy.nvim package manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
  'git',
  'clone',
  '--filter=blob:none',
  'https://github.com/folke/lazy.nvim.git',
  '--branch=stable', -- latest stable release
  lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Packages
require('lazy').setup({
  {
    'dahu/vim-fanfingtastic',
    keys = { 'F', 'f', 'T', 't', ';', ',' },
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    init = function()
      vim.opt.timeout = true
      vim.opt.timeoutlen = 300
    end,
    opts = { },
  },
  {
    'tpope/vim-commentary',
    keys = { 'gc' },
  },
  {
    'tpope/vim-repeat',
    keys = { '.' },
  },
  {
    'tpope/vim-sleuth',
  },
  {
    'tpope/vim-surround',
    keys = { 'cs', 'ds', 'S', 'ys' },
  },
  {
    'tpope/vim-unimpaired',
    keys = { '[', ']' },
  },
  {
    'tversteeg/registers.nvim',
    keys = {
      { '\'', mode = { 'n', 'v' } },
      { '<C-R>', mode = 'i' },
    },
  },
  {
    'wellle/targets.vim',
    keys = {
      'cA', 'dA', 'yA',
      'ca', 'da', 'ya',
      'cI', 'dI', 'yI',
      'ci', 'di', 'yi',
    },
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = { },
  },
})

-- Built-in options
--- Clipboard: use system C-c C-v clipboard by default
--- (but don't override the selection clipboard '*)
vim.opt.clipboard = { 'unnamedplus' }

--- Search and replace
vim.opt.gdefault = true  -- Replace all occurrences by default
---- Context-dependent case sensitivity (disable with \C flag)
vim.opt.ignorecase = true
vim.opt.smartcase = true

--- Lines
---- Folding
vim.opt.foldlevelstart = 99  -- Start unfolded
vim.opt_global.foldmethod = 'indent'
---- Line numbers
vim.opt_global.number = true
vim.opt_global.relativenumber = true
---- Line length
vim.opt_global.colorcolumn = { 80 }
vim.opt_global.textwidth = 79
---- Scrolling
vim.opt.mousescroll = 'ver:1'
vim.opt.scrolloff = 2  -- Always show some lines above/below the cursor

--- Spell-check
vim.opt_global.spell = true

--- Whitespace
vim.opt_global.list = true  -- Show whitespace
---- Indentation
vim.opt_global.expandtab = true  -- Use spaces for indentation
vim.opt_global.shiftwidth = 4  -- Number of spaces to indent with

--- Windows
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.title = true

-- Functions
--- Modify an existing highlight group without completely overriding it
local function mod_hl(hl_name, opts)
  local is_ok, hl_def = pcall(vim.api.nvim_get_hl, { name = hl_name })
  if is_ok then
    for k, v in pairs(opts) do
      hl_def[k] = v
    end
  end
end

-- Autocommands
--- Only highlight searches, not search-and-replace
vim.api.nvim_create_autocmd({ 'CmdlineEnter' }, {
  group = vim.api.nvim_create_augroup('hl_group', { }),
  pattern = '[/?]',
  command = 'set hlsearch',
})
vim.api.nvim_create_autocmd({ 'CmdlineLeave' }, {
  group = vim.api.nvim_create_augroup('hl_group', { clear = false }),
  pattern = '[/?]',
  command = 'set nohlsearch',
})

--- Override colour scheme to use a transparent background
vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
  group = vim.api.nvim_create_augroup('colour_group', { }),
  pattern = '*',
  callback = function()
    mod_hl('Normal', { ctermbg = 'NONE' })
  end,
})

--- Use :help in this file
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  group = vim.api.nvim_create_augroup('init_group', { }),
  pattern = 'init.lua',
  command = 'set keywordprg='
})
