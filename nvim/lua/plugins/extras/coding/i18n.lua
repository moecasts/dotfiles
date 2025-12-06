return {
  {
    'yelog/i18n.nvim',
    dependencies = {
      'ibhagwan/fzf-lua',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('i18n').setup({
        -- Locales to parse; first is the default locale
        -- Use I18nNextLocale command to switch the default locale in real time
        locales = { 'en-US', 'zh-CN' },
        -- sources can be string or table { pattern = "...", prefix = "..." }
        sources = {
          'src/locales/{locales}.json',
          -- { pattern = "src/locales/lang/{locales}/{module}.ts",            prefix = "{module}." },
          -- { pattern = "src/views/{bu}/locales/lang/{locales}/{module}.ts", prefix = "{bu}.{module}." },
        },
      })
    end,
  },
}
