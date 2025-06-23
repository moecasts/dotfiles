return {
  -- depends on the typescript extra
  -- { import = 'lazyvim.plugins.extras.lang.typescript' },

  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'vue', 'css' } },
  },

  -- Add LSP servers
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        volar = {
          init_options = {
            vue = {
              hybridMode = true,
            },
          },
        },
        vtsls = {},
      },
    },
  },

  -- Configure tsserver plugin
  -- {
  --   'neovim/nvim-lspconfig',
  --   opts = function(_, opts)
  --     table.insert(opts.servers.vtsls.filetypes, 'vue')
  --     Editor.extend(opts.servers.vtsls, 'settings.vtsls.tsserver.globalPlugins', {
  --       {
  --         name = '@vue/typescript-plugin',
  --         location = Editor.get_pkg_path('vue-language-server', '/node_modules/@vue/language-server'),
  --         languages = { 'vue' },
  --         configNamespace = 'typescript',
  --         enableForWorkspaceTypeScriptVersions = true,
  --       },
  --     })
  --   end,
  -- },
}
