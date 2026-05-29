-- Render cmdline window as a floating prompt.

local winid = vim.api.nvim_get_current_win()

local function set_config()
  local config = vim.api.nvim_win_get_config(winid)
  local frame_width = vim.opt.columns:get()
  local win_width = math.min(math.max(frame_width - 32, 80), frame_width)
  vim.api.nvim_win_set_config(winid, {
    relative = 'editor',
    row = 5,
    col = (frame_width - win_width) / 2,
    width = win_width,
    height = config.height,
  })
end

set_config()

vim.api.nvim_create_autocmd({ 'VimResized' }, {
  group = my.augroup,
  buffer = 0,
  desc = 'Resize cmdline window',
  callback = set_config,
})
