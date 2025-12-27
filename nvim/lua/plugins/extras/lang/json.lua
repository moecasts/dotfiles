return {
  recommended = {
    ft = { 'json', 'jsonc' },
    root = { 'package.json', 'tsconfig.json', '.prettierrc.json' },
  },

  desc = 'JSON support',

  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'json', 'jsonc' } },
  },
}
