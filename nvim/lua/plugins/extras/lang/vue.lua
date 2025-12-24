return {
  recommended = {
    ft = 'vue',
    root = { 'vue.config.js', 'vue.config.ts', 'nuxt.config.js', 'nuxt.config.ts' },
  },

  desc = 'Vue.js support with Vue LSP',

  -- depends on the typescript extra
  { import = 'plugins.extras.lang.typescript' },

  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'vue', 'css' } },
  },

  -- Add LSP servers
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        vue_ls = {},
        vtsls = {},
      },
    },
  },

  -- Configure tsserver plugin
  {
    'neovim/nvim-lspconfig',
    opts = function(_, opts)
      table.insert(opts.servers.vtsls.filetypes, 'vue')
      Editor.extend(opts.servers.vtsls, 'settings.vtsls.tsserver.globalPlugins', {
        {
          name = '@vue/typescript-plugin',
          location = Editor.get_pkg_path('vue-language-server', '/node_modules/@vue/language-server'),
          languages = { 'vue' },
          configNamespace = 'typescript',
          enableForWorkspaceTypeScriptVersions = true,
        },
      })
    end,
  },
}
