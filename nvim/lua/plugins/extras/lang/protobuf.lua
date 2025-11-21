return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'proto' } },
  },

  {
    'williamboman/mason.nvim',
    opts = { ensure_installed = { 'buf' } },
  },

  -- formatters
  {
    'stevearc/conform.nvim',
    optional = true,
    opts = {
      formatters_by_ft = {
        proto = {
          'buf',
        },
      },
    },
  },
}
