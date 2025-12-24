local util = require('util')

return {
  {
    'nvim-treesitter/nvim-treesitter',
    version = false, -- last release is way too old and doesn't work on Windows
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    keys = {
      { '<c-space>', desc = 'Increment selection' },
      { '<bs>', desc = 'Schrink selection', mode = 'x' },
    },
    ---@type TSConfig
    opts = {
      highlight = {
        enable = true,
        -- disable slow treesitter highlight for large files
        disable = function(lang, buf)
          local max_filesize = 10 * 1024 -- 10 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      ensure_installed = {
        'bash',
        'vimdoc',
        'html',
        'javascript',
        'json',
        'lua',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'regex',
        'tsx',
        'typescript',
        'vim',
        'yaml',
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-space>',
          node_incremental = '<C-space>',
          scope_incremental = '<nop>',
          node_decremental = '<bs>',
        },
      },
    },
    ---@param opns TSConfig
    config = function(_, opts)
      require('nvim-treesitter').setup(opts)

      vim.keymap.set(
        'n',
        '<leader>tsh',
        '<CMD>TSBufToggle highlight<CR>',
        { buffer = buffer, desc = 'Treesitter toggle highlight' }
      )

      vim.keymap.set(
        'n',
        '<leader>tsa',
        util.toggle_treesitter_modules,
        { buffer = buffer, desc = 'Treesitter toggle all' }
      )
    end,
  },

  {
    'kevinhwang91/nvim-ufo',
    event = 'VeryLazy',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'kevinhwang91/promise-async',
    },
    config = function()
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      require('ufo').setup({
        provider_selector = function(bufnr, filetype, buftype)
          return { 'treesitter', 'indent' }
        end,
      })
      vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
      vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds)
      vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)
      vim.keymap.set('n', 'K', function()
        local winid = require('ufo').peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end)
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    init = function()
      -- Disable entire built-in ftplugin mappings to avoid conflicts.
      -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
      vim.g.no_plugin_maps = true

      -- Or, disable per filetype (add as you like)
      -- vim.g.no_python_maps = true
      -- vim.g.no_ruby_maps = true
      -- vim.g.no_rust_maps = true
      -- vim.g.no_go_maps = true
    end,
    config = function()
      require('nvim-treesitter-textobjects').setup({
        select = {
          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,

          -- You can choose the select mode (default is charwise 'v')
          selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'V', -- linewise
            ['@class.outer'] = '<c-v>', -- blockwise
          },

          -- If you set this to `true` (default is `false`) then any textobject is
          -- extended to include preceding or succeeding whitespace. Succeeding
          -- whitespace has priority in order to act similarly to eg the built-in
          -- `ap`.
          include_surrounding_whitespace = true,
        },

        swap = {
          set_jumps = true, -- whether to set jumps in the jumplist
        },

        move = {
          -- whether to set jumps in the jumplist
          set_jumps = true,
        },
      })

      -- Text objects: select
      vim.keymap.set({ 'x', 'o' }, 'af', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
      end, { desc = 'Select outer function' })

      vim.keymap.set({ 'x', 'o' }, 'if', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
      end, { desc = 'Select inner function' })

      vim.keymap.set({ 'x', 'o' }, 'ac', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@class.outer', 'textobjects')
      end, { desc = 'Select outer class' })

      vim.keymap.set({ 'x', 'o' }, 'ic', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@class.inner', 'textobjects')
      end, { desc = 'Select inner class' })

      vim.keymap.set({ 'x', 'o' }, 'as', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@local.scope', 'locals')
      end, { desc = 'Select language scope' })

      -- Text objects: swap
      vim.keymap.set('n', '<leader>a', function()
        require('nvim-treesitter-textobjects.swap').swap_next('@parameter.inner')
      end, { desc = 'Swap parameter with next' })

      vim.keymap.set('n', '<leader>A', function()
        require('nvim-treesitter-textobjects.swap').swap_previous('@parameter.inner')
      end, { desc = 'Swap parameter with previous' })

      -- Text objects: move
      vim.keymap.set({ 'n', 'x', 'o' }, ']f', function()
        require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')
      end, { desc = 'Next function start' })

      vim.keymap.set({ 'n', 'x', 'o' }, ']F', function()
        require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer', 'textobjects')
      end, { desc = 'Next function end' })

      vim.keymap.set({ 'n', 'x', 'o' }, '[f', function()
        require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects')
      end, { desc = 'Previous function start' })

      vim.keymap.set({ 'n', 'x', 'o' }, '[F', function()
        require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer', 'textobjects')
      end, { desc = 'Previous function end' })

      vim.keymap.set({ 'n', 'x', 'o' }, ']c', function()
        require('nvim-treesitter-textobjects.move').goto_next_start('@class.outer', 'textobjects')
      end, { desc = 'Next class start' })

      vim.keymap.set({ 'n', 'x', 'o' }, '[c', function()
        require('nvim-treesitter-textobjects.move').goto_previous_start('@class.outer', 'textobjects')
      end, { desc = 'Previous class start' })

      -- LSP interop: peek definition
      vim.keymap.set('n', '<leader>df', function()
        require('nvim-treesitter-textobjects.lsp_interop').peek_definition_code('@function.outer', 'textobjects')
      end, { desc = 'Peek function definition' })

      vim.keymap.set('n', '<leader>dF', function()
        require('nvim-treesitter-textobjects.lsp_interop').peek_definition_code('@class.outer', 'textobjects')
      end, { desc = 'Peek class definition' })

      -- Make movements repeatable with ; and ,
      local ts_repeat_move = require('nvim-treesitter-textobjects.repeatable_move')
      vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move_next)
      vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_previous)

      -- Make builtin f, F, t, T also repeatable with ; and ,
      vim.keymap.set({ 'n', 'x', 'o' }, 'f', ts_repeat_move.builtin_f_expr, { expr = true })
      vim.keymap.set({ 'n', 'x', 'o' }, 'F', ts_repeat_move.builtin_F_expr, { expr = true })
      vim.keymap.set({ 'n', 'x', 'o' }, 't', ts_repeat_move.builtin_t_expr, { expr = true })
      vim.keymap.set({ 'n', 'x', 'o' }, 'T', ts_repeat_move.builtin_T_expr, { expr = true })
    end,
  },
}
