return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    lazy = false,
    cmd = 'Neotree',
    branch = 'v2.x',
    keys = {
      { '<leader>n', '<cmd>Neotree toggle<cr>', desc = 'NeoTree' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('neo-tree').setup({
        close_if_last_window = true,
        enable_git_status = true,
        default_component_configs = {
          git_status = {
            symbols = {
              -- Change type
              added = '✚', -- or "✚", but this is redundant info if you use git_status_colors on the name
              modified = '', -- or "", but this is redundant info if you use git_status_colors on the name
              deleted = '✖', -- this can only be used in the git_status source
              renamed = '', -- this can only be used in the git_status source
              -- Status type
              untracked = '',
              ignored = '',
              unstaged = '',
              staged = '',
              conflict = '',
            },
          },
        },
        window = {
          width = 30,
        },
        filesystem = {
          follow_current_file = true,
          hijack_netrw_behavior = 'open_current',
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_by_name = {
              '.DS_Store',
              'thumbs.db',
              'node_modules',
            },
          },
          window = {
            mappings = {
              ['/'] = 'noop',
            },
          },
        },
      })
    end,
  },
}
