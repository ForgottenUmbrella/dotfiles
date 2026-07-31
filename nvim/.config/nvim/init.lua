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
if vim.fn.executable 'rg' == 1 then
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
-- BUG: The autocompletedelay option currently blocks text rendering:
-- https://github.com/neovim/neovim/issues/40064
-- vim.opt.autocompletedelay = 1000
vim.opt.complete:append { 'F', 'o' }
vim.opt.completeopt:append { 'noselect', 'fuzzy' }
vim.opt.pumheight = 5
function my.findfunc(cmdarg, cmdcomplete)
  local paths = vim.list.unique(vim.opt.path:get())
  local find_paths = {}
  for i, path in ipairs(paths) do
    if path == '' then
      table.insert(find_paths, '.')
    elseif path == '.' then
      local has_cwd = vim.tbl_contains(paths, '')
      local current_file_dir = vim.fn.expand '%:p:h'
      local cwd = vim.fn.getcwd() .. '/'
      local is_cwd_descendent = vim.startswith(current_file_dir, cwd)
      if not has_cwd or not is_cwd_descendent then
        -- Only add current file directory if it wouldn't duplicate cwd.
        table.insert(find_paths, current_file_dir)
      end
    else
      table.insert(find_paths, path)
    end
  end
  local options = vim.fn.systemlist {
    'fd', '--full-path', '--hidden', '--follow', cmdarg, unpack(find_paths),
  }
  -- When querying completion candidates, return all options.
  -- Or if selecting a candidate, allow partial match if unambiguous.
  if cmdcomplete or #options == 1 then
    return options
  end
  -- If ambiguous, use the exact input.
  return { cmdarg }
end
if vim.fn.executable 'fd' == 1 then
  vim.opt.findfunc = 'v:lua.my.findfunc'
else
  vim.notify('fd not installed; :find will be slow', vim.log.levels.WARN)
end
-- Set noselect for cmdline-autocompletion
vim.opt.wildmode:prepend { 'noselect:lastused', 'longest' }
vim.opt.wildoptions:append 'fuzzy'
vim.keymap.set('i', '<C-s>', function()
  -- Completion popup menu prefers below, so show signature help above.
  vim.lsp.buf.signature_help { anchor_bias = 'above' }
end, { desc = 'Show signature help' })

