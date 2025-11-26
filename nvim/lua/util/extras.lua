---@class editor.util.extras
local M = {}

local uv = vim.loop

---@alias WantsOpts {ft?: string|string[], root?: string|string[]}

---@class LazyExtra
---@field name string              -- 模块名（如 "lang/typescript"）
---@field module string             -- 完整导入路径（如 "plugins/extras/lang/typescript"）
---@field desc string|nil           -- 描述
---@field enabled boolean           -- 是否已启用
---@field recommended boolean|nil   -- 是否推荐
---@field row number|nil            -- UI 中的行号

--- Current buffer for wants detection
M.buf = 0

--- Check if an extra should be recommended based on filetype and root patterns
---@param opts WantsOpts
---@return boolean
function M.wants(opts)
  if opts.ft then
    -- Normalize to array
    local filetypes = type(opts.ft) == 'string' and { opts.ft } or opts.ft
    local current_ft = vim.bo[M.buf].filetype

    for _, ft in ipairs(filetypes) do
      if current_ft == ft then
        return true
      end
    end
  end

  if opts.root then
    -- Normalize to array
    local patterns = type(opts.root) == 'string' and { opts.root } or opts.root

    -- Get buffer path
    local buf_path = vim.api.nvim_buf_get_name(M.buf)
    if buf_path == '' then
      buf_path = vim.loop.cwd()
    end

    -- Find root directory with any of the patterns
    local found = vim.fs.find(patterns, {
      path = buf_path,
      upward = true,
      type = 'file',
    })

    return #found > 0
  end

  return false
end

--- Get information about a single extra
---@param path string Relative path like "lang/typescript"
---@return LazyExtra|nil
function M.get_extra(path)
  local module_name = 'plugins/extras/' .. path

  -- Try to load the module
  local ok, module_data = pcall(require, module_name)
  if not ok then
    return nil
  end

  -- Extract metadata from the module itself
  local recommended = module_data.recommended or false
  local desc = module_data.desc

  -- Evaluate recommended
  if type(recommended) == 'function' then
    local func_ok, result = pcall(recommended)
    recommended = func_ok and result or false
  elseif type(recommended) == 'table' then
    recommended = M.wants(recommended)
  end

  return {
    name = path,
    module = module_name,
    desc = desc,
    enabled = false, -- Will be set later
    recommended = recommended and true or false,
  }
end

--- Scan extras directory and get all extras
---@return LazyExtra[]
function M.get()
  local extras_path = vim.fn.stdpath('config') .. '/lua/plugins/extras/lang'
  local json = require('util.json')
  local config = json.load()
  local enabled_set = {}

  -- Build enabled set for O(1) lookup
  for _, extra_module in ipairs(config.extras) do
    enabled_set[extra_module] = true
  end

  ---@param dir string
  ---@param base string
  ---@return LazyExtra[]
  local function scan_dir(dir, base)
    local result = {}
    local handle = uv.fs_scandir(dir)
    if not handle then
      return result
    end

    while true do
      local name, type = uv.fs_scandir_next(handle)
      if not name then
        break
      end

      local full_path = dir .. '/' .. name
      local rel_path = base == '' and name or (base .. '/' .. name)

      if type == 'directory' then
        -- Recursively scan subdirectories
        vim.list_extend(result, scan_dir(full_path, rel_path))
      elseif type == 'file' and name:match('%.lua$') and name ~= 'init.lua' then
        -- Found a plugin file
        local extra_name = 'lang/' .. rel_path:gsub('%.lua$', '')
        local extra = M.get_extra(extra_name)

        if extra then
          -- Check if enabled
          extra.enabled = enabled_set[extra.module] or false
          table.insert(result, extra)
        end
      elseif name == 'init.lua' and base ~= '' then
        -- Handle init.lua as the module itself
        local extra_name = 'lang/' .. base
        local extra = M.get_extra(extra_name)
        if extra then
          extra.enabled = enabled_set[extra.module] or false
          table.insert(result, extra)
        end
      end
    end

    return result
  end

  local extras = scan_dir(extras_path, '')

  -- Sort by name
  table.sort(extras, function(a, b)
    return a.name < b.name
  end)

  return extras
end

--- Save enabled extras to configuration
---@param extras LazyExtra[]
function M.save(extras)
  local json = require('util.json')
  local enabled_modules = {}

  for _, extra in ipairs(extras) do
    if extra.enabled then
      table.insert(enabled_modules, extra.module)
    end
  end

  json.data.extras = enabled_modules
  json.save()
end

--- Show EditorExtras UI
function M.show()
  -- Will be implemented in step 3
  require('util.extras.ui').show()
end

return M
