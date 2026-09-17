return {
  -- navigate lsp links
  {
    'icholy/lsplinks.nvim',
    event = 'LspAttach',
    config = function()
      local lsplinks = require('lsplinks')
      lsplinks.setup()
      vim.keymap.set('n', 'gx', lsplinks.gx)
    end,
  },
}
