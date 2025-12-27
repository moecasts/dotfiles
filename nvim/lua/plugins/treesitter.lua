return {
  -- nvim-treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    version = false,
    build = ':TSUpdate',
    lazy = false,
    opts_extend = { 'ensure_installed' },
    opts = {
      indent = { enable = true },
      highlight = { enable = true },
      ensure_installed = {
        'bash',
        'c',
        'diff',
        'lua',
        'luadoc',
        'luap',
        'printf',
        'query',
        'regex',
        'vim',
        'vimdoc',
      },
    },
    config = function(_, opts)
      local TS = require('nvim-treesitter')
      TS.setup(opts)
      Editor.treesitter.get_installed(true)

      -- 安装缺失的解析器
      local to_install = vim.tbl_filter(function(lang)
        return not Editor.treesitter.have(lang)
      end, opts.ensure_installed or {})
      if #to_install > 0 then
        TS.install(to_install)
      end

      -- FileType autocmd
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('editor_treesitter', { clear = true }),
        callback = function(ev)
          local buf = ev.buf

          -- 跳过大文件
          if Editor.treesitter.is_large_file(buf) then
            return
          end

          if not Editor.treesitter.have(ev.match) then
            return
          end

          local function enabled(feat, query)
            local f = opts[feat] or {}
            return f.enable ~= false and Editor.treesitter.have(ev.match, query)
          end

          -- 高亮
          if enabled('highlight', 'highlights') then
            pcall(vim.treesitter.start, buf)
          end

          -- 缩进
          if enabled('indent', 'indents') then
            vim.bo[buf].indentexpr = 'v:lua.Editor.treesitter.indentexpr()'
          end
        end,
      })
    end,
  },

  -- nvim-ufo
  {
    'kevinhwang91/nvim-ufo',
    event = 'VeryLazy',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'kevinhwang91/promise-async',
    },
    config = function()
      vim.o.foldlevel = 99
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
      vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith)
      vim.keymap.set('n', 'K', function()
        local winid = require('ufo').peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end)
    end,
  },

  -- nvim-treesitter-textobjects
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = 'VeryLazy',
    opts = {
      move = {
        enable = true,
        set_jumps = true,
        keys = {
          goto_next_start = { [']f'] = '@function.outer', [']c'] = '@class.outer', [']a'] = '@parameter.inner' },
          goto_next_end = { [']F'] = '@function.outer', [']C'] = '@class.outer', [']A'] = '@parameter.inner' },
          goto_previous_start = { ['[f'] = '@function.outer', ['[c'] = '@class.outer', ['[a'] = '@parameter.inner' },
          goto_previous_end = { ['[F'] = '@function.outer', ['[C'] = '@class.outer', ['[A'] = '@parameter.inner' },
        },
      },
    },
    config = function(_, opts)
      require('nvim-treesitter-textobjects').setup(opts)

      local function attach(buf)
        local ft = vim.bo[buf].filetype
        if not (opts.move and opts.move.enable and Editor.treesitter.have(ft, 'textobjects')) then
          return
        end

        for method, keymaps in pairs(opts.move.keys or {}) do
          for key, query in pairs(keymaps) do
            local desc = (key:sub(1, 1) == '[' and 'Prev ' or 'Next ')
              .. query:gsub('@', ''):gsub('%..*', '')
              .. (key:sub(2, 2) == key:sub(2, 2):upper() and ' end' or ' start')

            if not (vim.wo.diff and key:find('[cC]')) then
              vim.keymap.set({ 'n', 'x', 'o' }, key, function()
                require('nvim-treesitter-textobjects.move')[method](query, 'textobjects')
              end, { buffer = buf, desc = desc, silent = true })
            end
          end
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('editor_treesitter_textobjects', { clear = true }),
        callback = function(ev)
          attach(ev.buf)
        end,
      })
      vim.tbl_map(attach, vim.api.nvim_list_bufs())
    end,
  },
}
