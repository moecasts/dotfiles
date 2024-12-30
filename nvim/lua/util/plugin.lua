local M = {}

local uv = vim.loop

-- Using nvim's API, scan all subdirectories under the root path, exclude import specs without Lua files, include the root itself,
-- and generate import specs in the format {{ import = path }}
function M.generate_import_specs(root)
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

return M
