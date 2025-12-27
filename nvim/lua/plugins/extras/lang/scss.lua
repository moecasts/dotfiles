return {
  recommended = {
    ft = { 'scss', 'sass' },
  },

  desc = 'SCSS/Sass support with LSP',

  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'scss', 'css' } },
  },

  {
    -- correctly setup lspconfig
    {
      'neovim/nvim-lspconfig',
      opts = {
        -- make sure mason installs the server
        servers = {
          somesass_ls = {},
        },
      },
    },
  },
}
