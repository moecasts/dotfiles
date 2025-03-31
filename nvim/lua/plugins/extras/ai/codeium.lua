return {
  {
    'Exafunction/codeium.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('codeium').setup({
        -- Optionally disable cmp source if using virtual text only
        enable_cmp_source = false,

        virtual_text = {
          enabled = true,
          key_bindings = {
            -- Accept the current completion.
            accept = '<M-l>',
          },
        },
      })
    end,
  },
}
