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
    'tpope/vim-surround',
    keys = { 'cs', 'ds', 'ys' },
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
vim.opt.foldmethod = 'indent'
---- Scrolling
vim.opt.mousescroll = {
  ver = 3,
}
vim.opt.scrolloff = 2  -- Always show some lines above/below the cursor
---- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
---- Line width
vim.opt.colorcolumn = { 80 }
vim.opt.textwidth = 79

--- Spell-check
vim.opt.spell = true

--- Whitespace
vim.opt.list = true  -- Show whitespace
---- Indentation
vim.opt.expandtab = true  -- Use spaces for indentation
vim.opt.shiftwidth = 4  -- Number of spaces to indent with

--- Windows
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Autocommands
--- Only highlight searches, not search-and-replace
local hl_group = vim.api.nvim_create_augroup('hl_group', { clear = true })
vim.api.nvim_create_autocmd({ 'CmdlineEnter' }, {
  group = hl_group,
  pattern = '[/\?]',
  command = 'set hlsearch',
})
vim.api.nvim_create_autocmd({ 'CmdlineLeave' }, {
  group = hl_group,
  pattern = '[/\?]',
  command = 'set nohlsearch',
})
