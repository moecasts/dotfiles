return {
  recommended = {
    ft = { 'xml' },
  },

  desc = 'XML support',

  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'xml' } },
  },
}
