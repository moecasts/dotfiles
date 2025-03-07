local lsp = 'intelephense'

return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'php' } },
  },

  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        phpactor = {
          enabled = lsp == 'phpactor',
        },
        intelephense = {
          enabled = lsp == 'intelephense',
        },
        [lsp] = {
          enabled = true,
        },
      },
    },
  },

  {
    'williamboman/mason.nvim',
    opts = {
      ensure_installed = {
        'pint',
        'phpcs',
        'php-cs-fixer',
      },
    },
  },

  -- formatters
  {
    'stevearc/conform.nvim',
    optional = true,
    opts = {
      formatters_by_ft = {
        php = {
          'pint',
          'php_cs_fixer',
        },
      },
    },
  },

  -- dap
  {
    'mfussenegger/nvim-dap',
    optional = true,
    opts = function()
      local dap = require('dap')
      local path = require('mason-registry').get_package('php-debug-adapter'):get_install_path()
      dap.adapters.php = {
        type = 'executable',
        command = 'node',
        args = { path .. '/extension/out/phpDebug.js' },
      }
    end,
  },

  -- code actions
  {
    'nvimtools/none-ls.nvim',
    optional = true,
    opts = function(_, opts)
      local nls = require('null-ls')
      opts.sources = opts.sources or {}
      table.insert(opts.sources, nls.builtins.formatting.phpcsfixer)
      table.insert(opts.sources, nls.builtins.diagnostics.phpcs)
    end,
  },

  -- lint
  {
    'mfussenegger/nvim-lint',
    optional = true,
    opts = {
      linters_by_ft = {
        php = {
          -- 'phpcs'
        },
      },
    },
  },

  -- blade
  {
    -- Add a Treesitter parser for Laravel Blade to provide Blade syntax highlighting.
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        'blade',
        'php_only',
      })
    end,
    config = function(_, opts)
      vim.filetype.add({
        pattern = {
          ['.*%.blade%.php'] = 'blade',
        },
      })

      require('nvim-treesitter.configs').setup(opts)

      local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
      parser_config.blade = {
        install_info = {
          url = 'https://github.com/EmranMR/tree-sitter-blade',
          files = { 'src/parser.c' },
          branch = 'main',
        },
        filetype = 'blade',
      }
    end,
  },
}
