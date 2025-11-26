---@class editor.util.extras.ui
local M = {}

local api = vim.api

---@class ExtrasUI
---@field buf number
---@field win number
---@field extras LazyExtra[]
local UI = {}
UI.__index = UI

--- Create a new UI instance
---@return ExtrasUI
function UI:new()
  local obj = setmetatable({}, self)
  obj.extras = require('util.extras').get()
  return obj
end

--- Render a section of extras
---@param lines string[]
---@param highlights table[]
---@param extras LazyExtra[]
---@param title string
---@param filter fun(extra: LazyExtra): boolean
---@return number line_count
function UI:render_section(lines, highlights, extras, title, filter)
  local section_extras = vim.tbl_filter(filter, extras)

  if #section_extras == 0 then
    return 0
  end

  -- Add section title
  table.insert(lines, '')
  table.insert(lines, ' ' .. title)
  table.insert(highlights, {
    line = #lines - 1,
    col = 1,
    end_col = #title + 1,
    hl_group = 'Title',
  })

  -- Add extras
  for _, extra in ipairs(section_extras) do
    local line_num = #lines
    extra.row = line_num + 1 -- Store row for toggle functionality

    local prefix = '   '
    local icon = ''
    local status = ''

    if extra.enabled then
      status = '✓ '
      icon = ''
    elseif extra.recommended then
      icon = '❤️ '
    end

    local line = prefix .. status .. icon .. extra.name
    if extra.desc then
      line = line .. '  ' .. extra.desc
    end

    table.insert(lines, line)

    -- Highlight status
    if extra.enabled then
      table.insert(highlights, {
        line = line_num,
        col = #prefix,
        end_col = #prefix + #status,
        hl_group = 'DiagnosticOk',
      })
    end

    -- Highlight icon
    if extra.recommended and not extra.enabled then
      table.insert(highlights, {
        line = line_num,
        col = #prefix + #status,
        end_col = #prefix + #status + vim.fn.strchars(icon),
        hl_group = 'DiagnosticError',
      })
    end

    -- Highlight name
    table.insert(highlights, {
      line = line_num,
      col = #prefix + #status + vim.fn.strchars(icon),
      end_col = #prefix + #status + vim.fn.strchars(icon) + #extra.name,
      hl_group = extra.enabled and 'Normal' or 'Comment',
    })
  end

  return #section_extras
end

--- Render the UI
function UI:render()
  local lines = {}
  local highlights = {}

  -- Header
  table.insert(lines, '')
  table.insert(lines, ' Editor Extras - Language Support')
  table.insert(highlights, {
    line = 1,
    col = 1,
    end_col = 35,
    hl_group = 'Title',
  })
  table.insert(lines, ' Manage language extras dynamically')
  table.insert(highlights, {
    line = 2,
    col = 1,
    end_col = 37,
    hl_group = 'Comment',
  })

  -- Recommended Languages (not enabled)
  self:render_section(lines, highlights, self.extras, '📝 Recommended Languages', function(e)
    return e.recommended and not e.enabled
  end)

  -- Enabled Languages
  self:render_section(lines, highlights, self.extras, '✅ Enabled Languages', function(e)
    return e.enabled
  end)

  -- Other Languages
  self:render_section(lines, highlights, self.extras, '📦 Available Languages', function(e)
    return not e.enabled and not e.recommended
  end)

  -- Footer
  table.insert(lines, '')
  table.insert(lines, ' [x] toggle  [q] close  [?] help')
  table.insert(highlights, {
    line = #lines - 1,
    col = 1,
    end_col = #lines[#lines],
    hl_group = 'Comment',
  })

  -- Set lines
  api.nvim_buf_set_lines(self.buf, 0, -1, false, lines)

  -- Apply highlights
  for _, hl in ipairs(highlights) do
    api.nvim_buf_add_highlight(self.buf, -1, hl.hl_group, hl.line, hl.col, hl.end_col)
  end

  -- Make buffer read-only
  vim.bo[self.buf].modifiable = false
end

--- Toggle extra at current cursor position
function UI:toggle()
  local pos = api.nvim_win_get_cursor(self.win)
  local line = pos[1]

  for _, extra in ipairs(self.extras) do
    if extra.row == line then
      extra.enabled = not extra.enabled

      -- Save configuration
      require('util.extras').save(self.extras)

      -- Refresh UI
      vim.bo[self.buf].modifiable = true
      self:render()

      -- Notify user
      local msg = extra.enabled and 'Enabled' or 'Disabled'
      vim.notify(
        msg .. ' ' .. extra.name .. '. Please restart Neovim to apply changes.',
        vim.log.levels.INFO,
        { title = 'Editor Extras' }
      )

      return
    end
  end
end

--- Show help
function UI:show_help()
  local help_lines = {
    '',
    ' Editor Extras - Language Support',
    '',
    ' x       - Toggle language support on/off',
    ' q / Esc - Close window',
    ' ?       - Show this help',
    '',
    ' ❤️       - Recommended language',
    ' ✓       - Enabled language',
    '',
    ' Note: Only language extras (lang/*) are managed here.',
    ' Other plugins (editor, coding, etc.) are always loaded.',
    '',
    ' Press any key to close...',
  }

  local help_buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(help_buf, 0, -1, false, help_lines)
  vim.bo[help_buf].modifiable = false

  local width = 55
  local height = #help_lines
  local help_win = api.nvim_open_win(help_buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = 'minimal',
    border = 'rounded',
    title = ' Help ',
    title_pos = 'center',
  })

  -- Close on any key
  vim.keymap.set('n', '<buffer>', function()
    api.nvim_win_close(help_win, true)
  end, { buffer = help_buf })
end

--- Close the UI
function UI:close()
  if self.win and api.nvim_win_is_valid(self.win) then
    api.nvim_win_close(self.win, true)
  end
end

--- Show the UI
function UI:show_ui()
  -- Create buffer
  self.buf = api.nvim_create_buf(false, true)
  vim.bo[self.buf].bufhidden = 'wipe'
  vim.bo[self.buf].filetype = 'editor-extras'

  -- Calculate window size
  local width = math.min(100, vim.o.columns - 4)
  local height = math.min(40, vim.o.lines - 4)

  -- Create window
  self.win = api.nvim_open_win(self.buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = 'minimal',
    border = 'rounded',
    title = ' Language Extras ',
    title_pos = 'center',
  })

  -- Set up keymaps
  local opts = { buffer = self.buf, nowait = true }

  vim.keymap.set('n', 'x', function()
    self:toggle()
  end, opts)

  vim.keymap.set('n', 'q', function()
    self:close()
  end, opts)

  vim.keymap.set('n', '<Esc>', function()
    self:close()
  end, opts)

  vim.keymap.set('n', '?', function()
    self:show_help()
  end, opts)

  -- Render
  self:render()
end

--- Entry point
function M.show()
  local ui = UI:new()
  ui:show_ui()
end

return M
