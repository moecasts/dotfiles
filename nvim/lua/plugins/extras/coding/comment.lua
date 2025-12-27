return {
  -- change ts comment case
  {
    'moecasts/nvim-ts-comment-case',
    event = 'VeryLazy',
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

  -- 增强 Neovim 原生注释功能，支持 treesitter 上下文
  {
    'folke/ts-comments.nvim',
    event = 'VeryLazy',
    opts = {},
    enabled = vim.fn.has('nvim-0.10.0') == 1,
  },

  {
    'kkoomen/vim-doge',
    event = 'VeryLazy',
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
    event = 'VeryLazy',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = true,
  },
}
