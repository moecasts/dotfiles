local supported = {
  'blade',
}

return {
  {
    'williamboman/mason.nvim',
    opts = { ensure_installed = { 'blade-formatter' } },
  },

  {
    'stevearc/conform.nvim',
    optional = true,
    ---@param opts ConformOpts
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(supported) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        table.insert(opts.formatters_by_ft[ft], 'blade-formatter')
      end

      opts.formatters = opts.formatters or {}
      opts.formatters['blade-formatter'] = {
        require_cwd = true,
        prepend_args = { '-i', '2' },
      }
    end,
  },

  -- none-ls support
  {
    'nvimtools/none-ls.nvim',
    optional = true,
    opts = function(_, opts)
      local nls = require('null-ls')
      opts.sources = opts.sources or {}
      table.insert(opts.sources, nls.builtins.formatting.blade_formatter)
    end,
  },
}
