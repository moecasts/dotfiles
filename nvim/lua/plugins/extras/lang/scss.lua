return {
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
