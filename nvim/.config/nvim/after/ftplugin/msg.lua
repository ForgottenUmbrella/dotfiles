-- Render floating message window like a notification.

local config = vim.api.nvim_win_get_config(0)
vim.api.nvim_win_set_config(0, {
  relative = 'editor',
  anchor = 'NE',
  row = 1, -- Leave a row for the tabline
  col = config.col, -- Must be explicitly set when setting `relative`
  width = math.max(config.width, 32),
  height = math.max(config.height, 2),
})
