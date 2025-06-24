return {
  -- snacks - a collection of small QoL plugins for Neovim.
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = function()
      -- Toggle the profiler
      Snacks.toggle.profiler():map('<leader>pp')
      -- Toggle the profiler highlights
      Snacks.toggle.profiler_highlights():map('<leader>ph')

      -- Register notifier commands
      vim.cmd([[command! Notifications :lua Snacks.notifier.show_history()<CR>]])

      return {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        bigfile = { enabled = true },
        -- dashboard = { enabled = true },
        -- explorer = { enabled = true },
        -- indent = { enabled = true },
        -- picker = { enabled = true },
        input = {
          enabled = true,
        },
        notifier = { enabled = true },
        notify = { enabled = true },
        -- quickfile = { enabled = true },
        -- scope = { enabled = true },
        -- scroll = { enabled = true },
        statuscolumn = { enabled = true },
        -- words = { enabled = true },

        profiler = {
          -- your profiler configuration comes here
          -- or leave it empty to use the default settings
          -- refer to the configuration section below
        },
        styles = {},
      }
    end,
    keys = {
      {
        '<leader>ps',
        function()
          Snacks.profiler.scratch()
        end,
        desc = 'Profiler Scratch Bufer',
      },
    },
  },
}
