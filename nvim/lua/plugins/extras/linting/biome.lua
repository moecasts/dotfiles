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
  'biome.json',
}

return {
  {
    'williamboman/mason.nvim',
    opts = { ensure_installed = { 'biome' } },
  },
  {
    'mfussenegger/nvim-lint',
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      for _, ft in ipairs(supported) do
        opts.linters_by_ft[ft] = opts.linters_by_ft[ft] or {}
        table.insert(opts.linters_by_ft[ft], 'biomejs')

        opts.linters = opts.linters or {}

        opts.linters['biomejs'] = {
          args = { 'lint', '--reporter=json' },
          stream = 'both',
          parser = function(output)
            if not output or vim.trim(output) == '' then
              return {}
            end

            local json_start = output:find('{', 1, true)
            local json_end = output:match('.*()}')
            if not json_start or not json_end then
              return {}
            end

            local ok, decoded = pcall(vim.json.decode, output:sub(json_start, json_end))
            if not ok or not decoded then
              return {}
            end

            local severities = {
              error = vim.diagnostic.severity.ERROR,
              warning = vim.diagnostic.severity.WARN,
              information = vim.diagnostic.severity.INFO,
              hint = vim.diagnostic.severity.HINT,
            }
            local diagnostics = {}

            for _, diagnostic in ipairs(decoded.diagnostics or {}) do
              local location = diagnostic.location or {}
              local start = location.start or {}
              if start.line then
                local finish = location['end'] or start
                table.insert(diagnostics, {
                  source = 'biomejs',
                  lnum = math.max(start.line - 1, 0),
                  col = math.max((start.column or 1) - 1, 0),
                  end_lnum = math.max((finish.line or start.line) - 1, 0),
                  end_col = math.max((finish.column or start.column or 1) - 1, 0),
                  severity = severities[diagnostic.severity] or vim.diagnostic.severity.ERROR,
                  message = diagnostic.message or '',
                  code = diagnostic.category,
                })
              end
            end

            return diagnostics
          end,
          condition = function(ctx)
            return vim.fs.find(config_files, { path = ctx.filename, upward = true })[1]
          end,
        }
      end
    end,
  },
}