-- UI {{{2
-- Set leader key for keymaps
vim.g.mapleader = ' '
vim.keymap.set({ 'n', 'v' }, '<Leader><Leader>', ':', { desc = 'Run command' })

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
vim.opt.scrolloff = 2 -- Always show some lines above/below the cursor
-- Line numbers {{{4
vim.opt.number = true
vim.opt.relativenumber = true
-- Folding {{{4
vim.opt.foldlevelstart = 99 -- Start unfolded
vim.opt.foldmethod = 'indent' -- Most syntax files don't define folds
vim.opt.foldopen:remove 'block'
vim.keymap.set('n', '<Tab>', 'za')
vim.keymap.set('n', '<C-i>', '<C-i>') -- By default <Tab> and <C-i> are the same
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
        local qfinfo = vim.fn.getqflist { nr = '$' }
        for i = 1, qfinfo.nr do
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
            [[setqflist([], ' ', %s)]],
            vim.fn.string(qflist)
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
        for tabnr in pairs(qf_tabs) do
          vim.fn.writelist({ tabnr .. 'tabdo copen' }, data.path, 'a')
        end
      end,
    },
  },
}
vim.api.nvim_create_user_command('Mksession', function(opts)
  local file = opts.fargs[1]
  if file == nil and vim.v.this_session == '' then
    file = mini_sessions.config.file
  end
  mini_sessions.write(file)
end, { desc = 'Initialise directory session', nargs = '?', complete = 'file' })
-- Auto-update session on a timer in case of crashes
my.session_timer = vim.uv.new_timer() -- Global for runtime interaction
my.session_timer:start(15*60*1000, 15*60*1000, vim.schedule_wrap(function()
  -- Not an error if no session exists.
  pcall(mini_sessions.write, nil, { force = false, verbose = false })
end))

if vim.fn.executable 'fzf' == 1 then
  -- fzf comes bundled with a vim plugin that provides :FZF.
  vim.g.fzf_action = {
    ['ctrl-a'] = 'argadd',
  }
  vim.g.fzf_layout = {
    window = { width = 0.9, height = 0.6, border = 'none' },
  }
  vim.keymap.set('n', '<Leader>ff', '<Cmd>FZF<CR>')
end

-- Language Server Protocol/tree-sitter {{{2
vim.pack.add {
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/nvim-treesitter/nvim-treesitter-context',
  -- Dependency (typescript-tools.nvim, none-ls.nvim)
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvimtools/none-ls.nvim',
  'https://github.com/nvimtools/none-ls-extras.nvim',
  'https://github.com/pmizio/typescript-tools.nvim',
}
require('mason').setup {}
require('treesitter-context').setup {
  multiwindow = true,
  multiline_threshold = 1,
  separator = '-',
}
local null_ls = require 'null-ls'
null_ls.setup {
  sources = {
    null_ls.builtins.diagnostics.golangci_lint.with {
      extra_args = { '--output.text.path=/dev/null' },
    },
    null_ls.builtins.formatting.prettier,
    require 'none-ls.diagnostics.eslint',
  },
}
require('typescript-tools').setup {}

-- Add mason executables to PATH.
vim.env.PATH = string.format(
  '%s/mason/bin:%s',
  vim.fn.stdpath('data'), vim.env.PATH
)
local registry = require 'mason-registry'
---Ensure an executable is installed.
---@param spec string|table If string, the mason package providing the
---executable to install. Otherwise a full spec with the following fields.
---@param spec[1] string The mason package providing the executable to install
---@param spec.exe? string The executable provided by the package. Defaults to
---spec[1].
---@param spec.requires? string|string[] Executable(s) that must be available
---to install the mason package
---@return boolean Whether the executable is installed
function my.mason_ensure(spec)
  if type(spec) == 'string' then
    spec = { spec }
  end
  local pkg_name = spec[1]
  local exe = spec.exe or pkg_name
  local requires = type(spec.requires) == 'string' and
    { spec.requires } or
    spec.requires or {}
  local is_installed = vim.fn.executable(exe) == 1 or
    registry.is_installed(pkg_name)
  if not is_installed then
    for _, required in ipairs(requires) do
      if vim.fn.executable(required) == 0 then
        vim.notify(
          string.format(
            'Skipping install of %s; %s is required but not installed',
            pkg_name, required
          ),
          vim.log.levels.WARN
        )
        return false
      end
    end
    vim.cmd.MasonInstall(pkg_name)
  end
  return true
end

my.mason_ensure {
  'tree-sitter-cli',
  exe = 'tree-sitter',
  requires = { 'tar', 'curl', 'cc' },
}

-- File tree {{{3
vim.pack.add {
  -- Dependency (neo-tree.nvim)
  'https://github.com/MunifTanjim/nui.nvim',
  -- Dependency (neo-tree.nvim, nvim-lsp-file-operations)
  'https://github.com/nvim-lua/plenary.nvim',
  -- Dependency (nvim-file-operations)
  'https://github.com/nvim-neo-tree/neo-tree.nvim',
  'https://github.com/Crysthamus/nvim-file-operations',
}
require('neo-tree').setup {
  filesystem = {
    filtered_items = {
      hide_dotfiles = false,
    },
  },
  mappings = {
    ['<space>'] = { 'toggle_node', nowait = true },
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
require('nvim-file-operations').setup {}
vim.keymap.set('n', '<Leader>ft', '<Cmd>Neotree reveal<CR>')

-- Editing {{{2
vim.pack.add {
  -- Surround operator (not mini.surround, limits search to find match)
  'https://github.com/kylechui/nvim-surround',
  -- Around/inner text objects
  'https://github.com/nvim-mini/mini.ai',
  -- Indentation text object
  'https://github.com/nvim-mini/mini.indentscope',
  -- Balanced pairs (not mini.pairs, doesn't support multi-character pairs)
  'https://github.com/windwp/nvim-autopairs',
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
require('nvim-autopairs').setup {}

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
  'https://github.com/mfussenegger/nvim-dap', -- Dependency (nvim-dap-view)
  'https://github.com/igorlfs/nvim-dap-view',
}
require('dap-view').setup {}
vim.keymap.set('n', '<Leader>ad', '<Cmd>DapViewOpen<CR>')

-- Autocommands {{{1
require 'my.lsp'

vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = my.augroup,
  desc = 'Delete trailing whitespace on save',
  command = [[%s/\s\+$//e]],
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
          vim.lsp.buf.code_action {
            context = {
              only = { 'source.organizeImports' },
            },
            apply = true,
          }
          vim.lsp.buf.format { bufnr = ev.buf, id = client.id }
        end,
      })
    end
  end,
})

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufReadPost' }, {
  group = my.augroup,
  pattern = '**/nvim/**/*.lua',
  desc = 'Use :help in nvim/init.lua',
  -- Can't be set via modeline
  callback = function() vim.opt_local.keywordprg = ':help!' end,
})

local function pack_clean()
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
end

vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
  group = my.augroup,
  pattern = '**/nvim/**/*.lua',
  desc = 'Clean up unused plugins',
  callback = pack_clean,
})

-- User commands {{{1
-- Remove unused plugins {{{2
vim.api.nvim_create_user_command('PackClean', pack_clean, {
  desc = 'Remove unused plugins',
})

-- Reload nvim config {{{2
vim.api.nvim_create_user_command('Restart', function()
  -- Instead of storing our own temp session, use mini.sessions' functionality
  -- to avoid clobbering its internal state.
  mini_sessions.restart()
end, { desc = 'Reload nvim config' })

-- Toggle soft wrap {{{2
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
