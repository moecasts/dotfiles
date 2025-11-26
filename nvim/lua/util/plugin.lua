local M = {}

local uv = vim.loop

-- Using nvim's API, scan all subdirectories under the root path, exclude import specs without Lua files, include the root itself,
-- and generate import specs in the format {{ import = path }}
function M.generate_import_specs(root)
  -- Special handling for 'plugins' root with extras management
  if root == 'plugins' then
    return M.generate_plugins_specs()
  end

  local function has_lua_files(dir)
    local handle = uv.fs_scandir(dir)
    if not handle then
      return false
    end

    while true do
      local name, type = uv.fs_scandir_next(handle)
      if not name then
        break
      end
      if type == 'file' and name:match('%.lua$') then
        return true
      end
    end
    return false
  end

  local function scan_dir(dir, base)
    local specs = {}
    local handle = uv.fs_scandir(dir)
    if not handle then
      return specs
    end

    while true do
      local name, type = uv.fs_scandir_next(handle)
      if not name then
        break
      end
      local path = dir .. '/' .. name
      local import_path = base .. '/' .. name
      if type == 'directory' then
        if has_lua_files(path) then
          table.insert(specs, { import = import_path })
        end
        vim.list_extend(specs, scan_dir(path, import_path))
      end
    end
    return specs
  end

  local config_path = vim.fn.stdpath('config') .. '/lua/' .. root
  local specs = {}
  if has_lua_files(config_path) then
    table.insert(specs, { import = root })
  end
  vim.list_extend(specs, scan_dir(config_path, root))
  return specs
end

-- Generate import specs for plugins with extras management
function M.generate_plugins_specs()
  local specs = {}
  local json = require('util.json')

  -- Always import the base plugins directory
  table.insert(specs, { import = 'plugins' })

  -- Helper function to scan and load modules with metadata filtering
  local function scan_dir_with_filter(dir, base)
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
      local path = dir .. '/' .. name
      local import_path = base .. '/' .. name

      if type == 'directory' then
        vim.list_extend(result, scan_dir_with_filter(path, import_path))
      elseif type == 'file' and name:match('%.lua$') and name ~= 'init.lua' then
        -- Load the module and filter metadata
        local module_name = import_path:gsub('%.lua$', '')
        local ok, module_data = pcall(require, module_name)
        if ok and type(module_data) == 'table' then
          -- Extract only plugin specs (numeric indices)
          for key, value in pairs(module_data) do
            if type(key) == 'number' then
              table.insert(result, value)
            end
          end
        end
      end
    end
    return result
  end

  -- Helper function for non-lang imports (no filtering needed)
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
      local path = dir .. '/' .. name
      local import_path = base .. '/' .. name
      if type == 'directory' then
        table.insert(result, { import = import_path })
        vim.list_extend(result, scan_dir(path, import_path))
      end
    end
    return result
  end

  local extras_path = vim.fn.stdpath('config') .. '/lua/plugins/extras'

  -- Always import non-lang extras (editor, coding, formatting, linting, etc.)
  local extras_dirs = vim.fn.readdir(extras_path)
  for _, dir_name in ipairs(extras_dirs) do
    if dir_name ~= 'lang' then
      local dir_path = extras_path .. '/' .. dir_name
      if vim.fn.isdirectory(dir_path) == 1 then
        table.insert(specs, { import = 'plugins/extras/' .. dir_name })
        vim.list_extend(specs, scan_dir(dir_path, 'plugins/extras/' .. dir_name))
      end
    end
  end

  -- For lang extras, use dynamic loading based on editor.json
  if not json.exists() then
    -- No configuration file, load all lang extras with metadata filtering
    local lang_path = extras_path .. '/lang'
    vim.list_extend(specs, scan_dir_with_filter(lang_path, 'plugins/extras/lang'))
  else
    -- Load configuration and only import enabled lang extras
    local config = json.load()
    for _, extra_module in ipairs(config.extras) do
      -- Only add if it's a lang extra
      if extra_module:match('^plugins/extras/lang/') then
        -- Load module and filter out metadata
        local ok, module_data = pcall(require, extra_module)
        if ok and type(module_data) == 'table' then
          -- Extract only plugin specs (numeric indices)
          for key, value in pairs(module_data) do
            if type(key) == 'number' then
              table.insert(specs, value)
            end
          end
        end
      end
    end
  end

  return specs
end

return M
