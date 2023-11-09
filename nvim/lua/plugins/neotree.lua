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
          commands = {
            copy_selector = function(state)
              local node = state.tree:get_node()
              local filepath = node:get_id()
              local filename = node.name
              local modify = vim.fn.fnamemodify

              local vals = {
                ['BASENAME'] = modify(filename, ':r'),
                ['EXTENSION'] = modify(filename, ':e'),
                ['FILENAME'] = filename,
                ['PATH (CWD)'] = modify(filepath, ':.'),
                ['PATH (HOME)'] = modify(filepath, ':~'),
                ['PATH'] = filepath,
                ['URI'] = vim.uri_from_fname(filepath),
              }

              local options = vim.tbl_filter(function(val)
                return vals[val] ~= ''
              end, vim.tbl_keys(vals))
              if vim.tbl_isempty(options) then
                vim.notify('No values to copy', vim.log.levels.WARN)
                return
              end
              table.sort(options)
              vim.ui.select(options, {
                prompt = 'Choose to copy to clipboard:',
                format_item = function(item)
                  return ('%s: %s'):format(item, vals[item])
                end,
              }, function(choice)
                local result = vals[choice]
                if result then
                  vim.notify(('Copied: `%s`'):format(result))
                  vim.fn.setreg('+', result)
                end
              end)
            end,
          },
          window = {
            mappings = {
              ['/'] = 'noop',
              ['Y'] = 'copy_selector',
            },
          },
        },
      })
    end,
  },
}
