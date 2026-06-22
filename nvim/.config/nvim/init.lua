-- For reference, see `:help lua-guide`.
-- Reload with `:Restart`.

_G.my = {} -- Namespace for my globals
my.augroup = vim.api.nvim_create_augroup('my.augroup', {})
-- Source host-specific config if it exists.
pcall(require, string.format('my.%s-init', vim.fn.hostname():gsub('%.', '-')))

-- Built-in options {{{1
-- OS/terminal integration {{{2
-- Use system C-c C-v clipboard by default (but don't override selection '*)
vim.opt.clipboard = { 'unnamedplus' }
vim.opt.ttimeoutlen = 0 -- Don't ignore Esc immediately after keypress

-- Behaviour {{{2
vim.opt.undofile = true -- Allow undoing changes after exit
vim.opt.gdefault = true -- Replace all occurrences by default
if vim.fn.executable 'rg' then
  vim.opt.grepprg = 'rg --vimgrep ' -- Remove -uu flags added by default
else
  vim.notify('ripgrep not installed; :grep will be slow', vim.log.levels.WARN)
end
vim.opt.sessionoptions:remove { 'blank', 'buffers' }
-- Context-dependent case sensitivity (disable with \C flag) {{{3
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- Default indentation (overridden by file convention/editorconfig) {{{3
vim.opt.expandtab = true -- Use spaces for indentation
vim.opt.shiftwidth = 4 -- Number of spaces to indent with
vim.opt.tabstop = 4 -- Render tabs as 4 spaces wide
-- Completion {{{3
vim.opt.autocomplete = true
vim.keymap.set('i', '<CR>', function()
  return vim.fn.pumvisible() == 0 and '<CR>' or '<C-e><CR>'
end, { desc = 'Insert newline regardless of completion', expr = true })
-- The autocompletedelay option currently blocks text rendering:
-- https://github.com/neovim/neovim/issues/40064
-- vim.opt.autocompletedelay = 1000
vim.opt.complete:append { 'F', 'o' }
vim.opt.completeopt:append 'noselect'
function my.findfunc(cmdarg, cmdcomplete)
  local paths = vim.list.unique(vim.opt.path:get())
  for i, path in ipairs(paths) do
    if path == '.' then
      paths[i] = vim.fn.expand '%:p:h'
    elseif path == '' then
      paths[i] = '.'
    end
  end
  local options = vim.fn.systemlist {
    'fd', '--full-path', '--hidden', '--follow', cmdarg, unpack(paths),
  }
  -- When querying completion candidates, return all options.
  -- Or if selecting a candidate, allow partial match if unambiguous.
  if cmdcomplete or #options == 1 then
    return options
  end
  -- If ambiguous, use the exact input.
  return { cmdarg }
end
if vim.fn.executable 'fd' then
  vim.opt.findfunc = 'v:lua.my.findfunc'
else
  vim.notify('fd not installed; :find will be slow', vim.log.levels.WARN)
end
-- Set noselect for cmdline-autocompletion
vim.opt.wildmode:prepend { 'noselect:lastused', 'longest' }
vim.opt.wildoptions:append 'fuzzy'

-- UI {{{2
require 'my.colourscheme'
require 'my.statusline'
require('vim._core.ui2').enable {
  msg = {
    -- Show messages in a toast instead of covering statusline (cmdheight=0)
    targets = 'msg',
  },
}
vim.opt.cmdheight = 0
vim.opt.shortmess:append 'c'

-- Windows {{{3
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.title = true
vim.opt.winblend = 10
vim.opt.winborder = 'single'
vim.opt.pumblend = 10

-- Lines {{{3
vim.opt.conceallevel = 2
vim.opt.cursorline = true
vim.opt.list = true
-- Line numbers {{{4
vim.opt.number = true
vim.opt.relativenumber = true
-- Folding {{{4
vim.opt.foldlevelstart = 99 -- Start unfolded
vim.opt.foldmethod = 'indent' -- Most syntax files don't define folds
vim.keymap.set('n', '<Tab>', 'za')
vim.keymap.set('n', '<C-i>', '<C-i>') -- By default <Tab> and <C-i> are the same
-- Scrolling {{{4
vim.opt.scrolloff = 2 -- Always show some lines above/below the cursor
-- Line length {{{4
vim.opt.breakindent = true
vim.opt.colorcolumn = { 81 }
vim.opt.linebreak = true
vim.opt.smoothscroll = true
vim.opt.textwidth = 80

-- Spell-check {{{3
vim.opt.spell = true
vim.opt.spelloptions = { 'camel', 'noplainbuffer' }

-- Plugins {{{1
-- Set leader key for plugin keymaps
vim.g.mapleader = ' '
vim.keymap.set({ 'n', 'v' }, '<Leader><Leader>', ':', { desc = 'Run command' })

-- Built-in plugins {{{2
vim.cmd.packadd 'cfilter'
vim.cmd.packadd 'nvim.undotree'
vim.keymap.set('n', '<Leader>u', '<Cmd>Undotree<CR>')
vim.g.markdown_folding = 1
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
  preset = 'modern',
  delay = 1000,
  spec = {
    { '<Leader>a', group = 'applications' },
    { '<Leader>f', group = 'files' },
    { '<Leader>t', group = 'toggles' },
  },
  win = {
    border = vim.o.winborder,
  },
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
vim.keymap.set({ 'n', 'v' }, '<Leader>?', function()
  wk.show { global = false }
end, { desc = 'Buffer Local Keymaps (which-key)' })
vim.keymap.del('n', '<C-W><C-D>') -- Clashes with C-d to show more keymaps
vim.keymap.set('n', '<Leader>w', function()
  wk.show { keys = '<C-w>', loop = true }
end, { desc = 'Window Hydra Mode' })
vim.keymap.set('i', '<C-?>', '<Cmd>WhichKey i<CR>')

local mini_sessions = require 'mini.sessions'
mini_sessions.setup {
  autoread = true,
  hooks = {
    post = {
      write = function(data)
        -- Persist quickfix lists.
        local num_qflists = vim.fn.getqflist { nr = '$' }
        for i = 1, num_qflists do
          local qflist = vim.fn.getqflist {
            nr = i,
            context = 1,
            efm = 1,
            items = 1,
            title = 1,
          }
          for _, entry in ipairs(qflist.items) do
            -- Use filename instead of bufnr so it can be reloaded.
            entry.filename = vim.api.nvim_buf_get_name(entry.bufnr)
            entry.bufnr = nil
          end
          local restore_cmd = string.format(
            [[setqflist([], ' ', %s)]], vim.fn.string(qflist)
          )
          vim.fn.writelist({ restore_cmd }, data.path, 'a')
        end
        -- Reopen quickfix windows in each tab.
        local qf_tabs = {}
        for _, window in ipairs(vim.fn.getwininfo()) do
          if window.quickfix == 1 then
            qf_tabs[window.tabnr] = true
          end
        end
        for tabnr in vim.tbl_keys(qf_tabs) do
          vim.fn.writelist({ tabnr .. 'tabdo copen' }, data.path, 'a')
        end
      end,
    },
  },
}
vim.api.nvim_create_user_command('Mksession', function(opts)
  local file = opts.fargs[1]
  mini_sessions.write(file)
end, { desc = 'Initialise directory session', nargs = '?', complete = 'file' })
-- Auto-update session on a timer in case of crashes
my.session_timer = vim.uv.new_timer() -- Global for runtime interaction
my.session_timer:start(15*60*1000, 15*60*1000, vim.schedule_wrap(function()
  -- Not an error if no session exists.
  pcall(mini_sessions.write, nil, { force = false, verbose = false })
end))

if vim.fn.executable 'fzf' then
  -- fzf comes bundled with a vim plugin that provides :FZF.
  vim.g.fzf_action = {
    ['ctrl-a'] = 'argadd',
  }
  vim.g.fzf_layout = {
    window = { width = 0.9, height = 0.6, border = 'none' },
  }
  vim.keymap.set('n', '<Leader>ff', '<Cmd>FZF<CR>')
end

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
    ['<space>'] = { nowait = true },
    O = {
      desc = 'open in external application', function(state)
        local opener
        local os = vim.uv.os_uname().sysname
        if os == 'Linux' then
          opener = 'xdg-open'
        elseif os == 'Darwin' then
          opener = 'open'
        elseif os == 'Windows_NT' then
          opener = 'start'
        else
          vim.notify(
            string.format('Unknown OS %s; cannot open file', os),
            vim.log.levels.ERROR
          )
          return
        end
        vim.system { opener, state.tree:get_node().path }
      end
    },
    Y = {
      desc = 'yank absolute path', function(state)
        vim.fn.setreg(vim.v.register, state.tree:get_node().path)
      end,
    },
  },
}
require('lsp-file-operations').setup {}
vim.keymap.set('n', '<Leader>ft', '<Cmd>Neotree toggle reveal<CR>')

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
require('mini.ai').setup {
  search_method = 'cover', -- mini.ai overrides text object behaviour, reset it.
}
local mini_indentscope = require 'mini.indentscope'
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
      F = 'PullPopup',
      p = 'PushPopup',
      P = false,
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
vim.g.org_folding = 1

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
  desc = 'Set up LSP features',
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local diff = vim.opt.diff:get() -- Don't override diff-mode folds
    if client:supports_method 'textDocument/foldingRange' and not diff then
      vim.opt_local.foldmethod = 'expr'
      vim.opt_local.foldexpr = 'v:lua.vim.lsp.foldexpr()'
    end

    if client:supports_method 'textDocument/documentHighlight' then
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        group = my.augroup,
        buffer = ev.buf,
        desc = 'Highlight occurrences',
        callback = vim.lsp.buf.document_highlight,
      })
      vim.keymap.set('n', '<C-*>', vim.lsp.buf.document_highlight, {
        desc = 'Highlight occurrences',
        buf = 0,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
        group = my.augroup,
        buffer = ev.buf,
        desc = 'Remove highlighting on move',
        callback = vim.lsp.buf.clear_references,
      })
    end

    if not client:supports_method('textDocument/willSaveWaitUntil')
      and client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = my.augroup,
        buffer = ev.buf,
        desc = 'lsp-format',
        callback = function()
          vim.lsp.buf.format {
            bufnr = ev.buf,
            id = client.id,
            timeout_ms = 1000,
          }
        end,
      })
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
  -- Swallow return so autocmd doesn't get deleted on first event
  callback = function() vim.fn.wildtrigger() end,
})
for _, key in ipairs { '<Up>', '<Down>', '<Right>' } do
  vim.keymap.set('c', key, function()
    return vim.fn.wildmenumode() == 1 and '<C-e>' .. key or key
  end, { expr = true })
end

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufReadPost' }, {
  group = my.augroup,
  pattern = '**/nvim/**/*.lua',
  desc = 'Use :help in nvim/init.lua',
  -- Can't be set via modeline
  callback = function() vim.opt_local.keywordprg = ':help!' end,
})

vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
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

-- User commands {{{1
vim.api.nvim_create_user_command('Restart', function()
  -- Instead of storing our own temp session, use mini.sessions' functionality
  -- to avoid clobbering its internal state.
  mini_sessions.restart()
end, { desc = 'Reload nvim config' })

vim.api.nvim_create_user_command('Wrap', function(opts)
  local wrap_col = opts.fargs[1] or vim.opt.textwidth:get()

  -- If already wrapped, undo wrapping
  local is_wrapped = vim.w.my_wrapper_winid and
    vim.api.nvim_win_is_valid(vim.w.my_wrapper_winid)
  if is_wrapped then
    vim.api.nvim_win_close(vim.w.my_wrapper_winid)
    vim.opt_local.colorcolumn = vim.w.my_wrapped_colorcolumn
    return
  end

  if wrap_col == 0 then
    vim.notify('Wrap column cannot be zero', vim.log.levels.ERROR)
    return
  end

  -- Configure the helper window to enforce wrapping
  vim.cmd.vnew()
  local wrapper_winid = vim.fn.win_getid()
  local wrapper_options = {}
  vim.api.nvim_create_autocmd({ 'OptionSet' }, {
    group = my.augroup,
    buffer = 0,
    desc = 'Track original window options',
    callback = function(ev)
      local option = ev.match
      table.insert(wrapper_options, option)
    end,
  })
  vim.api.nvim_create_autocmd({ 'BufWinLeave' }, {
    group = my.augroup,
    buffer = 0,
    desc = 'Reset window options',
    callback = function()
      for _, option in ipairs(wrapper_options) do
        vim.opt_local[option] = nil
      end
    end,
  })
  vim.api.nvim_win_set_config(0, { style = 'minimal' })
  vim.opt_local.statusline = ' '
  vim.opt_local.winhighlight:append {
    StatusLine = 'Normal',
    StatusLineNC = 'Normal',
  }
  vim.opt_local.bufhidden = 'delete'
  vim.opt_local.modifiable = false

  -- Configure the wrapped window
  vim.cmd.wincmd 'p'
  vim.w.my_wrapper_winid = wrapper_winid
  vim.w.my_wrapped_colorcolumn = vim.opt.colorcolumn:get()
  vim.opt_local.colorcolumn = {}
  vim.cmd.resize { wrap_col, mods = { vertical = true } }
end, { desc = 'Toggle soft-wrap', nargs = '?' })
vim.keymap.set('n', '<Leader>tw', '<Cmd>Wrap<CR>')

-- vim: foldmethod=marker
