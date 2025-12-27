return {
  recommended = {
    ft = { 'yaml' },
    root = { '.github', 'docker-compose.yml', 'docker-compose.yaml' },
  },

  desc = 'YAML support',

  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'yaml' } },
  },
}
