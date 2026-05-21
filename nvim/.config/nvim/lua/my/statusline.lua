-- Configure the statusline.

local ctrl_v = vim.api.nvim_replace_termcodes('<C-v>', true, true, true)
local ctrl_s = vim.api.nvim_replace_termcodes('<C-s>', true, true, true)
local modes = {
  n = { long = 'NORMAL', short = 'N', hl = '%#MyStatusLineNormal#' },
  v = { long = 'VISUAL', short = 'V', hl = '%#MyStatusLineVisual#' },
  V = { long = 'V-LINE', short = 'VL', hl = '%#MyStatusLineVisual#' },
  [ctrl_v] = { long = 'V-BLOCK', short = 'VB', hl = '%#MyStatusLineVisual#' },
  s = { long = 'SELECT', short = 'S', hl = '%#MyStatusLineVisual#' },
  S = { long = 'S-LINE', short = 'SL', hl = '%#MyStatusLineVisual#' },
  [ctrl_s] = { long = 'S-BLOCK', short = 'SB', hl = '%#MyStatusLineVisual#' },
  i = { long = 'INSERT', short = 'I', hl = '%#MyStatusLineInsert#' },
  R = { long = 'REPLACE', short = 'R', hl = '%#MyStatusLineReplace#' },
  c = { long = 'COMMAND', short = 'C', hl = '%#MyStatusLineCommand#' },
  r = { long = 'PROMPT', short = 'P', hl = '%#MyStatusLineCommand#' },
  ['!'] = { long = 'SHELL', short = 'SH', hl = '%#MyStatusLineCommand#' },
  t = { long = 'TERMINAL', short = 'T', hl = '%#MyStatusLineCommand#' },
}

vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
  group = my.augroup,
  desc = 'Create statusline highlight groups',
  callback = function()
    local fg = vim.api.nvim_get_hl(0, { name = 'StatusLine' }).fg
    local colours = {
      Normal = 'Type',
      Visual = 'Special',
      Insert = 'String',
      Replace = 'Number',
      Command = 'Identifier',
    }
    for mode, hl_name in pairs(colours) do
      local bg = vim.api.nvim_get_hl(0, { name = hl_name }).fg
      vim.api.nvim_set_hl(0, 'MyStatusLine' .. mode, {
        bg = bg,
        fg = fg,
        bold = true,
      })
    end
  end,
})

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
      local git_segments = {}
      if has_uncommitted_changes then
        table.insert(git_segments, '[*]')
      end
      if tonumber(ahead) > 0 then
        table.insert(git_segments, string.format('[%d+]', ahead))
      end
      if tonumber(behind) > 0 then
        table.insert(git_segments, string.format('[%d-]', behind))
      end
      git_status = table.concat(git_segments, ' ')
    end,
  })
end

function my.statusline()
  local file = '%f %h%w%m%r'
  local is_active =
    vim.api.nvim_get_current_win() == tonumber(vim.g.actual_curwin)
  if not is_active then
    return table.concat {
      '%#StatusLine# ',
      vim.fn.winnr(), ' ',

      '%#StatusLineNC# ',
      '%<',
      file,
    }
  end

  local width = vim.api.nvim_win_get_width(0)
  local mode = vim.api.nvim_get_mode().mode
  local mode_info = modes[mode] or {
    long = string.format('UNKNOWN-%s', mode),
    short = string.format('?%s', mode),
    hl = '%#MyStatusLineNormal#',
  }
  local cwd_path = vim.split(vim.fn.getcwd(), '/')
  local progress = table.concat {
    vim.ui.progress_status(),
    vim.opt.busy:get() > 0 and '◐' or '',
  }
  local ruler = width >= 80 and '%6(%l:%c%V%) %3p%%' or '%l:%c%V %p%%'

  return table.concat {
    mode_info.hl, ' ',
    width >= 100 and mode_info.long or mode_info.short, ' ',

    width >= 80 and table.concat {
      '%#StatusLine# ',
      cwd_path[#cwd_path], ' ',
      git_status ~= '' and string.format('%s ', git_status) or '',
    } or '',

    '%#StatusLineNC# ',
    '%<',
    file, ' ',
    vim.diagnostic.status(),
    '%=',

    progress ~= '' and string.format('%#StatusLine# %s ', progress) or '',

    mode_info.hl, ' ',
    ruler, ' ',
  }
end

vim.opt.statusline = '%{% v:lua.my.statusline() %}'
vim.opt.showmode = false

vim.api.nvim_create_autocmd({ 'ModeChanged' }, {
  group = my.augroup,
  desc = 'Redraw statusline on mode change',
  -- Visual line/block mode doesn't update statusline automatically
  command = 'redrawstatus',
})
