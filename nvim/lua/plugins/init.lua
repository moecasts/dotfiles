return {
  {
    "shaunsingh/nord.nvim",
      lazy = false,
      priority = 1000,
      config = function ()
        vim.cmd([[colorscheme nord]])
      end,
  },
  require('plugins.ui.alpha'),
  require('plugins.cmp'),
  {
    "nvim-neo-tree/neo-tree.nvim",
      lazy = false,
      cmd = "Neotree",
      branch = "v2.x",
      keys = {
        { "<leader>ft", "<cmd>Neotree toggle<cr>", desc = "NeoTree" },
      },
      dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
      },
      config = function()
        require("neo-tree").setup({
          close_if_last_window = true,
          enable_git_status = true,
          window = {
            width = 30,
          },
          filesystem = {
            follow_current_file = true,
            hijack_netrw_behavior = "open_current",
          },
        })
      end,
  },
}
