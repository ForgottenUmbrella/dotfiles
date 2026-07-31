-- Set up LSP servers.

local treesitter = require 'nvim-treesitter'

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
  callback = function()
    mason_lsp_ensure { 'gopls', requires = 'go' }
    treesitter.install 'go'
  end,
  once = true,
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = my.augroup,
  pattern = { 'typescript', 'typescriptreact' },
  desc = 'Install typescript treesitter definitions',
  callback = function() treesitter.install 'typescript' end,
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
