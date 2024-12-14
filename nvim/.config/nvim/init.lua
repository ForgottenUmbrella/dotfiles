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
    'afreakk/unimpaired-which-key.nvim',
    dependencies = { 'tpope/vim-unimpaired' },
    config = function()
      local wk = require('which-key')
      wk.add(require('unimpaired-which-key'))
    end,
  },
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
    keys = {
      { 'cs', 'ds', 'ys' },
      { 'S', mode = 'v' },
    },
  },
  {
    'tpope/vim-unimpaired',
    keys = { '[', ']' },
  },
  {
    'tversteeg/registers.nvim',
    keys = {
      { "'", mode = { 'n', 'v' } },
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
    config = true,
  },
})

-- Built-in options
--- Clipboard: use system C-c C-v clipboard by default
--- (but don't override the selection clipboard '*)
vim.opt.clipboard = { 'unnamedplus' }

--- Search and replace
vim.opt.gdefault = true  -- Replace all occurrences by default
vim.opt.hlsearch = true
---- Context-dependent case sensitivity (disable with \C flag)
vim.opt.ignorecase = true
vim.opt.smartcase = true

--- Lines
---- Folding
vim.opt.foldlevelstart = 99  -- Start unfolded
vim.opt.foldmethod = 'indent'
---- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
---- Line length
vim.opt.colorcolumn = { 80 }
vim.opt.textwidth = 79
---- Scrolling
vim.opt.mousescroll = 'ver:5'
vim.opt.scrolloff = 2  -- Always show some lines above/below the cursor

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
vim.opt.title = true

-- Functions
--- Modify an existing highlight group without completely overriding it
local function mod_hl(hl_name, opts)
  local is_ok, hl_def = pcall(vim.api.nvim_get_hl, 0, { name = hl_name })
  if is_ok then
    for k, v in pairs(opts) do
      hl_def[k] = v
    end
    vim.api.nvim_set_hl(0, hl_name, hl_def)
  end
end

-- Autocommands
--- Override colour scheme to use a transparent background
local colour_group = vim.api.nvim_create_augroup('colour_group', { })
vim.api.nvim_create_autocmd({ 'VimEnter', 'ColorScheme' }, {
  group = colour_group,
  pattern = '*',
  callback = function()
    mod_hl('Normal', { ctermbg = 'NONE', bg = 'NONE' })
  end,
})

--- Use :help in this file
local init_group = vim.api.nvim_create_augroup('init_group', { })
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  group = init_group,
  pattern = 'init.lua',
  command = 'set keywordprg='
})
