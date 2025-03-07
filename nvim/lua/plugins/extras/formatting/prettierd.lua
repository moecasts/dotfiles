local supported = {
  'css',
  'graphql',
  'handlebars',
  'html',
  'javascript',
  'javascriptreact',
  'json',
  'jsonc',
  'less',
  'markdown',
  'markdown.mdx',
  'scss',
  'typescript',
  'typescriptreact',
  'vue',
  'yaml',
}

return {
  {
    'williamboman/mason.nvim',
    opts = { ensure_installed = { 'prettierd' } },
  },
  {
    'stevearc/conform.nvim',
    optional = true,
    ---@param opts ConformOpts
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(supported) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        table.insert(opts.formatters_by_ft[ft], 'prettierd')
      end

      opts.formatters = opts.formatters or {}
      opts.formatters.prettierd = {
        require_cwd = true,
      }
    end,
  },
}
