---@class editor.util.json
local M = {}

M.path = vim.fn.stdpath('config') .. '/editor.json'

---@class EditorJsonData
---@field version number
---@field extras string[]

---@type EditorJsonData
M.data = {
  version = 1,
  extras = {},
}

--- Load configuration from editor.json
---@return EditorJsonData
function M.load()
  local file = io.open(M.path, 'r')
  if not file then
    -- Return default data if file doesn't exist
    return vim.deepcopy(M.data)
  end

  local content = file:read('*a')
  file:close()

  local ok, decoded = pcall(vim.json.decode, content)
  if not ok or type(decoded) ~= 'table' then
    vim.notify('Failed to parse editor.json, using defaults', vim.log.levels.WARN, { title = 'Editor' })
    return vim.deepcopy(M.data)
  end

  -- Merge with defaults to ensure all fields exist
  M.data = vim.tbl_deep_extend('force', M.data, decoded)
  return M.data
end

--- Save configuration to editor.json
---@param data? EditorJsonData
function M.save(data)
  data = data or M.data

  local ok, encoded = pcall(vim.json.encode, data)
  if not ok then
    vim.notify('Failed to encode editor.json', vim.log.levels.ERROR, { title = 'Editor' })
    return false
  end

  local file = io.open(M.path, 'w')
  if not file then
    vim.notify('Failed to open editor.json for writing', vim.log.levels.ERROR, { title = 'Editor' })
    return false
  end

  file:write(encoded)
  file:close()

  vim.notify('Configuration saved to editor.json', vim.log.levels.INFO, { title = 'Editor' })
  return true
end

--- Check if editor.json exists
---@return boolean
function M.exists()
  return vim.fn.filereadable(M.path) == 1
end

--- Initialize editor.json with current extras
---@param extras string[]
function M.init(extras)
  M.data.extras = extras or {}
  M.save()
end

return M
