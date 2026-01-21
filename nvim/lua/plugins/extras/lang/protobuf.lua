return {
  recommended = {
    ft = { 'proto' },
    root = { 'buf.yaml', 'buf.work.yaml', '.git' },
  },

  desc = 'Protocol Buffers support with buf LSP',

  -- Treesitter support for proto files
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'proto' } },
  },

  -- LSP configuration using buf CLI's built-in LSP
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        bufls = {
          -- buf LSP configuration
          -- Uses buf CLI's built-in LSP server (buf beta lsp)
          -- https://buf.build/docs/editor-integration
          cmd = { 'buf', 'beta', 'lsp' },
          filetypes = { 'proto' },
          root_dir = function(fname)
            local util = require('lspconfig.util')
            return util.root_pattern('buf.yaml', 'buf.work.yaml', '.git')(fname)
          end,
          single_file_support = true,
        },
      },
    },
  },

  -- Ensure buf is installed via Mason
  {
    'williamboman/mason.nvim',
    opts = { ensure_installed = { 'buf' } },
  },

  -- Formatter support with buf format
  {
    'stevearc/conform.nvim',
    optional = true,
    opts = {
      formatters_by_ft = {
        proto = { 'buf' },
      },
    },
  },

  -- Linting support with buf lint
  {
    'mfussenegger/nvim-lint',
    optional = true,
    opts = {
      linters_by_ft = {
        proto = { 'buf_lint' },
      },
    },
  },
}
