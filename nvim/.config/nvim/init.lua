-- For reference, see `:help lua-guide`.
-- Reload with `:luafile %`.

-- Built-in options {{{1
-- OS/terminal integration {{{2
-- Use system C-c C-v clipboard by default (but don't override selection '*)
vim.opt.clipboard = { 'unnamedplus' }
vim.opt.ttimeoutlen = 0 -- Don't ignore Esc immediately after keypress

-- Behaviour {{{2
vim.opt.undofile = true -- Allow undoing changes after exit
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
vim.opt.cursorline = true
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

-- Plugins {{{1
-- Set leader key for plugin keymaps
vim.g.mapleader = ' '
vim.keymap.set('n', '<Leader><Leader>', ':', { desc = 'Run command' })

-- Built-in plugins {{{2
vim.cmd.packadd 'nvim.difftool' -- Diff multiple files in quickfix list
vim.cmd.packadd 'nvim.undotree'
vim.keymap.set('n', '<Leader>au', '<Cmd>Undotree<CR>')
-- Disable netrw (buggy) {{{3
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

-- Usability {{{2
vim.pack.add {
  -- Show keymaps (not mini.clue, doesn't support operator-pending mode)
  'https://github.com/folke/which-key.nvim',
  -- Auto-update sessions
  'https://github.com/nvim-mini/mini.sessions',
  -- Auto-detect code style
  'https://github.com/tpope/vim-sleuth',
}
local wk = require 'which-key'
wk.setup {
  icons = {
    mappings = false,
    keys = {
      Up = '<Up>',
      Down = '<Down>',
      Left = '<Left>',
      Right = '<Right>',
      C = 'C-',
      M = 'M-',
      S = 'S-',
      CR = '<CR>',
      Esc = '<Esc>',
      ScrollWheelDown = '<ScrollDown>',
      ScrollWheelUp = '<ScrollUp>',
      BS = '<BS>',
      Space = '<Space>',
      Tab = '<Tab>',
      F1 = '<F1>',
      F2 = '<F2>',
      F3 = '<F3>',
      F4 = '<F4>',
      F5 = '<F5>',
      F6 = '<F6>',
      F7 = '<F7>',
      F8 = '<F8>',
      F9 = '<F9>',
      F10 = '<F10>',
      F11 = '<F11>',
      F12 = '<F12>',
    },
  },
}
wk.add {
  { '<Leader>a', group = 'applications' },
  { '<Leader>t', group = 'toggles' },
}
vim.keymap.set('n', '<Leader>?', function()
  wk.show { global = false }
end, { desc = 'Buffer Local Keymaps (which-key)' })
vim.keymap.del('n', '<C-W><C-D>') -- Clashes with C-d to show more keymaps
require('mini.sessions').setup {
  autoread = true,
}

-- Language Server Protocol {{{2
vim.pack.add {
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim', -- Dependency
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/nvim-lua/plenary.nvim', -- Dependency
  'https://github.com/pmizio/typescript-tools.nvim',
  'https://github.com/creativenull/efmls-configs-nvim',
}
require('mason').setup { }
require('mason-lspconfig').setup {
  ensure_installed = {
    'efm', -- Integrates with non-LSP tools like formatters and linters
    'gopls',
    'tailwindcss',
  },
}
require('typescript-tools').setup { }
local efm_languages = require('efmls-configs.defaults').languages()
vim.lsp.config('efm', {
  filetypes = vim.tbl_keys(efm_languages),
  settings = {
    rootMarkers = { '.git/' },
    languages = efm_languages,
  },
  init_options = {
    documentFormatting = true,
    documentRangeFormatting = true,
  },
})

-- File tree {{{3
vim.pack.add {
  'https://github.com/MunifTanjim/nui.nvim', -- Dependency (neo-tree.nvim)
  'https://github.com/nvim-lua/plenary.nvim', -- Dependency (neo-tree.nvim, nvim-lsp-file-operations)
  'https://github.com/nvim-neo-tree/neo-tree.nvim', -- Dependency (nvim-lsp-file-operations)
  'https://github.com/antosha417/nvim-lsp-file-operations',
}
require('lsp-file-operations').setup { }
vim.keymap.set('n', '<Leader>at', '<Cmd>Neotree toggle<CR>')

-- Editing {{{2
vim.pack.add {
  -- Surround operator (not mini.surround, limits search to find match)
  'https://github.com/keylechui/nvim-surround',
  -- Around/inner text objects
  'https://github.com/nvim-mini/mini.ai',
  -- Indentation text object
  'https://github.com/nvim-mini/mini.indentscope',
  -- Balanced pairs
  'https://github.com/nvim-mini/mini.pairs',
}
require('mini.ai').setup { }
mini_indentscope = require 'mini.indentscope'
mini_indentscope.setup {
  draw = {
    animation = mini_indentscope.gen_animation.none(),
  },
}
require('mini.pairs').setup { }

-- Git {{{2
vim.pack.add {
  'https://github.com/FabijanZulj/blame.nvim',
  'https://github.com/NeogitOrg/neogit',
  'https://github.com/whiteinge/diffconflicts', -- Resolve merge conflicts
}
require('blame').setup { }
require('neogit').setup {
  -- Match Magit keymaps
  mappings = {
    popup = {
      ['F'] = 'PullPopup',
      ['p'] = 'PushPopup',
      ['P'] = false,
    },
  },
}
wk.add {
  { '<Leader>g', group = 'git' },
}
vim.keymap.set('n', '<Leader>gb', '<Cmd>BlameToggle<CR>')
vim.keymap.set('n', '<Leader>gs', '<Cmd>Neogit<CR>')
vim.keymap.set('n', '<Leader>gl', '<Cmd>NeogitLog<CR>')
vim.keymap.set('n', '<Leader>gc', '<Cmd>DiffConflicts<CR>')

-- Org mode {{{2
vim.pack.add { 'https://github.com/nvim-orgmode/orgmode' }
require('orgmode').setup { }
vim.lsp.enable 'org'
wk.add {
  { '<Leader>o', group = 'org mode' },
}

-- Debug Adapter Protocol {{{2
vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap', -- Dependency
  'https://github.com/igorlfs/nvim-dap-view',
}
require('dap-view').setup { }
vim.keymap.set('n', '<Leader>ad', '<Cmd>DapViewOpen<CR>')

-- Functions {{{1
-- Modify an existing highlight group without completely replacing it {{{2
local function mod_hl(hl_name, opts)
  old_hl = vim.api.nvim_get_hl(0, { name = hl_name })
  new_hl = vim.tbl_extend('force', old_hl, opts)
  vim.api.nvim_set_hl(0, hl_name, new_hl)
end

-- Manage background transparency {{{2
-- Use a global (static) variable that will persist across reloads
if _G.my_term_bg == nil then
  _G.my_term_bg = vim.opt.background:get()
end
local original_bg_hl

-- Clear the background to use the terminal's background.
-- Returns whether the operation succeeded.
local function clear_bg()
  -- Only set transparency if colour scheme matches terminal background
  if vim.opt.background:get() ~= my_term_bg then
    return false
  end
  original_bg_hl = vim.api.nvim_get_hl(0, { name = 'Normal' })
  mod_hl('Normal', { ctermbg = 'NONE', bg = 'NONE' })
  return true
end

-- Set background back to original definition from colour scheme.
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

-- Autocommands {{{1
local config_group = vim.api.nvim_create_augroup('config_group', { })

-- Override colour scheme to use a transparent background {{{2
vim.api.nvim_create_autocmd({ 'ColorSchemePre' }, {
  group = config_group,
  pattern = '*',
  callback = function()
    -- Reset background option so that dynamic colour schemes follow the
    -- terminal's light/dark mode setting instead of whatever the previous
    -- colour scheme overrode the option to be.
    vim.opt.background = _G.my_term_bg
  end,
})
vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
  group = config_group,
  pattern = '*',
  callback = clear_bg,
})
-- Only set colour scheme after setting up the autocmd
if my_term_bg == 'light' then
  vim.cmd.colorscheme 'wildcharm'
else
  vim.cmd.colorscheme 'habamax'
end

-- Format on save {{{2
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = config_group,
  pattern = '*',
  callback = vim.lsp.buf.format,
})

-- Delete trailing whitespace on save {{{2
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = config_group,
  pattern = '*',
  command = [[%s/\s\+$//e]],
})

-- Use LSP for folding {{{2
vim.api.nvim_create_autocmd({ 'LspAttach' }, {
  group = config_group,
  pattern = '*',
  callback = function()
    if not vim.opt.diff:get() then
      vim.opt_local.foldmethod = 'expr'
      vim.opt_local.foldexpr = 'v:lua.vim.lsp.foldexpr()'
    end
  end,
})

-- Highlight on yank {{{2
vim.api.nvim_create_autocmd({ 'TextYankPost' }, {
  group = config_group,
  pattern = '*',
  callback = function()
    vim.hl.on_yank { hlgroup = 'Visual', timeout = 300 }
  end,
})

--- Use :help in this file (modeline does not support keywordprg) {{{2
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  group = config_group,
  pattern = '**/nvim/init.lua', -- Can't use MYVIMRC because it's a symlink
  callback = function()
    vim.opt_local.keywordprg = ':help!'
  end,
})

-- Clean up unused plugins {{{2
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
  group = config_group,
  pattern = 'nvim/init.lua',
  callback = function()
    local plugins_to_delete = { }
    for _, plugin in ipairs(vim.pack.get()) do
      if not plugin.active then
        table.insert(plugins_to_delete, plugin.spec.name)
      end
    end
    if #plugins_to_delete > 0 then
      local choice = vim.fn.confirm(
        'Remove unused plugins? ' .. vim.inspect(plugins_to_delete),
        '&Yes\n&No', 1, 'Question'
      )
      if choice == 1 then
        vim.pack.del(plugins_to_delete)
      end
    end
  end,
})

-- vim: foldmethod=marker
