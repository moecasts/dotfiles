return {
  {
    'olimorris/codecompanion.nvim',
    enabled = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante', 'codecompanion' },
        },
        ft = { 'markdown', 'Avante', 'codecompanion' },
      },
    },
    opts = {
      adapters = {
        deepseek_tencent = function()
          return require('codecompanion.adapters').extend('deepseek', {
            name = 'deepseek_tencent',
            url = 'https://api.lkeap.cloud.tencent.com/v1',
            env = {
              api_key = function()
                return os.getenv('DEEPSEEK_API_KEY')
              end,
            },
            schema = {
              model = {
                default = 'deepseek-v3-0324',
                choices = {
                  ['deepseek-r1'] = { opts = { can_reason = true } },
                  'deepseek-v3',
                  'deepseek-v3-0324',
                },
              },
            },
          })
        end,
      },
      strategies = {
        chat = { adapter = 'deepseek_tencent' },
        inline = { adapter = 'deepseek_tencent' },
        agent = { adapter = 'deepseek_tencent' },
      },
    },
    config = true,
  },
}
