return {
  -- lspconfig
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
    dependencies = {
      {
        'mason.nvim',
        version = '^1.0.0',
      },

      {
        'williamboman/mason-lspconfig.nvim',
        version = '^1.0.0',
      },
    },
    opts = {
      -- options for vim.diagnostic.config()
      ---@type vim.diagnostic.Opts
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = false,
        -- virtual_text = {
        --   spacing = 4,
        --   source = "if_many",
        --   prefix = "●",
        --   -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
        --   -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
        --   -- prefix = "icons",
        -- },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = require('config').icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = require('config').icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = require('config').icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = require('config').icons.diagnostics.Info,
          },
        },
      },
      -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the inlay hints.
      inlay_hints = {
        enabled = false,
        exclude = { 'vue' }, -- filetypes for which you don't want to enable inlay hints
      },
      -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the code lenses.
      codelens = {
        enabled = false,
      },
      -- add any global capabilities here
      capabilities = {
        workspace = {
          fileOperations = {
            didRename = true,
            willRename = true,
          },
        },
      },
      -- options for vim.lsp.buf.format
      -- `bufnr` and `filter` is handled by the Editor formatter,
      -- but can be also overridden when specified
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },

      -- LSP Server Settings
      ---@type lspconfig.options
      servers = {
        jsonls = {},
        cssls = {},
        html = {},
        lua_ls = {},
        -- pyright = {},
        bashls = {},
        yamlls = {},
      },

      setup = {},
    },
    config = function(plugin, opts)
      -- setup autoformat
      Editor.format.register(Editor.lsp.formatter())

      -- setup formatting and keymaps
      require('util').on_attach(function(client, buffer)
        require('util.lsp-keymaps').on_attach(client, buffer)
      end)

      Editor.lsp.setup()
      Editor.lsp.on_dynamic_capability(require('util.lsp-keymaps').on_attach)

      -- diagnostics signs
      if vim.fn.has('nvim-0.10.0') == 0 then
        if type(opts.diagnostics.signs) ~= 'boolean' then
          for severity, icon in pairs(opts.diagnostics.signs.text) do
            local name = vim.diagnostic.severity[severity]:lower():gsub('^%l', string.upper)
            name = 'DiagnosticSign' .. name
            vim.fn.sign_define(name, { text = icon, texthl = name, numhl = '' })
          end
        end
      end

      if vim.fn.has('nvim-0.10') == 1 then
        -- inlay hints
        if opts.inlay_hints.enabled then
          Editor.lsp.on_supports_method('textDocument/inlayHint', function(client, buffer)
            if
              vim.api.nvim_buf_is_valid(buffer)
              and vim.bo[buffer].buftype == ''
              and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
            then
              vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
            end
          end)
        end

        -- code lens
        if opts.codelens.enabled and vim.lsp.codelens then
          Editor.lsp.on_supports_method('textDocument/codeLens', function(client, buffer)
            vim.lsp.codelens.refresh()
            vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
              buffer = buffer,
              callback = vim.lsp.codelens.refresh,
            })
          end)
        end
      end

      if type(opts.diagnostics.virtual_text) == 'table' and opts.diagnostics.virtual_text.prefix == 'icons' then
        opts.diagnostics.virtual_text.prefix = vim.fn.has('nvim-0.10.0') == 0 and '●'
          or function(diagnostic)
            local icons = Editor.config.icons.diagnostics
            for d, icon in pairs(icons) do
              if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
                return icon
              end
            end
          end
      end

      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      local servers = opts.servers
      local has_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
      local has_blink, blink = pcall(require, 'blink.cmp')
      local capabilities = vim.tbl_deep_extend(
        'force',
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {},
        has_blink and blink.get_lsp_capabilities() or {},
        opts.capabilities or {}
      )

      local function setup(server)
        local server_opts = vim.tbl_deep_extend('force', {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})
        if server_opts.enabled == false then
          return
        end

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

      -- get all the servers that are available through mason-lspconfig
      local have_mason, mlsp = pcall(require, 'mason-lspconfig')
      local all_mslp_servers = {}
      if have_mason then
        all_mslp_servers = vim.tbl_keys(require('mason-lspconfig.mappings.server').lspconfig_to_package)
      end

      local ensure_installed = {} ---@type string[]
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          if server_opts.enabled ~= false then
            -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
            if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
              setup(server)
            else
              local server_identifier = server
              if server_opts.version then
                server_identifier = server .. '@' .. server_opts.version
              end
              ensure_installed[#ensure_installed + 1] = server_identifier
            end
          end
        end
      end

      if have_mason then
        mlsp.setup({
          ensure_installed = vim.tbl_deep_extend(
            'force',
            ensure_installed,
            Editor.opts('mason-lspconfig.nvim').ensure_installed or {}
          ),
          handlers = { setup },
        })
      end

      if Editor.lsp.is_enabled('denols') and Editor.lsp.is_enabled('vtsls') then
        local is_deno = require('lspconfig.util').root_pattern('deno.json', 'deno.jsonc')
        Editor.lsp.disable('vtsls', is_deno)
        Editor.lsp.disable('denols', function(root_dir, config)
          if not is_deno(root_dir) then
            config.settings.deno.enable = false
          end
          return false
        end)
      end
    end,
  },

  -- cmdline tools and lsp servers
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' } },
    opts_extend = { 'ensure_installed' },
    opts = {
      ensure_installed = {
        'stylua',
        'shellcheck',
        'shfmt',
        'flake8',
        'cspell',
        'clang-format',
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
