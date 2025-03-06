return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    lazy = false,
    cmd = 'Neotree',
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
              renamed = '󰁕', -- this can only be used in the git_status source
              -- Status type
              untracked = '',
              ignored = '',
              unstaged = '󰄱',
              staged = '',
              conflict = '',
            },
          },
        },
        window = {
          width = 30,
        },
        filesystem = {
          follow_current_file = {
            enabled = true,
          },
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

            find_in_directory_telescope = function(state)
              local node = state.tree:get_node()
              local filepath = node:get_id()
              local modify = vim.fn.fnamemodify
              local dirpath = modify(filepath, ':.')

              -- check if the dirpath is a directory
              if vim.fn.isdirectory(dirpath) == 0 then
                print('Error: ' .. dirpath .. ' is not a directory.')
                return
              end

              require('telescope.builtin').live_grep({
                prompt_title = 'Live Grep',
                cwd = dirpath,
              })
            end,

            find_in_directory_spectre = function(state)
              local node = state.tree:get_node()
              local filepath = node:get_id()
              local modify = vim.fn.fnamemodify
              local dirpath = modify(filepath, ':.')

              -- check if the dirpath is a directory
              if vim.fn.isdirectory(dirpath) == 0 then
                print('Error: ' .. dirpath .. ' is not a directory.')
                return
              end

              local path = ('%s/**/*'):format(dirpath)

              require('spectre').open({
                search_text = '',
                replace_text = '',
                path = path,
              })
            end,

            find_in_directory_grug_far = function(state)
              local node = state.tree:get_node()
              local filepath = node:get_id()
              local modify = vim.fn.fnamemodify
              local dirpath = modify(filepath, ':.')

              -- check if the dirpath is a directory
              if vim.fn.isdirectory(dirpath) == 0 then
                print('Error: ' .. dirpath .. ' is not a directory.')
                return
              end

              local prefills = {
                paths = dirpath,
              }

              local grug_far = require('grug-far')
              -- instance check
              if not grug_far.has_instance('explorer') then
                grug_far.open({
                  instanceName = 'explorer',
                  prefills = prefills,
                  staticTitle = 'Find and Replace from Explorer',
                })
              else
                grug_far.open_instance('explorer')
                -- updating the prefills without clearing the search and other fields
                grug_far.update_instance_prefills('explorer', prefills, false)
              end
            end,

            avante_add_files = function(state)
              local node = state.tree:get_node()
              local filepath = node:get_id()
              local relative_path = require('avante.utils').relative_path(filepath)

              local sidebar = require('avante').get()

              local open = sidebar:is_open()
              -- ensure avante sidebar is open
              if not open then
                require('avante.api').ask()
                sidebar = require('avante').get()
              end

              sidebar.file_selector:add_selected_file(relative_path)

              -- remove neo tree buffer
              if not open then
                sidebar.file_selector:remove_selected_file('neo-tree filesystem [1]')
              end
            end,
          },
          window = {
            mappings = {
              ['/'] = 'noop',
              ['Y'] = 'copy_selector',
              ['F'] = 'find_in_directory_grug_far',
              ['T'] = 'find_in_directory_telescope',
              ['oa'] = 'avante_add_files',
            },
          },
        },
      })
    end,
  },
}
