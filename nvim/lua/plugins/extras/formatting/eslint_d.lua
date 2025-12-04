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

local config_files = {
  '.eslintrc',
  '.eslintrc.*',
  'eslint.config.js',
  'eslint.config.mjs',
  'eslint.config.cjs',
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

      opts.formatters = opts.formatters or {}
      opts.formatters.eslint_d = {
        require_cwd = true,
        condition = require('conform.util').root_file(config_files),
      }
    end,
  },
}
