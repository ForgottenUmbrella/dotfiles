-- vim: nospell foldmethod=marker
-- For reference, see `:help lua-guide`

-- Bootstrap lazy.nvim package manager {{{1
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

-- Set leader key for package keybindings
vim.g.mapleader = ' '

-- Packages {{{1
require('lazy').setup({
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = { },
    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show({ global = false })
        end,
        desc = 'Buffer Local Keymaps (which-key)',
      },
    },
  },

  {
    'nvim-mini/mini.ai',
    opts = { },
    keys = {
      'cA', 'dA', 'yA',
      'ca', 'da', 'ya',
      'cI', 'dI', 'yI',
      'ci', 'di', 'yi',
    },
  },

  {
    'nvim-mini/mini.pairs',
    event = 'InsertEnter',
    opts = { },
  },

  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    opts = {
      kind = 'replace',
    },
    keys = {
      { '<leader>gs', '<cmd>Neogit<cr>', desc = 'Show Neogit UI' },
    },
    lazy = true,
    cmd = 'Neogit',
  },

  {
    'tpope/vim-repeat',
    keys = { '.' },
  },

  -- Auto-detect code style
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
})

-- Built-in options {{{1
-- Clipboard: use system C-c C-v clipboard by default {{{2
-- (but don't override the selection clipboard '*)
vim.opt.clipboard = { 'unnamedplus' }

-- Colorscheme {{{2
vim.cmd.colorscheme('habamax')

-- Files {{{2
vim.opt.autochdir = true  -- Set working directory to current file's directory

-- Lines {{{2
-- Folding {{{3
vim.opt.foldlevelstart = 99  -- Start unfolded
vim.opt.foldmethod = 'syntax'
-- Line numbers {{{3
vim.opt.number = true
vim.opt.relativenumber = true
-- Line length {{{3
vim.opt.colorcolumn = { 80 }
vim.opt.textwidth = 79
-- Scrolling {{{{3
vim.opt.mousescroll = 'ver:5'
vim.opt.scrolloff = 2  -- Always show some lines above/below the cursor

-- Search and replace {{{2
vim.opt.gdefault = true  -- Replace all occurrences by default
-- Context-dependent case sensitivity (disable with \C flag) {{{3
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Spell-check {{{2
vim.opt.spell = true
vim.opt.spelloptions = { 'camel' }  -- Recognise CamelCase.

-- Whitespace {{{2
vim.opt.list = true  -- Show whitespace
-- Indentation {{{3
vim.opt.expandtab = true  -- Use spaces for indentation
vim.opt.shiftwidth = 4  -- Number of spaces to indent with
vim.opt.tabstop = 4  -- Render tabs as 4 spaces wide

-- Windows {{{2
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.title = true

-- Functions {{{1
-- Modify an existing highlight group without completely overriding it {{{2
local function mod_hl(hl_name, opts)
  local is_ok, hl_def = pcall(vim.api.nvim_get_hl, 0, { name = hl_name })
  if is_ok then
    for k, v in pairs(opts) do
      hl_def[k] = v
    end
    vim.api.nvim_set_hl(0, hl_name, hl_def)
  end
end

-- Autocommands {{{1
-- Override colour scheme to use a transparent background {{{2
local colour_group = vim.api.nvim_create_augroup('colour_group', { })
vim.api.nvim_create_autocmd({ 'VimEnter', 'ColorScheme' }, {
  group = colour_group,
  pattern = '*',
  callback = function()
    mod_hl('Normal', { ctermbg = 'NONE', bg = 'NONE' })
  end,
})

-- Use :help in this file {{{2
local init_group = vim.api.nvim_create_augroup('init_group', { })
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  group = init_group,
  pattern = 'init.lua',
  callback = function()
    vim.opt.keywordprg = ':help!'
  end,
})
