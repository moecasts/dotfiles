return {
  -- splitjoin
  {
    'Wansmer/treesj',
    keys = { 'gJ', 'gS' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' }, -- if you install parsers with `nvim-treesitter`
    config = function()
      require('treesj').setup({
        use_default_keymaps = false,
      })

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, {
          buffer = buffer,
          desc = desc,
        })
      end

      map('n', 'gJ', require('treesj').join, 'Join the object')
      map('n', 'gS', require('treesj').split, 'Split the object')
    end,
  },
}
