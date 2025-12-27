return {
  recommended = {
    ft = { 'html' },
    root = { 'index.html' },
  },

  desc = 'HTML support',

  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'html' } },
  },
}
