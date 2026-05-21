-- Set up LSP servers.

vim.pack.add {
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/nvim-lua/plenary.nvim', -- Dependency
  'https://github.com/pmizio/typescript-tools.nvim',
  'https://github.com/creativenull/efmls-configs-nvim',
}

require('mason').setup {}
local registry = require 'mason-registry'

---Ensure an LSP server is installed and enabled.
---@param spec string|table If string, the mason package providing the server
---to install. Otherwise a full spec with the following fields.
---@param spec[1] string The mason package providing the server to install
---@param spec.lspconfig? string The name of the lspconfig to enable. Defaults
---to spec[1].
---@param spec.requires? string|string[] Executable(s) that must be available
---to install the server
local function mason_lsp_ensure(spec)
  if type(spec) == 'string' then
    spec = { spec }
  end
  local pkg_name = spec[1]
  local lspconfig = spec.lspconfig or pkg_name
  local requires = type(spec.requires) == 'string' and
    { spec.requires } or
    spec.requires or {}

  if not (vim.fn.executable(pkg_name) or registry.is_installed(pkg_name)) then
    for _, required in ipairs(requires) do
      if not vim.fn.executable(required) then
        vim.notify(
          string.format(
            'Skipping install of %s LSP server; \z
            %s is required but not installed',
            pkg_name, required
          ),
          vim.log.levels.WARN
        )
        return
      end
    end
    vim.cmd.MasonInstall(pkg_name)
  end

  vim.lsp.enable(lspconfig)
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

require('typescript-tools').setup {}
