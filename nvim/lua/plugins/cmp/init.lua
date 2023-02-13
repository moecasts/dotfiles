return {
  "hrsh7th/nvim-cmp",
  -- load cmp on InsertEnter
  event = "InsertEnter",
  -- these dependencies will only be loaded when cmp loads
  -- dependencies are always lazy-loaded unless specified otherwise
  dependencies = {
    'neovim/nvim-lspconfig',
    -- nvim-cmp
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/nvim-cmp',
    -- vsnip
    'hrsh7th/vim-vsnip',
    { 'hrsh7th/cmp-vsnip', after = 'hrsh7th/vim-vsnip' },
    'rafamadriz/friendly-snippets',
    -- lspkind
    'onsails/lspkind-nvim',
  },
  config = function()
    local cmp = require("cmp")
    local lspkind = require("lspkind")
    local t = function (str)
        return vim.api.nvim_replace_termcodes(str, true, true, true)
    end

    cmp.setup({
      -- 设置代码片段引擎，用于根据代码片段补全
      snippet = {
          expand = function(args)
              vim.fn["vsnip#anymous"](args.body)
          end,
      },
  
      window = {
      },
  
      mapping = cmp.mapping.preset.insert({
        -- snippet movement with vsnips
        -- ['<C-j>'] = cmp.mapping(function (fallback)
        --     if vim.fn['vsnip#jumpable'](1) == 1 then
        --         feedkeys.call(t"<Plug>(vsnip-jump-next)", "")
        --     else
        --         fallback()
        --     end
        -- end, { 'i', 's', 'c' }),
        -- ['<C-h>'] = cmp.mapping(function (fallback)
        --     if vim.fn['vsnip#jumpable'](-1) == 1 then
        --         feedkeys.call(t"<Plug>(vsnip-jump-prev)", "")
        --     else
        --         fallback()
        --     end
        -- end, { 'i', 's', 'c' }),
        -- ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        -- ['<C-f>'] = cmp.mapping.scroll_docs(4),
        -- ['<C-Space>'] = cmp.mapping.complete(),
        -- ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      }),
  
      -- 补全来源
      sources = cmp.config.sources({
          {name = 'path'},
          {name = 'buffer'},
          {name = 'nvim_lsp'},
          {name = 'vsnip'},
      }),
  
      --根据文件类型来选择补全来源
      cmp.setup.filetype('gitcommit', {
          sources = cmp.config.sources({
              {name = 'buffer'}
          })
      }),
  
      -- 命令模式下输入 `/` 启用补全
      cmp.setup.cmdline('/', {
          mapping = cmp.mapping.preset.cmdline(),
          sources = {
              { name = 'buffer' }
          }
      }),
  
      -- 命令模式下输入 `:` 启用补全
      cmp.setup.cmdline(':', {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({
              { name = 'path' }
          }, {
                  { name = 'cmdline' }
              })
      }),
  
      -- 设置补全显示的格式
      formatting = {
          format = lspkind.cmp_format({
              with_text = true,
              maxwidth = 50,
              before = function(entry, vim_item)
                  vim_item.menu = "[" .. string.upper(entry.source.name) .. "]"
                  return vim_item
              end
          }),
      },
    })
    require'lspconfig'.tsserver.setup {}

    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
    require('lspconfig').tsserver.setup {
        capabilities = capabilities
    }
  end,
}
