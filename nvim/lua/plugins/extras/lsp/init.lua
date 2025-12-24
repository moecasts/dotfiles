return {
  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufReadPost', 'BufWritePost', 'BufNewFile' },
    dependencies = {
      'mason.nvim',
      { 'williamboman/mason-lspconfig.nvim', config = function() end },
    },
    ---@class PluginLspOpts
    opts = {
      -- Diagnostics configuration
      ---@type vim.diagnostic.Opts
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = false,
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

      -- Inlay hints
      inlay_hints = {
        enabled = false,
        exclude = { 'vue' },
      },

      -- Code lenses
      codelens = {
        enabled = false,
      },

      -- Format options
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },

      -- LSP Server Settings
      ---@type table<string, vim.lsp.Config|boolean>
      servers = {
        -- Global capabilities for all servers
        ['*'] = {
          capabilities = {
            workspace = {
              fileOperations = {
                didRename = true,
                willRename = true,
              },
            },
          },
        },

        -- Individual server configurations
        jsonls = {},
        cssls = {},
        html = {},
        lua_ls = {},
        bashls = {},
        yamlls = {},
      },

      -- Custom setup handlers
      -- Return true to prevent default setup
      ---@type table<string, fun(server:string, opts:vim.lsp.Config):boolean?>
      setup = {},
    },

    ---@param opts PluginLspOpts
    config = function(_, opts)
      -- Setup autoformat
      Editor.format.register(Editor.lsp.formatter())

      -- Setup keymaps and LSP handlers
      require('util').on_attach(function(client, buffer)
        require('util.lsp-keymaps').on_attach(client, buffer)
      end)

      Editor.lsp.setup()
      Editor.lsp.on_dynamic_capability(require('util.lsp-keymaps').on_attach)

      -- Configure inlay hints
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

      -- Configure code lenses
      if opts.codelens.enabled and vim.lsp.codelens then
        Editor.lsp.on_supports_method('textDocument/codeLens', function(client, buffer)
          vim.lsp.codelens.refresh()
          vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
            buffer = buffer,
            callback = vim.lsp.codelens.refresh,
          })
        end)
      end

      -- Configure diagnostics
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- Apply global server configuration
      if opts.servers['*'] then
        vim.lsp.config('*', opts.servers['*'])
      end

      -- Get mason-lspconfig servers
      local have_mason = pcall(require, 'mason-lspconfig')
      local mason_all = have_mason
          and vim.tbl_keys(require('mason-lspconfig.mappings').get_mason_map().lspconfig_to_package)
        or {}

      -- Build exclusion list: only enable servers explicitly configured in opts.servers
      -- This prevents mason from auto-enabling servers from disabled extras
      local configured_servers = vim.tbl_keys(opts.servers)
      local mason_exclude = {} ---@type string[]

      for _, server in ipairs(mason_all) do
        if not vim.tbl_contains(configured_servers, server) then
          -- Server is not configured, exclude it from automatic enabling
          mason_exclude[#mason_exclude + 1] = server
        end
      end

      -- Configure individual servers
      ---@param server string
      ---@return boolean? use_mason
      local function configure(server)
        if server == '*' then
          return false
        end

        local server_opts = opts.servers[server]
        -- Normalize options
        server_opts = server_opts == true and {} or (not server_opts) and { enabled = false } or server_opts

        if server_opts.enabled == false then
          -- Also add disabled servers to exclusion list
          if not vim.tbl_contains(mason_exclude, server) then
            mason_exclude[#mason_exclude + 1] = server
          end
          return
        end

        local use_mason = server_opts.mason ~= false and vim.tbl_contains(mason_all, server)
        local setup = opts.setup[server] or opts.setup['*']

        if setup and setup(server, server_opts) then
          -- Custom setup handled it, exclude from automatic enabling
          if not vim.tbl_contains(mason_exclude, server) then
            mason_exclude[#mason_exclude + 1] = server
          end
        else
          -- Standard setup
          vim.lsp.config(server, server_opts)
          if not use_mason then
            vim.lsp.enable(server)
          end
        end

        return use_mason
      end

      -- Configure all servers and collect mason-managed ones
      local mason_install = vim.tbl_filter(configure, vim.tbl_keys(opts.servers))

      -- Setup mason-lspconfig
      if have_mason then
        require('mason-lspconfig').setup({
          ensure_installed = vim.list_extend(mason_install, Editor.opts('mason-lspconfig.nvim').ensure_installed or {}),
          automatic_enable = { exclude = mason_exclude },
        })
      end

      -- Handle Deno/vtsls conflict
      if Editor.lsp.is_enabled('denols') and Editor.lsp.is_enabled('vtsls') then
        local is_deno = vim.fs.root(0, { 'deno.json', 'deno.jsonc' })
        Editor.lsp.disable('vtsls', is_deno)
        Editor.lsp.disable('denols', function(root_dir, config)
          if not vim.fs.root(root_dir, { 'deno.json', 'deno.jsonc' }) then
            config.settings.deno.enable = false
          end
          return false
        end)
      end
    end,
  },

  -- Mason Package Manager
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' } },
    build = ':MasonUpdate',
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
    config = function(_, opts)
      require('mason').setup(opts)
      local mr = require('mason-registry')

      -- Auto-reload LSP after package install
      mr:on('package:install:success', function()
        vim.defer_fn(function()
          require('lazy.core.handler.event').trigger({
            event = 'FileType',
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)

      -- Install packages
      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },
}
