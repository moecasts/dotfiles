return {
  {
    'voldikss/vim-floaterm',
    keys = {
      { '<leader>ft', '<cmd>FloatermNew<cr>', desc = 'Floaterm New' },
      { '<F7>', '<cmd>FloatermToggle<cr>', mode = 'n', desc = 'Floaterm Toggle' },
      -- stylua: ignore
      { '<F7>', '<C-\\><C-n><cmd>FloatermToggle<cr>', mode = 't', desc = 'Floaterm Toggle' },
    },
  },
}
