return {
  -- lspconfig
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'simrat39/rust-tools.nvim',
      'jose-elias-alvarez/typescript.nvim',
    },
    opts = {
      -- options for vim.diagnostic.config()
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = false,
        -- virtual_text = { spacing = 4, prefix = '●' },
        severity_sort = true,
      },

      -- Automatically format on save
      autoformat = true,

      -- options for vim.lsp.buf.format
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },

      -- LSP Server Settings
      ---@type lspconfig.options
      servers = {
        tsserver = {
          settings = {
            javascript = {
              format = {
                semicolons = 'insert',
              },
              preferences = {
                quoteStyle = 'single',
              },
            },
            typescript = {
              format = {
                semicolons = 'insert',
              },
              preferences = {
                quoteStyle = 'single',
              },
            },
          },
        },
        jsonls = {},
        cssls = {},
        html = {},
        lua_ls = {},
        -- pyright = {},
        bashls = {},
        yamlls = {},
        rust_analyzer = {},
        -- codelldb = {},
        gopls = {},
      },

      setup = {
        -- example to setup with typescript.nvim
        tsserver = function(_, opts)
          require('typescript').setup({ server = opts })
          return true
        end,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
        rust_analyzer = function(_, opts)
          require('util').on_attach(function(client, buffer)
            -- stylua: ignore
            if client.name == "rust_analyzer" then
              vim.keymap.set("n", "K", "<CMD>RustHoverActions<CR>", { buffer = buffer })
              vim.keymap.set("n", "<leader>ct", "<CMD>RustDebuggables<CR>", { buffer = buffer, desc = "Run Test" })
              vim.keymap.set("n", "<leader>dr", "<CMD>RustDebuggables<CR>", { buffer = buffer, desc = "Run" })
            end
          end)
          local mason_registry = require('mason-registry')
          -- rust tools configuration for debugging support
          local codelldb = mason_registry.get_package('codelldb')
          local extension_path = codelldb:get_install_path() .. '/extension/'
          local codelldb_path = extension_path .. 'adapter/codelldb'
          local liblldb_path = vim.fn.has('mac') == 1 and extension_path .. 'lldb/lib/liblldb.dylib'
              or extension_path .. 'lldb/lib/liblldb.so'
          local rust_tools_opts = vim.tbl_deep_extend('force', opts, {
            dap = {
              adapter = require('rust-tools.dap').get_codelldb_adapter(codelldb_path, liblldb_path),
            },
            tools = {
              hover_actions = {
                auto_focus = false,
                border = 'none',
              },
              inlay_hints = {
                auto = false,
                show_parameter_hints = true,
              },
            },
            server = {
              settings = {
                ['rust-analyzer'] = {
                  cargo = {
                    features = 'all',
                  },
                  -- Add clippy lints for Rust.
                  checkOnSave = true,
                  check = {
                    command = 'clippy',
                    features = 'all',
                  },
                  procMacro = {
                    enable = true,
                  },
                },
              },
            },
          })
          require('rust-tools').setup(rust_tools_opts)
          return true
        end,
      },
    },
    config = function(plugin, opts)
      -- setup autoformat
      require('plugins.lsp.format').autoformat = opts.autoformat

      -- setup formatting and keymaps
      require('util').on_attach(function(client, buffer)
        require('plugins.lsp.format').on_attach(client, buffer)
        require('plugins.lsp.keymaps').on_attach(client, buffer)
      end)

      -- diagnostics
      for name, icon in pairs(require('config').icons.diagnostics) do
        name = 'DiagnosticSign' .. name
        vim.fn.sign_define(name, { text = icon, texthl = name, numhl = '' })
      end
      vim.diagnostic.config(opts.diagnostics)

      local servers = opts.servers
      local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

      local setup = function(server)
        local server_opts = vim.tbl_deep_extend('force', {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then
            return
          end
        elseif opts.setup['*'] then
          if opts.setup['*'](server, server_opts) then
            return
          end
        end
        require('lspconfig')[server].setup(server_opts)
      end

      local mlsp = require('mason-lspconfig')
      local available = mlsp.get_available_servers()

      local ensure_installed = {} ---@type string[]
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
          if server_opts.mason == false or not vim.tbl_contains(available, server) then
            setup(server)
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end

      require('mason-lspconfig').setup({
        ensure_installed = ensure_installed,
        automatic_installation = true,
      })
      require('mason-lspconfig').setup_handlers({ setup })
    end,
  },

  -- formatters
  {
    'nvimtools/none-ls.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'mason.nvim' },
    enabled = false,
    opts = function()
      local nls = require('null-ls')

      nls.setup({
        -- you can reuse a shared lspconfig on_attach callback here
        on_attach = require('plugins.lsp.format').on_attach,

        sources = {
          -- code spell
          nls.builtins.diagnostics.cspell.with({
            diagnostics_postprocess = function(diagnostic)
              diagnostic.severity = vim.diagnostic.severity.HINT
            end,
          }),
          nls.builtins.code_actions.cspell,

          nls.builtins.formatting.stylua,
          -- nls.builtins.diagnostics.eslint,
          -- nls.builtins.completion.spell,

          nls.builtins.formatting.prettier,
          -- nls.builtins.completion.luasnip,

          -- eslint
          nls.builtins.formatting.eslint_d,
          nls.builtins.diagnostics.eslint_d.with({
            condition = function(utils)
              return utils.root_has_file({
                'eslint.config.js',
                -- https://eslint.org/docs/user-guide/configuring/configuration-files#configuration-file-formats
                '.eslintrc',
                '.eslintrc.js',
                '.eslintrc.cjs',
                '.eslintrc.yaml',
                '.eslintrc.yml',
                '.eslintrc.json',
              })
            end,
          }),
          nls.builtins.code_actions.eslint_d,

          -- clang_format
          nls.builtins.formatting.clang_format.with({
            extra_args = {
              '--style',
              '{ BasedOnStyle: google, AlignConsecutiveAssignments: true, AlignConsecutiveDeclarations: true }',
            },
          }),

          -- golang
          nls.builtins.formatting.gofumpt,
          nls.builtins.formatting.goimports_reviser,
          nls.builtins.formatting.golines,

          -- typescript
          require('typescript.extensions.null-ls.code-actions'),
        },
      })
    end,
  },

  -- lint
  {
    "mfussenegger/nvim-lint",
    -- event = "LazyFile",
    opts = {
      -- Event to trigger linters
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        -- Use the "*" filetype to run linters on all filetypes.
        -- ['*'] = { 'global linter' },
        -- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
        -- ['_'] = { 'fallback linter' },
        -- ["*"] = { "typos" },
      },
      -- LazyVim extension to easily override linter options
      -- or add custom linters.
      ---@type table<string,table>
      linters = {
        -- -- Example of using selene only when a selene.toml file is present
        -- selene = {
        --   -- `condition` is another LazyVim extension that allows you to
        --   -- dynamically enable/disable linters based on the context.
        --   condition = function(ctx)
        --     return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
      },
    },
    config = function(_, opts)
      local M = {}

      local lint = require("lint")
      for name, linter in pairs(opts.linters) do
        if type(linter) == "table" and type(lint.linters[name]) == "table" then
          lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
          if type(linter.prepend_args) == "table" then
            lint.linters[name].args = lint.linters[name].args or {}
            vim.list_extend(lint.linters[name].args, linter.prepend_args)
          end
        else
          lint.linters[name] = linter
        end
      end
      lint.linters_by_ft = opts.linters_by_ft

      function M.debounce(ms, fn)
        local timer = vim.uv.new_timer()
        return function(...)
          local argv = { ... }
          timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
          end)
        end
      end

      function M.lint()
        -- Use nvim-lint's logic first:
        -- * checks if linters exist for the full filetype first
        -- * otherwise will split filetype by "." and add all those linters
        -- * this differs from conform.nvim which only uses the first filetype that has a formatter
        local names = lint._resolve_linter_by_ft(vim.bo.filetype)

        -- Create a copy of the names table to avoid modifying the original.
        names = vim.list_extend({}, names)

        -- Add fallback linters.
        if #names == 0 then
          vim.list_extend(names, lint.linters_by_ft["_"] or {})
        end

        -- Add global linters.
        vim.list_extend(names, lint.linters_by_ft["*"] or {})

        -- Filter out linters that don't exist or don't match the condition.
        local ctx = { filename = vim.api.nvim_buf_get_name(0) }
        ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
        names = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          if not linter then
            LazyVim.warn("Linter not found: " .. name, { title = "nvim-lint" })
          end
          return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
        end, names)

        -- Run linters.
        if #names > 0 then
          lint.try_lint(names)
        end
      end

      vim.api.nvim_create_autocmd(opts.events, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = M.debounce(100, M.lint),
      })
    end,
  },

  -- cmdline tools and lsp servers
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' } },
    opts = {
      ensure_installed = {
        'stylua',
        'shellcheck',
        'shfmt',
        'flake8',
        'codelldb',
        'cspell',
        'clang-format',
        'gofumpt',
        'goimports',
        'goimports-reviser',
        'eslint_d',
      },
    },
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(plugin, opts)
      require('mason').setup(opts)
      local mr = require('mason-registry')
      for _, tool in ipairs(opts.ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end,
  },
}
