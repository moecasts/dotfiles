local M = {}

---@type LazyKeysLspSpec[]|nil
M._keys = nil

---@alias LazyKeysLspSpec LazyKeysSpec|{has?:string|string[], cond?:fun():boolean}
---@alias LazyKeysLsp LazyKeys|{has?:string|string[], cond?:fun():boolean}

---@return LazyKeysLspSpec[]
function M.get()
  if M._keys then
    return M._keys
  end
    -- stylua: ignore
    M._keys =  {
      { "<leader>cl", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
      { "gd", "<cmd>Telescope lsp_definitions<CR>", desc = "Goto Definition" },
      { "gdv", function() require"telescope.builtin".lsp_definitions({ jump_type="vsplit" }) end, desc = "Goto Definition (vsplit)" },
      { "gds", function() require"telescope.builtin".lsp_definitions({ jump_type="split" }) end, desc = "Goto Definition (split)" },
      { "K", function() vim.lsp.buf.hover() end, desc = "Hover" },
      { "gI", "<cmd>Telescope lsp_implementations<cr>", desc = "Goto Implementation" },
      { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
      { "gl", function() vim.diagnostic.open_float() end, desc = "Show Diagnostics" },
      { "<leader>lf", function() vim.lsp.buf.format{ async = true } end, desc = "Format Document", mode = { "n", "v" } },
      { "<leader>li", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
      { "<leader>lI", "<cmd>LspInstallInfo<cr>", desc = "Lsp Install Info" },
      { "<leader>la", function() vim.lsp.buf.code_action() end, desc = "Code Action" },
      { "<leader>lj", function() vim.diagnostic.goto_next({buffer=0}) end, desc = "Next Diagnostic" },
      { "<leader>lk", function() vim.diagnostic.goto_prev({buffer=0}) end, desc = "Previous Diagnostic" },
      { "<leader>rn", function() vim.lsp.buf.rename() end, desc = "Rename" },
      { "<leader>ls", function() vim.lsp.buf.signature_help() end, desc = "Signature Help" },
      { "<leader>lq", function() vim.diagnostic.setloclist() end, desc = "Set Loclist" },
      { "<leader>ll", function() vim.diagnostic.open_float() end, desc = "Show Diagnostics" },
    }

  return M._keys
end

---@param method string|string[]
function M.has(buffer, method)
  if type(method) == 'table' then
    for _, m in ipairs(method) do
      if M.has(buffer, m) then
        return true
      end
    end
    return false
  end
  method = method:find('/') and method or 'textDocument/' .. method
  local clients = Editor.lsp.get_clients({ bufnr = buffer })
  for _, client in ipairs(clients) do
    if client.supports_method(method) then
      return true
    end
  end
  return false
end

---@return LazyKeysLsp[]
function M.resolve(buffer)
  local Keys = require('lazy.core.handler.keys')
  if not Keys.resolve then
    return {}
  end
  local spec = vim.tbl_extend('force', {}, M.get())
  local opts = Editor.opts('nvim-lspconfig')
  local clients = Editor.lsp.get_clients({ bufnr = buffer })
  for _, client in ipairs(clients) do
    local maps = opts.servers[client.name] and opts.servers[client.name].keys or {}
    vim.list_extend(spec, maps)
  end
  return Keys.resolve(spec)
end

function M.on_attach(_, buffer)
  local Keys = require('lazy.core.handler.keys')
  local keymaps = M.resolve(buffer)
  for _, keys in pairs(keymaps) do
    local has = not keys.has or M.has(buffer, keys.has)
    local cond = not (keys.cond == false or ((type(keys.cond) == 'function') and not keys.cond()))

    if has and cond then
      local opts = Keys.opts(keys)
      opts.cond = nil
      opts.has = nil
      opts.silent = opts.silent ~= false
      opts.buffer = buffer
      vim.keymap.set(keys.mode or 'n', keys.lhs, keys.rhs, opts)
    end
  end
end

return M
