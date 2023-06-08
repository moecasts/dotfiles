local M = {}

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
M.on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap = true, silent = true }
  local keymap = vim.api.nvim_buf_set_keymap
  keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', bufopts)
  keymap(bufnr, 'n', 'gd', '<cmd>Telescope lsp_definitions<CR>', bufopts)
  keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', bufopts)
  keymap(bufnr, 'n', 'gI', '<cmd>Telescope lsp_implementations<cr>', bufopts)
  keymap(bufnr, 'n', 'gr', '<cmd>Telescope lsp_references<cr>', bufopts)
  keymap(bufnr, 'n', 'gl', '<cmd>lua vim.diagnostic.open_float()<CR>', bufopts)
  keymap(bufnr, 'n', '<leader>lf', '<cmd>lua vim.lsp.buf.format{ async = true }<cr>', bufopts)
  keymap(bufnr, 'n', '<leader>li', '<cmd>LspInfo<cr>', bufopts)
  keymap(bufnr, 'n', '<leader>lI', '<cmd>LspInstallInfo<cr>', bufopts)
  keymap(bufnr, 'n', '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<cr>', bufopts)
  keymap(bufnr, 'n', '<leader>lj', '<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>', bufopts)
  keymap(bufnr, 'n', '<leader>lk', '<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>', bufopts)
  keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', bufopts)
  keymap(bufnr, 'n', '<leader>ls', '<cmd>lua vim.lsp.buf.signature_help()<CR>', bufopts)
  keymap(bufnr, 'n', '<leader>lq', '<cmd>lua vim.diagnostic.setloclist()<CR>', bufopts)
  keymap(bufnr, 'n', '<leader>ll', '<cmd>lua vim.diagnostic.open_float()<CR>', bufopts)
end

return M
