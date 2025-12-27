---@class editor.util.treesitter
local M = {}

M._installed = nil ---@type table<string, boolean>?
M._queries = {} ---@type table<string, boolean>
M.max_filesize = 10 * 1024 -- 10 KB

--- 获取已安装的解析器
---@param update boolean?
function M.get_installed(update)
  if update then
    M._installed, M._queries = {}, {}
    local ok, installed = pcall(function()
      return require('nvim-treesitter').get_installed()
    end)
    if ok then
      for _, lang in ipairs(installed) do
        M._installed[lang] = true
      end
    end
  end
  return M._installed or {}
end

--- 检查语言是否有特定查询
---@param lang string
---@param query string
function M.have_query(lang, query)
  local key = lang .. ':' .. query
  if M._queries[key] == nil then
    M._queries[key] = vim.treesitter.query.get(lang, query) ~= nil
  end
  return M._queries[key]
end

--- 检查 buffer/filetype 是否支持 treesitter
---@param what string|number|nil
---@param query? string
function M.have(what, query)
  what = what or vim.api.nvim_get_current_buf()
  what = type(what) == 'number' and vim.bo[what].filetype or what
  local lang = vim.treesitter.language.get_lang(what)
  if lang == nil or M.get_installed()[lang] == nil then
    return false
  end
  if query and not M.have_query(lang, query) then
    return false
  end
  return true
end

--- 检查是否为大文件
---@param buf number
function M.is_large_file(buf)
  local bufname = vim.api.nvim_buf_get_name(buf)
  local ok, stats = pcall(vim.uv.fs_stat, bufname)
  return ok and stats and stats.size > M.max_filesize
end

--- treesitter foldexpr
function M.foldexpr()
  return M.have(nil, 'folds') and vim.treesitter.foldexpr() or '0'
end

--- treesitter indentexpr
function M.indentexpr()
  return M.have(nil, 'indents') and require('nvim-treesitter').indentexpr() or -1
end

return M
