-- Configure the statusline.

local ctrl_v = vim.api.nvim_replace_termcodes('<C-v>', true, true, true)
local ctrl_s = vim.api.nvim_replace_termcodes('<C-s>', true, true, true)
local mode_text_map = {
  n = 'NORMAL',
  v = 'VISUAL',
  V = 'V-LINE',
  [ctrl_v] = 'V-BLOCK',
  s = 'SELECT',
  S = 'S-LINE',
  [ctrl_s] = 'S-BLOCK',
  i = 'INSERT',
  R = 'REPLACE',
  c = 'COMMAND',
  r = 'PROMPT',
  ['!'] = 'SHELL',
  t = 'TERMINAL',
}
local visual_mode_hl = '%#DiffAdd#'
local mode_hl_map = {
  n = '%#Cursor#',
  v = visual_mode_hl,
  V = visual_mode_hl,
  [ctrl_v] = visual_mode_hl,
  s = visual_mode_hl,
  S = visual_mode_hl,
  [ctrl_s] = visual_mode_hl,
  i = '%#DiffChange#',
  R = '%#DiffDelete#',
  c = '%#DiffText#',
}

local git_status = ''
if vim.fn.executable 'git' then
  vim.api.nvim_create_autocmd(
    { 'BufEnter', 'FocusGained', 'BufWritePost', 'User' }, {
    group = my.augroup,
    pattern = { '*', 'NeogitStatusRefreshed' },
    desc = 'Update git statusline',
    callback = function()
      local has_uncommitted_changes = vim.system(
        { 'git', 'status', '--porcelain' },
        { text = true }
      ):wait().stdout ~= ''
      local ahead, behind = unpack(
        vim.split(
          vim.system(
            { 'git', 'rev-list', '--left-right', '--count', 'HEAD...@{u}' },
            { text = true }
          ):wait().stdout,
          '\t'
        )
      )
      git_status = vim.trim(
        table.concat {
          has_uncommitted_changes and '* ' or '',
          tonumber(ahead) > 0 and string.format('%d+ ', ahead) or '',
          tonumber(behind) > 0 and string.format('%d- ', behind) or '',
        }
      )
    end,
  })
end

function my.statusline()
  local file = '%<%f %h%w%m%r'
  local is_active =
    vim.api.nvim_get_current_win() == tonumber(vim.g.actual_curwin)
  if not is_active then
    return table.concat {
      '%#StatusLine#',
      ' ',
      vim.fn.winnr(),
      ' ',

      '%#StatusLineNC#',
      ' ',
      file,
    }
  end

  local mode = vim.api.nvim_get_mode().mode
  local mode_text = mode_text_map[mode] or 'UNKNOWN'
  local mode_hl = mode_hl_map[mode] or '%#IncSearch#'
  local cwd_path = vim.split(vim.fn.getcwd(), '/')
  local progress = table.concat {
    vim.ui.progress_status(),
    vim.opt.busy:get() > 0 and '◐' or '',
  }
  local ruler = '%l,%c%V %3.p%%'

  return table.concat {
    mode_hl,
    ' ',
    mode_text,
    ' ',

    '%#StatusLine#',
    ' ',
    cwd_path[#cwd_path],
    git_status,
    ' ',

    '%#StatusLineNC#',
    ' ',
    file,
    ' ',
    vim.diagnostic.status(),

    '%=',

    '%#StatusLine#',
    progress ~= '' and string.format(' %s ', progress) or '',

    mode_hl,
    ' ',
    ruler,
    ' ',
  }
end

vim.opt.statusline = '%{% v:lua.my.statusline() %}'
vim.opt.showmode = false
