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
    local fg = vim.api.nvim_get_hl(0, { name = 'StatusLine', link = false }).fg
    local colours = {
      Normal = 'Type',
      Visual = 'Special',
      Insert = 'String',
      Replace = 'Number',
      Command = 'Identifier',
    }
    for mode, hl_name in pairs(colours) do
      local bg = vim.api.nvim_get_hl(0, { name = hl_name, link = false }).fg
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
  vim.api.nvim_create_autocmd({ 'FocusGained', 'BufWritePost', 'User' }, {
    group = my.augroup,
    pattern = { '*', 'NeogitStatusRefreshed' },
    desc = 'Update git statusline',
    callback = function()
      local status_result = vim.system(
        { 'git', 'status', '--porcelain' },
        { text = true }
      ):wait()
      if status_result.code ~= 0 then
        -- Not a git repository.
        git_status = ''
        return
      end
      local has_uncommitted_changes = status_result.stdout ~= ''
      local branch_diff = vim.system(
        { 'git', 'rev-list', '--left-right', '--count', 'HEAD...@{u}' },
        { text = true }
      ):wait()
      local ahead, behind = unpack(vim.split(branch_diff.stdout, '\t'))
      git_status = table.concat {
        has_uncommitted_changes and '[*]' or '',
        (tonumber(ahead) or 0) > 0 and string.format('[+%d]', ahead) or '',
        (tonumber(behind) or 0) > 0 and string.format('[-%d]', behind) or '',
      }
    end,
  })
end

function my.statusline()
  local file = '%f%( %h%w%m%r%)'
  if vim.api.nvim_get_current_win() ~= tonumber(vim.g.actual_curwin) then
    return table.concat {
      '%#StatusLine# ',
      vim.fn.winnr(), ' ',

      '%#StatusLineNC# ',
      '%<',
      file,
    }
  end

  local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
  local mode_info = modes[mode] or {
    long = 'UNKNOWN-' .. mode,
    short = '?' .. mode,
    hl = '%#MyStatusLineNormal#',
  }
  local cwd_path = vim.split(vim.fn.getcwd(), '/')
  local searchcount = ''
  if vim.v.hlsearch == 1 then
    local ok, search = pcall(vim.fn.searchcount)
    if ok and search.current > 0 then
      local dir = vim.v.searchforward == 1 and '/' or '?'
      local current = search.current > search.maxcount and
        search.current .. '+' or
        search.current
      local total = search.total > search.maxcount and
        search.total .. '+' or
        search.total
      searchcount = string.format('%s%s [%s/%s]',
        dir, vim.fn.getreg('/'), current, total)
    end
  end
  local reg = vim.fn.reg_recording()
  local macro = reg ~= '' and 'recording @' .. reg or ''
  local progress = table.concat {
    vim.ui.progress_status(),
    vim.opt.busy:get() > 0 and '◐' or '',
  }
  local percentage = '%3p%%'
  local ruler = '%l:%c'
  local width = vim.api.nvim_win_get_width(0)

  return table.concat {
    mode_info.hl, ' ',
    width >= 100 and mode_info.long or mode_info.short, ' ',

    width >= 80 and table.concat {
      '%#StatusLine# ',
      cwd_path[#cwd_path], ' ',
      git_status ~= '' and git_status .. ' ' or '',
    } or '',

    '%#StatusLineNC# ',
    '%<',
    file, ' ',
    vim.diagnostic.status():gsub('%%#(%a+)#', '%%$%1$'), -- Respect bg
    '%#StatusLineNC# ', -- Reset diagnostic styling
    '%=',
    searchcount ~= '' and searchcount .. ' ' or '',
    (vim.w.quickfix_title or '') ~= '' and vim.w.quickfix_title .. ' ' or '',
    macro ~= '' and macro .. ' ' or '',
    progress ~= '' and progress .. ' ' or '',

    width >= 80 and table.concat {
      '%#StatusLine# ',
      percentage, ' ',
    } or '',

    mode_info.hl, ' ',
    width >= 100 and string.format('%%6(%s%%)', ruler) or ruler, ' ',
  }
end

vim.opt.statusline = '%{% v:lua.my.statusline() %}'
vim.opt.shortmess:append 'Sq'
vim.opt.showmode = false
vim.g.qf_disable_statusline = 1

vim.api.nvim_create_autocmd({ 'ModeChanged' }, {
  group = my.augroup,
  desc = 'Redraw statusline on mode change',
  -- Visual line/block mode doesn't update statusline automatically
  command = 'redrawstatus',
})
