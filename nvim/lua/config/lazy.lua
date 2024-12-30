-- package manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- set global utils
_G.Editor = require('util')

local spec = require('util').merge_tables(
  require('util.plugin').generate_import_specs('plugins'),
  {}
);

-- Setup lazy.nvim
require('lazy').setup({
  spec = spec,
  -- spec =
  -- {
  --   {
  --     import = 'plugins'
  --   },
  --   {
  --     import = 'plugins/coding'
  --   },
  --   {
  --     import = 'plugins/extras/lang'
  --   },
  --   {
  --     import = 'plugins/extras/formatting'
  --   },
  --   {
  --     import = 'plugins/extras/linting'
  --   },
  --   {
  --     import = 'plugins/lsp/init'
  --   },
  -- },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { 'nord' } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
