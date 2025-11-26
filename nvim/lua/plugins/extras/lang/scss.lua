return {
  recommended = {
    ft = { 'scss', 'sass' },
  },

  desc = 'SCSS/Sass support with LSP',

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
