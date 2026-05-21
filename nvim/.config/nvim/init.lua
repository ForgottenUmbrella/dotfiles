-- For reference, see `:help lua-guide`.
-- Reload with `:luafile %`.

_G.my = {} -- Namespace for my globals
my.augroup = vim.api.nvim_create_augroup('my_augroup', {})

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
-- Completion {{{3
vim.opt.complete:append { 'F', 'o' }
function my.findfunc(cmdarg, cmdcomplete)
  return vim.fn.systemlist {
    'fd', '--full-path', '--hidden', '--follow', cmdarg,
  }
end
if vim.fn.executable 'fd' then
  vim.opt.findfunc = 'v:lua.my.findfunc'
else
  vim.notify('fd not installed; :find will be slow', vim.log.levels.WARN)
end
vim.opt.pumheight = 10
-- Set noselect for cmdline-autocompletion
vim.opt.wildmode:prepend { 'noselect:lastused' }

-- UI {{{2
require 'my.colourscheme'
require 'my.statusline'
vim.opt.cmdheight = 0

-- Windows {{{3
require('vim._core.ui2').enable {
  msg = {
    -- Show messages in a toast instead of covering statusline (cmdheight=0)
    targets = 'msg',
  },
}
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
vim.opt.foldmethod = 'indent' -- Most syntax files don't define folds
vim.keymap.set('n', '<Tab>', 'za')
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
require 'my.lsp'

-- File tree {{{3
vim.pack.add {
  -- Dependency (neo-tree.nvim)
  'https://github.com/MunifTanjim/nui.nvim',
  -- Dependency (neo-tree.nvim, nvim-lsp-file-operations)
  'https://github.com/nvim-lua/plenary.nvim',
  -- Dependency (nvim-lsp-file-operations)
  'https://github.com/nvim-neo-tree/neo-tree.nvim',
  'https://github.com/antosha417/nvim-lsp-file-operations',
}
require('neo-tree').setup {
  filesystem = {
    filtered_items = {
      hide_dotfiles = false,
    },
  },
  mappings = {
    ['<Tab>'] = 'open',
  },
}
require('lsp-file-operations').setup {}
vim.keymap.set('n', '<Leader>at', '<Cmd>Neotree toggle reveal<CR>')

-- Editing {{{2
vim.pack.add {
  -- Surround operator (not mini.surround, limits search to find match)
  'https://github.com/kylechui/nvim-surround',
  -- Around/inner text objects
  'https://github.com/nvim-mini/mini.ai',
  -- Indentation text object
  'https://github.com/nvim-mini/mini.indentscope',
  -- Balanced pairs
  'https://github.com/nvim-mini/mini.pairs',
}
require('mini.ai').setup {}
mini_indentscope = require 'mini.indentscope'
mini_indentscope.setup {
  draw = {
    animation = mini_indentscope.gen_animation.none(),
  },
}
require('mini.pairs').setup {}

-- Git {{{2
vim.pack.add {
  'https://github.com/FabijanZulj/blame.nvim',
  'https://github.com/NeogitOrg/neogit',
  'https://github.com/whiteinge/diffconflicts', -- Resolve merge conflicts
}
require('blame').setup {}
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
require('orgmode').setup {}
vim.lsp.enable 'org'
wk.add {
  { '<Leader>o', group = 'org mode' },
}

-- Debug Adapter Protocol {{{2
vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap', -- Dependency
  'https://github.com/igorlfs/nvim-dap-view',
}
require('dap-view').setup {}
vim.keymap.set('n', '<Leader>ad', '<Cmd>DapViewOpen<CR>')

-- Autocommands {{{1
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = my.augroup,
  desc = 'Delete trailing whitespace on save',
  command = [[%s/\s\+$//e]],
})

vim.api.nvim_create_autocmd({ 'LspAttach' }, {
  group = my.augroup,
  desc = 'Use LSP for folding',
  callback = function()
    if not vim.opt.diff:get() then
      vim.opt_local.foldmethod = 'expr'
      vim.opt_local.foldexpr = 'v:lua.vim.lsp.foldexpr()'
    end
  end,
})

vim.api.nvim_create_autocmd({ 'TextYankPost' }, {
  group = my.augroup,
  desc = 'Highlight on yank',
  callback = function()
    vim.hl.on_yank { hlgroup = 'Visual', timeout = 300 }
  end,
})

vim.api.nvim_create_autocmd({ 'CmdlineChanged' }, {
  group = my.augroup,
  pattern = '[:/?]',
  desc = 'cmdline-autocompletion',
  callback = function() vim.fn.wildtrigger() end,
})
for _, key in ipairs { '<Up>', '<Down>', '<Right>' } do
  vim.keymap.set('c', key, function()
    return vim.fn.wildmenumode() and '<C-e>' .. key or key
  end, { expr = true })
end

vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  group = my.augroup,
  pattern = '**/nvim/**/*.lua',
  desc = 'Use :help in nvim/init.lua',
  -- Can't be set via modeline
  callback = function() vim.opt_local.keywordprg = ':help!' end,
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
  group = my.augroup,
  pattern = '**/nvim/**/*.lua',
  desc = 'Clean up unused plugins',
  callback = function()
    local plugins_to_delete = {}
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
