return {
  {
    'kawre/leetcode.nvim',
    event = 'VeryLazy',
    build = ':TSUpdate html',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim', -- required by telescope
      'MunifTanjim/nui.nvim',

      -- optional
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      ---@type lc.lang
      lang = 'typescript',

      -- configuration goes here
      plugins = {
        non_standalone = true,
      },
    },
  },
}
