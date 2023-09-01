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
        expr = true, silent = true, mode = 'i',
      },
      { '<tab>',   function() require('luasnip').jump(1) end,   mode = 's' },
      { '<s-tab>', function() require('luasnip').jump( -1) end, mode = { 'i', 's' } },
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
    },
    opts = function()
      local cmp = require('cmp')
      local lspkind = require('lspkind')

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
          ghost_text = {
            hl_group = 'LspCodeLens',
          },
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
      vim.g.doge_mapping = '<Leader>d'
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
  {
    'github/copilot.vim',
    keys = {
      { '<leader>cg', '<cmd>Copilot<cr>', desc = 'Copilot' },
    },
  },

  -- splitjoin
  {
    'AndrewRadev/splitjoin.vim',
  },
  {
    'bennypowers/splitjoin.nvim',
    lazy = true,
    keys = {
      {
        'gj',
        function()
          require('splitjoin').join()
        end,
        desc = 'Join the object under cursor',
      },
      {
        'g,',
        function()
          require('splitjoin').split()
        end,
        desc = 'Split the object under cursor',
      },
    },
  },

  -- change text case
  {
    'johmsalas/text-case.nvim',
    config = function()
      require('textcase').setup({})
    end,
  },
}
