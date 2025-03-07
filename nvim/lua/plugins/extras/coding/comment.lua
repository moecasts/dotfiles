return {
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

  -- ts context commentstring
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    config = function()
      require('ts_context_commentstring').setup({
        enable_autocmd = true,
      })
    end,
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
}
