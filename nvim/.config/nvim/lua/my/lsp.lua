-- Set up LSP servers.

vim.pack.add {
  -- Dependency (typescript-tools.nvim)
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/pmizio/typescript-tools.nvim',
  'https://github.com/creativenull/efmls-configs-nvim',
}
require('typescript-tools').setup {}

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

-- Integrates with non-LSP tools like formatters & linters
mason_lsp_ensure 'efm'
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

vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = my.augroup,
  pattern = 'go',
  desc = 'Install go LSP server',
  callback = function()
    mason_lsp_ensure { 'gopls', requires = 'go' }
  end,
  once = true,
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = my.augroup,
  pattern = { 'javascriptreact', 'typescriptreact' },
  desc = 'Install tailwind LSP server',
  callback = function()
    mason_lsp_ensure {
      'tailwindcss-language-server',
      lspconfig = 'tailwind',
      requires = 'npm',
    }
  end,
  once = true,
})
