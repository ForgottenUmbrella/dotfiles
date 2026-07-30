-- Set up LSP servers.

vim.pack.add {
  -- Dependency (typescript-tools.nvim, none-ls.nvim)
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvimtools/none-ls.nvim',
  'https://github.com/nvimtools/none-ls-extras.nvim',
  'https://github.com/pmizio/typescript-tools.nvim',
}
require('typescript-tools').setup {}
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

---Ensure an LSP server is installed and enabled.
---@see my.mason_ensure
---@param spec.lspconfig? string The name of the lspconfig to enable. Defaults
---to spec[1].
local function mason_lsp_ensure(spec)
  if type(spec) == 'string' then
    spec = { spec }
  end
  local lspconfig = spec.lspconfig or spec[1]
  if my.mason_ensure(spec) then
    vim.lsp.enable(lspconfig)
  end
end

vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = my.augroup,
  pattern = 'go',
  desc = 'Install go LSP server',
  callback = function() mason_lsp_ensure { 'gopls', requires = 'go' } end,
  once = true,
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = my.augroup,
  pattern = { 'javascriptreact', 'typescriptreact' },
  desc = 'Install JSX/TSX LSP server',
  callback = function()
    mason_lsp_ensure {
      'tailwindcss-language-server',
      lspconfig = 'tailwindcss',
      requires = 'npm',
    }
  end,
  once = true,
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
