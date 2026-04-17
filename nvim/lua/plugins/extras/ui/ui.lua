return {
  -- colorscheme - onenord
  {
    'rmehri01/onenord.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      local colors = require('onenord.colors').load()

      require('onenord').setup({
        custom_highlights = {
          NeoTreeIndentMarker = { fg = colors.selection },
        },
      })
    end,
  },

  -- dashboard
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    opts = function()
      local logo = [[
         ⡿⠉⠄⠄⠄⠄⠈⠙⠿⠟⠛⠉⠉⠉⠄⠄⠄⠈⠉⠉⠉⠛⠛⠻⢿⣿⣿⣿⣿⣿
         ⠁⠄⠄⠄⢀⡴⣋⣵⣮⠇⡀⠄⠄⠄⠄⠄⠄⢀⠄⠄⠄⡀⠄⠄⠄⠈⠛⠿⠋⠉
         ⠄⠄⠄⢠⣯⣾⣿⡿⣳⡟⣰⣿⣠⣂⡀⢀⠄⢸⡄⠄⢀⣈⢆⣱⣤⡀⢄⠄⠄⠄
         ⠄⠄⠄⣼⣿⣿⡟⣹⡿⣸⣿⢳⣿⣿⣿⣿⣴⣾⢻⣆⣿⣿⣯⢿⣿⣿⣷⣧⣀⣤
         ⠄⠄⣼⡟⣿⠏⢀⣿⣇⣿⣏⣿⣿⣿⣿⣿⣿⣿⢸⡇⣿⣿⣿⣟⣿⣿⣿⣿⣏⠋
         ⡆⣸⡟⣼⣯⠏⣾⣿⢸⣿⢸⣿⣿⣿⣿⣿⣿⡟⠸⠁⢹⡿⣿⣿⢻⣿⣿⣿⣿⠄
         ⡇⡟⣸⢟⣫⡅⣶⢆⡶⡆⣿⣿⣿⣿⣿⢿⣛⠃⠰⠆⠈⠁⠈⠙⠈⠻⣿⢹⡏⠄
         ⣧⣱⡷⣱⠿⠟⠛⠼⣇⠇⣿⣿⣿⣿⣿⣿⠃⣰⣿⣿⡆⠄⠄⠄⠄⠄⠉⠈⠄⠄
         ⡏⡟⢑⠃⡠⠂⠄⠄⠈⣾⢻⣿⣿⡿⡹⡳⠋⠉⠁⠉⠙⠄⢀⠄⠄⠄⠄⠄⠂⠄
         ⡇⠁⢈⢰⡇⠄⠄⡙⠂⣿⣿⣿⣿⣱⣿⡗⠄⠄⠄⢀⡀⠄⠈⢰⠄⠄⠄⠐⠄⠄
         ⠄⠄⠘⣿⣧⠴⣄⣡⢄⣿⣿⣿⣷⣿⣿⡇⢀⠄⠤⠈⠁⣠⣠⣸⢠⠄⠄⠄⠄⠄
         ⢀⠄⠄⣿⣿⣷⣬⣵⣿⣿⣿⣿⣿⣿⣿⣷⣟⢷⡶⢗⡰⣿⣿⠇⠘⠄⠄⠄⠄⠄
         ⣿⠄⠄⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣾⣿⣿⡟⢀⠃⠄⢸⡄⠁⣸
         ⣿⠄⠄⠘⢿⣿⣿⣿⣿⣿⣿⢛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⢄⡆⠄⢀⣪⡆⠄⣿
         ⡟⠄⠄⠄⠄⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢿⣟⣻⣩⣾⣃⣴⣿⣿⡇⠸⢾
      ]]

      logo = string.rep('\n', 8) .. logo .. '\n\n'

      local opts = {
        theme = 'doom',
        hide = {
          -- this is taken care of by lualine
          -- enabling this messes up the actual laststatus setting after loading a file
          statusline = false,
        },
        config = {
          header = vim.split(logo, '\n'),
          -- stylua: ignore
          center = {
            { action = "Telescope find_files", desc = " Find file", icon = " ", key = "f" },
            { action = "ene | startinsert", desc = " New file", icon = " ", key = "n" },
            { action = "Telescope oldfiles", desc = " Recent files", icon = " ", key = "r" },
            { action = "Telescope live_grep", desc = " Find text", icon = " ", key = "g" },
            { action = [[lua require("lazyvim.util").telescope.config_files()()]], desc = " Config", icon = " ", key = "c" },
            { action = 'lua require("persistence").load()', desc = " Restore Session", icon = " ", key = "s" },
            { action = "EditorExtras", desc = " Editor Extras", icon = " ", key = "x" },
            { action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l" },
            { action = "qa", desc = " Quit", icon = " ", key = "q" },
          },
          footer = function()
            local stats = require('lazy').stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return { '⚡ Neovim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms' }
          end,
        },
      }

      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(' ', 43 - #button.desc)
        button.key_format = '  %s'
      end

      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == 'lazy' then
        vim.cmd.close()
        vim.api.nvim_create_autocmd('User', {
          pattern = 'DashboardLoaded',
          callback = function()
            require('lazy').show()
          end,
        })
      end

      return opts
    end,
  },

  -- bufferline
  {
    'akinsho/bufferline.nvim',
    event = 'VeryLazy',
    keys = {
      { '<leader>bp', '<Cmd>BufferLineTogglePin<CR>', desc = 'Toggle pin' },
      { '<leader>bP', '<Cmd>BufferLineGroupClose ungrouped<CR>', desc = 'Delete non-pinned buffers' },
      { '<leader>bo', '<Cmd>BufferLineCloseOthers<CR>', desc = 'Delete other buffers' },
      { '<leader>br', '<Cmd>BufferLineCloseRight<CR>', desc = 'Delete buffers to the right' },
      { '<leader>bl', '<Cmd>BufferLineCloseLeft<CR>', desc = 'Delete buffers to the left' },
      { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev buffer' },
      { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next buffer' },
      { '[b', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev buffer' },
      { ']b', '<cmd>BufferLineCycleNext<cr>', desc = 'Next buffer' },
    },
    opts = {
      options = {
        diagnostics = 'nvim_lsp',
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diag)
          local icons = require('config').icons.diagnostics
          local ret = (diag.error and icons.Error .. diag.error .. ' ' or '')
            .. (diag.warning and icons.Warn .. diag.warning or '')
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = 'neo-tree',
            text = 'Neo-tree',
            highlight = 'Directory',
            text_align = 'left',
          },
        },
      },
    },
  },

  -- workflow scope
  {
    'tiagovla/scope.nvim',
    event = 'VeryLazy',
    config = function()
      require('scope').setup({ restore_state = false })
    end,
  },

  -- transparent background
  {
    'xiyaowong/transparent.nvim',
    config = function()
      require('transparent').setup({
        exclude_groups = {
          'StatusLine',
          'StatusLineNC',
        },
      })
    end,
  },

  -- colorizer
  {
    'catgoose/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end,
  },

  -- icons
  {
    'nvim-web-devicons',
    config = function()
      require('nvim-web-devicons').setup({
        override = {
          ['blade.php'] = {
            icon = '',
          },
        },
      })
    end,
  },

  -- colorscheme - nord
  -- {
  --   'ten3roberts/nord.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     -- config in lua
  --     -- https://github.com/shaunsingh/nord.nvim#%EF%B8%8F-configuration
  --     vim.g.nord_contrast = true
  --     vim.g.nord_borders = true
  --     vim.g.nord_uniform_diff_background = true

  --     -- Load the colorscheme
  --     require('nord').set()
  --   end,
  -- },
  -- {
  --   "fcancelinha/nordern.nvim",
  --   branch = "master",
  --   priority = 1000,
  --   config = function()
  --     vim.cmd.colorscheme('nordern')
  --   end,
  -- },

  -- colorscheme - nord
  -- {
  --   'gbprod/nord.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require('nord').setup({})
  --     vim.cmd.colorscheme('nord')
  --   end,
  -- },

  -- colorscheme - catppuccin
  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   priority = 1000,
  --   config = function()
  --     require("catppuccin").setup({
  --       flavour = "latte", -- latte, frappe, macchiato, mocha
  --       background = {     -- :h background
  --         light = "latte",
  --         dark = "frappe",
  --       },
  --     })

  --     vim.cmd.colorscheme("catppuccin")
  --   end,
  -- },

  -- colorscheme - dracula
  -- {
  --   "Mofiqul/dracula.nvim",
  --   name = "dracula",
  --   priority = 1000,
  --   config = function()
  --     vim.cmd.colorscheme("dracula")
  --   end,
  -- },

  -- colorscheme - nightfox
  -- {
  --   'EdenEast/nightfox.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.cmd('colorscheme nordfox')
  --   end,
  -- },
}
