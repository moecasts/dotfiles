-- https://biomejs.dev/internals/language-support/
local supported = {
  'astro',
  'css',
  'graphql',
  -- "html",
  'javascript',
  'javascriptreact',
  'json',
  'jsonc',
  -- "markdown",
  'svelte',
  'typescript',
  'typescriptreact',
  'vue',
  -- "yaml",
}

local config_files = {
  'biome.json',
  'biome.jsonc',
}

return {
  {
    'williamboman/mason.nvim',
    opts = { ensure_installed = { 'biome' } },
  },

  {
    'stevearc/conform.nvim',
    optional = true,
    ---@param opts ConformOpts
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(supported) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        table.insert(opts.formatters_by_ft[ft], 'biome-check')
      end

      opts.formatters = opts.formatters or {}
      opts.formatters['biome-check'] = {
        require_cwd = true,
        append_args = { '--unsafe' },
        condition = require('conform.util').root_file(config_files),
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
      table.insert(
        opts.sources,
        nls.builtins.formatting.biome.with({
          condition = function(utils)
            return utils.root_has_file(config_files)
          end,
        })
      )
    end,
  },
}
