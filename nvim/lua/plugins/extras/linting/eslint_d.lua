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
      end
    end,
  },
}

