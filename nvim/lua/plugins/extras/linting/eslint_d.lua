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
  'json',
  'jsonc',
}

local config_files = {
  '.eslintrc',
  '.eslintrc.js',
  '.eslintrc.cjs',
  '.eslintrc.yaml',
  '.eslintrc.yml',
  '.eslintrc.json',
}

return {
  {
    'williamboman/mason.nvim',
    opts = { ensure_installed = { 'eslint_d' } },
  },
  {
    'mfussenegger/nvim-lint',
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      for _, ft in ipairs(supported) do
        opts.linters_by_ft[ft] = opts.linters_by_ft[ft] or {}
        table.insert(opts.linters_by_ft[ft], 'eslint_d')

        opts.linters = opts.linters or {}

        opts.linters['eslint_d'] = {
          condition = function(ctx)
            return vim.fs.find(config_files, { path = ctx.filename, upward = true })[1]
          end,
        }
      end
    end,
  },
}
