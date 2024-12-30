local supported = {
  'astro',
  'javascript',
  'javascriptreact',
  'typescript',
  'typescriptreact',
  'html',
  'mdx',
  'vue',
  'markdown',
}

return {
  {
    'williamboman/mason.nvim',
    opts = { ensure_installed = { 'eslint_d' } },
  },
  {
    'stevearc/conform.nvim',
    optional = true,
    ---@param opts ConformOpts
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(supported) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        table.insert(opts.formatters_by_ft[ft], 1, 'eslint_d')
      end
    end,
  },
}
