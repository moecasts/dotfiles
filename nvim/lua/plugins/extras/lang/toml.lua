return {
  recommended = {
    ft = { 'toml' },
    root = { 'Cargo.toml', 'pyproject.toml' },
  },

  desc = 'TOML support',

  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'toml' } },
  },
}
