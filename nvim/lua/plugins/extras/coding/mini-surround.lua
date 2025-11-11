return {
  -- surround
  {
    'echasnovski/mini.surround',
    event = 'VeryLazy',
    config = function()
      -- use gz mappings instead of s to prevent conflict with leap
      require('mini.surround').setup({})
    end,
  },
}
