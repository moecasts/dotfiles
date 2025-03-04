return {
  -- snippets
  {
    'L3MON4D3/LuaSnip',
    dependencies = {
      'rafamadriz/friendly-snippets',
      config = function()
        require('luasnip.loaders.from_vscode').lazy_load()
        require('luasnip.loaders.from_vscode').lazy_load({ paths = { vim.fn.stdpath('config') .. '/snippets' } })
        require('luasnip').filetype_extend('typescript', { 'javascript' })
        require('luasnip').filetype_extend('typescriptreact', { 'javascriptreact' })
      end,
    },
    opts = {
      history = true,
      delete_check_events = 'TextChanged',
    },
    -- stylua: ignore
    keys = {
      {
        '<tab>',
        function()
          return require('luasnip').jumpable(1) and '<Plug>luasnip-jump-next' or '<tab>'
        end,
        expr = true,
        silent = true,
        mode = 'i',
      },
      { '<tab>',   function() require('luasnip').jump(1) end,   mode = 's' },
      { '<s-tab>', function() require('luasnip').jump(-1) end,  mode = { 'i', 's' } },
    },
  },

  -- auto completion
  {
    'hrsh7th/nvim-cmp',
    version = false, -- last release is way too old
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'saadparwaiz1/cmp_luasnip',
      -- lspkind
      'onsails/lspkind-nvim',

      -- copilot
      {
        'zbirenbaum/copilot-cmp',
        dependencies = 'copilot.lua',
        opts = {},
        config = function(_, opts)
          local copilot_cmp = require('copilot_cmp')
          copilot_cmp.setup(opts)
          -- attach cmp source whenever copilot attaches
          -- fixes lazy-loading issues with the copilot cmp source
          require('util').lsp.on_attach(function(client)
            if client.name == 'copilot' then
              copilot_cmp._on_insert_enter({})
            end
          end)
        end,
      },
    },
    opts = function()
      local cmp = require('cmp')
      local lspkind = require('lspkind')

      lspkind.init({
        symbol_map = {
          Copilot = '',
        },
      })

      vim.api.nvim_set_hl(0, 'CmpItemKindCopilot', require('util').ui.fg('Character'))

      return {
        completion = {
          completeopt = 'menu,menuone,noinsert',
        },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
          {
            name = 'copilot',
            group_index = 1,
            priority = 100,
          },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
        formatting = {
          fields = { 'menu', 'abbr', 'kind' },
          format = lspkind.cmp_format({
            with_text = true,
            maxwidth = 50,
            menu = {
              nvim_lsp = 'Lsp',
              luasnip = 'Snip',
              buffer = 'Buf',
              path = 'Path',
            },
            before = function(entry, vim_item)
              vim_item.menu = '[' .. string.upper(entry.source.name) .. ']'
              return vim_item
            end,
          }),
        },
        experimental = {
          ghost_text = false,
          -- ghost_text = {
          --   hl_group = 'LspCodeLens',
          -- },
        },
      }
    end,
  },

  -- auto pairs
  {
    'echasnovski/mini.pairs',
    event = 'VeryLazy',
    config = function(_, opts)
      require('mini.pairs').setup(opts)
    end,
  },

  -- surround
  {
    'echasnovski/mini.surround',
    config = function()
      -- use gz mappings instead of s to prevent conflict with leap
      require('mini.surround').setup({})
    end,
  },

  -- comments
  { 'JoosepAlviste/nvim-ts-context-commentstring', lazy = true },
  {
    'echasnovski/mini.comment',
    event = 'VeryLazy',
    opts = {
      options = {
        custom_commentstring = function()
          return require('ts_context_commentstring.internal').calculate_commentstring() or vim.bo.commentstring
        end,
      },
    },
  },

  {
    'kkoomen/vim-doge',
    build = function(plugin)
      if vim.fn.system('arch') == 'arm64' then
        os.execute('cd ' .. plugin.dir .. '&& npm i --no-save && npm run build:binary:unix')
      else
        vim.cmd(':call doge#install()')
      end
    end,
    config = function()
      vim.g.doge_enable_mappings = 0
      vim.g.doge_mapping = '<Leader>cg'
    end,
  },
  {
    'danymat/neogen',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = true,
  },

  -- better text-objects
  {
    'echasnovski/mini.ai',
    -- keys = {
    --   { "a", mode = { "x", "o" } },
    --   { "i", mode = { "x", "o" } },
    -- },
    event = 'VeryLazy',
  },

  -- better cursors
  {
    'mg979/vim-visual-multi',
  },

  -- copilot
  -- {
  --   'github/copilot.vim',
  --   keys = {
  --     { '<leader>cg', '<cmd>Copilot<cr>', desc = 'Copilot' },
  --   },
  -- },
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup({
        suggestion = {
          auto_trigger = true,
        },
      })
    end,
  },

  -- Cursor like ai plugin
  {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      provider = 'openai',
      auto_suggestions_provider = 'openai', -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
      openai = {
        -- endpoint = 'https://api.deepseek.com/v1',
        endpoint = 'https://api.lkeap.cloud.tencent.com/v1',
        model = 'deepseek-v3',
        -- model = 'deepseek-chat',
        -- model = 'deepseek-reasoner',
        timeout = 30000, -- Timeout in milliseconds
        temperature = 0,
        max_tokens = 4096,
        -- optional
        api_key_name = 'DEEPSEEK_API_KEY', -- default OPENAI_API_KEY if not set
        disable_tools = true,
      },
      file_selector = {
        provider = 'telescope',
        provider_opts = {
          provider_opts = {
            find_command = { 'rg', '--files', '--hidden', '-g', '!.git' },
          },
          -- file_ignore_patterns = {
          --   '^.git/',
          --   '^node_modules/',
          --   '^.DS_Store$',
          --   '^.idea/',
          --   '^.vscode/',
          --   '^build/',
          --   '^dist/',
          --   '^out/',
          --   '^target/',
          --   '^tmp/',
          --   '^vendor/',
          -- },
        },
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = 'make BUILD_FROM_SOURCE=true',
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      --- The below dependencies are optional,
      'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
      'zbirenbaum/copilot.lua', -- for providers='copilot'
      {
        -- support for image pasting
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
  },

  -- splitjoin
  {
    'Wansmer/treesj',
    keys = { 'gJ', 'gS' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' }, -- if you install parsers with `nvim-treesitter`
    config = function()
      require('treesj').setup({
        use_default_keymaps = false,
      })

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, {
          buffer = buffer,
          desc = desc,
        })
      end

      map('n', 'gJ', require('treesj').join, 'Join the object')
      map('n', 'gS', require('treesj').split, 'Split the object')
    end,
  },

  -- change text case
  {
    'johmsalas/text-case.nvim',
    config = function()
      require('textcase').setup({})
    end,
  },

  -- diffview
  { 'sindrets/diffview.nvim' },

  -- ts context commentstring
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    config = function()
      require('ts_context_commentstring').setup({
        enable_autocmd = true,
      })
    end,
  },

  -- change ts comment case
  {
    'moecasts/nvim-ts-comment-case',
    -- dir = '~/Developments/self/nvim/nvim-ts-comment-case',
    build = function(plugin)
      os.execute(string.format('cd %s && npm i --no-save', plugin.dir))
    end,
    config = function(plugin)
      require('ts_comment_case').setup({
        plugin_dir = plugin.dir,
      })
    end,
  },

  -- search/replace in multiple files
  {
    'MagicDuck/grug-far.nvim',
    opts = { headerMaxWidth = 80 },
    cmd = 'GrugFar',
    keys = {
      {
        '<leader>sr',
        function()
          local grug = require('grug-far')
          local ext = vim.bo.buftype == '' and vim.fn.expand('%:e')
          grug.open({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
            },
          })
        end,
        mode = { 'n', 'v' },
        desc = 'Search and Replace',
      },
    },
  },

  -- navigate lsp links
  {
    'icholy/lsplinks.nvim',
    config = function()
      local lsplinks = require('lsplinks')
      lsplinks.setup()
      vim.keymap.set('n', 'gx', lsplinks.gx)
    end,
  },
}
