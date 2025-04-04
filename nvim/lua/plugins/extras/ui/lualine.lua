return {
  -- lualine
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'zbirenbaum/copilot.lua',
    },
    event = 'VeryLazy',
    config = function()
      local icons = require('config').icons

      local util = require('util')

      local function fg(name)
        return function()
          ---@type {foreground?:number}?
          local hl = vim.api.nvim_get_hl_by_name(name, true)
          return hl and hl.foreground and { fg = string.format('#%06x', hl.foreground) }
        end
      end

      require('lualine').setup({
        options = {
          theme = 'auto',
          globalstatus = true,
          disabled_filetypes = { statusline = { 'dashboard', 'lazy', 'alpha' } },
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch' },
          lualine_c = {
            {
              'diagnostics',
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
            },
            {
              'filename',
              path = 1,
              symbols = {
                modified = '  ',
                readonly = '',
                unnamed = '',
              },
            },
            {
              'filetype',
              icon_only = true,
              separator = '',
              padding = { left = 1, right = 0 },
            },
            {
              function()
                return require('nvim-navic').get_location()
              end,
              cond = function()
                return package.loaded['nvim-navic'] and require('nvim-navic').is_available()
              end,
            },
          },
          lualine_x = {
            {
              function()
                return require('noice').api.status.command.get()
              end,
              cond = function()
                return package.loaded['noice'] and require('noice').api.status.command.has()
              end,
              color = fg('Statement'),
            },
            {
              function()
                return require('noice').api.status.mode.get()
              end,
              cond = function()
                return package.loaded['noice'] and require('noice').api.status.mode.has()
              end,
              color = fg('Constant'),
            },
            { require('lazy.status').updates, cond = require('lazy.status').has_updates, color = fg('Special') },
            {
              'diff',
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
            },
            {
              function()
                local icon = require('config').icons.kinds.Copilot
                local status = require('copilot.api').status.data
                return icon .. (status.message or '')
              end,
              cond = function()
                if not package.loaded['copilot'] then
                  return
                end
                local ok, clients = pcall(require('util').lsp.get_clients, { name = 'copilot', bufnr = 0 })
                if not ok then
                  return false
                end
                return ok and #clients > 0
              end,
              color = function()
                local colors = {
                  [''] = util.ui.fg('Character'),
                  ['Normal'] = util.ui.fg('Character'),
                  ['Warning'] = util.ui.fg('DiagnosticError'),
                  ['InProgress'] = util.ui.fg('DiagnosticWarn'),
                }
                if not package.loaded['copilot'] then
                  return
                end
                local status = require('copilot.api').status.data
                return colors[status.status] or colors['']
              end,
            },
            Snacks.profiler.status(),
          },
          lualine_y = {
            { 'progress', separator = ' ', padding = { left = 1, right = 0 } },
            { 'location', padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            function()
              return ' ' .. os.date('%R')
            end,
          },
        },
        extensions = { 'neo-tree' },
      })
    end,
  },

  -- lsp symbol navigation for lualine
  {
    'SmiteshP/nvim-navic',
    lazy = true,
    init = function()
      vim.g.navic_silence = true
      require('util').on_attach(function(client, buffer)
        if client.server_capabilities.documentSymbolProvider then
          require('nvim-navic').attach(client, buffer)
        end
      end)
    end,
    opts = function()
      return {
        separator = ' > ',
        -- highlight = true,
        depth_limit = 5,
        icons = require('config').icons.kinds,
      }
    end,
  },
}
