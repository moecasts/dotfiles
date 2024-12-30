local M = {}

---@param opts conform.setupOpts
function M.setup(_, opts)
  for _, key in ipairs({ 'format_on_save', 'format_after_save' }) do
    if opts[key] then
      local msg = "Don't set `opts.%s` for `conform.nvim`.\n**Editor** will use the conform formatter automatically"
      -- Editor.warn(msg:format(key))
      ---@diagnostic disable-next-line: no-unknown
      opts[key] = nil
    end
  end
  ---@diagnostic disable-next-line: undefined-field
  if opts.format then
    Editor.warn('**conform.nvim** `opts.format` is deprecated. Please use `opts.default_format_opts` instead.')
  end
  require('conform').setup(opts)
end

return {
  {
    'stevearc/conform.nvim',
    dependencies = { 'mason.nvim' },
    lazy = true,
    cmd = 'ConformInfo',
    init = function()
      -- Install the conform formatter on VeryLazy
      Editor.on_very_lazy(function()
        Editor.format.register({
          name = 'conform.nvim',
          priority = 100,
          primary = true,
          format = function(buf)
            require('conform').format({ bufnr = buf })
          end,
          sources = function(buf)
            local ret = require('conform').list_formatters(buf)
            ---@param v conform.FormatterInfo
            return vim.tbl_map(function(v)
              return v.name
            end, ret)
          end,
        })
      end)
    end,
    ---@param opts ConformOpts
    opts = function()
      local plugin = require('lazy.core.config').plugins['conform.nvim']
      if plugin.config ~= M.setup then
        Editor.error({
          "Don't set `plugin.config` for `conform.nvim`.\n",
          'This will break **Editor** formatting.\n',
        })
      end
      ---@type conform.setupOpts
      local opts = {
        default_format_opts = {
          timeout_ms = 3000,
          async = false, -- not recommended to change
          quiet = false, -- not recommended to change
          lsp_format = 'fallback', -- not recommended to change
        },
        formatters_by_ft = {
          lua = { 'stylua' },
          fish = { 'fish_indent' },
          sh = { 'shfmt' },
        },
      }
      return opts
    end,
    config = M.setup,
  },
}
