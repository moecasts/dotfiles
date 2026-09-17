local ts_root_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' }

---@param bufnr integer
---@return string?
local function typescript_root(bufnr)
  local deno_root = vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc' })
  local deno_lock_root = vim.fs.root(bufnr, { 'deno.lock' })
  local root_dir = vim.fs.root(bufnr, { ts_root_markers, { '.git' } })

  if deno_lock_root and (not root_dir or #deno_lock_root > #root_dir) then
    return
  end
  if deno_root and (not root_dir or #deno_root >= #root_dir) then
    return
  end

  return root_dir or vim.fn.getcwd()
end

---@param root_dir string
---@return boolean
local function uses_typescript_7(root_dir)
  local package_json = root_dir .. '/node_modules/typescript/package.json'
  local ok, lines = pcall(vim.fn.readfile, package_json)
  if not ok then
    return false
  end

  local ok_json, package = pcall(vim.json.decode, table.concat(lines, '\n'))
  local version = ok_json and package.version
  if type(version) ~= 'string' then
    return false
  end

  return tonumber(version:match('^(%d+)')) == 7
end

---@param root_dir string
---@return boolean
local function needs_legacy_typescript_server(root_dir)
  local ok, lines = pcall(vim.fn.readfile, root_dir .. '/package.json')
  if not ok then
    return false
  end

  local ok_json, package = pcall(vim.json.decode, table.concat(lines, '\n'))
  if not ok_json then
    return false
  end

  -- These tools embed the legacy TypeScript language service and cannot use
  -- TypeScript 7's native LSP yet.
  local embedded_language_packages = { 'vue', '@angular/core', 'astro', 'svelte', '@mdx-js/mdx' }
  for _, dependency_type in ipairs({ 'dependencies', 'devDependencies', 'peerDependencies' }) do
    local dependencies = package[dependency_type] or {}
    for _, dependency in ipairs(embedded_language_packages) do
      if dependencies[dependency] then
        return true
      end
    end
  end

  return false
end

---@param bufnr integer
---@return boolean
local function is_typescript_7_project(bufnr)
  local root_dir = typescript_root(bufnr)
  return root_dir ~= nil and uses_typescript_7(root_dir) and not needs_legacy_typescript_server(root_dir)
end

return {
  recommended = function()
    return Editor.extras.wants({
      ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
      root = { 'package.json', 'tsconfig.json', 'jsconfig.json', 'yarn.lock', 'package-lock.json' },
    })
  end,

  desc = 'TypeScript/JavaScript support with vtsls LSP',

  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'typescript', 'tsx', 'javascript', 'jsdoc' } },
  },

  -- correctly setup lspconfig
  {
    'neovim/nvim-lspconfig',
    opts = {
      -- make sure mason installs the server
      servers = {
        --- @deprecated -- tsserver renamed to ts_ls but not yet released, so keep this for now
        --- the proper approach is to check the nvim-lspconfig release version when it's released to determine the server name dynamically
        tsserver = {
          enabled = false,
        },
        ts_ls = {
          enabled = false,
        },
        -- TypeScript 7+ implements LSP natively via `tsc --lsp`. Keep the
        -- legacy vtsls bridge for every other project.
        tsc = {
          filetypes = {
            'javascript',
            'javascriptreact',
            'javascript.jsx',
            'typescript',
            'typescriptreact',
            'typescript.tsx',
          },
          ---@type lspconfig.settings.tsc
          settings = {
            ['js/ts'] = {
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = {
                  enabled = 'literals',
                  suppressWhenArgumentMatchesName = true,
                },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
            },
          },
        },
        vtsls = {
          -- explicitly add default filetypes, so that we can extend
          -- them in related extras
          filetypes = {
            'javascript',
            'javascriptreact',
            'javascript.jsx',
            'typescript',
            'typescriptreact',
            'typescript.tsx',
          },
          root_dir = function(bufnr, on_dir)
            if not is_typescript_7_project(bufnr) then
              on_dir(typescript_root(bufnr))
            end
          end,
          settings = {
            complete_function_calls = true,
            vtsls = {
              enableMoveToFileCodeAction = true,
              autoUseWorkspaceTsdk = true,
              experimental = {
                maxInlayHintLength = 30,
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
              },
            },
            typescript = {
              updateImportsOnFileMove = { enabled = 'always' },
              suggest = {
                completeFunctionCalls = true,
              },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = 'literals' },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
              preferences = {
                importModuleSpecifierPreference = 'relative',
                -- 启用 removeUnusedImports 功能
                organizeImports = true,
                removeUnusedImports = true,
              },

              importModuleSpecifierPreference = 'relative',
              -- 启用 removeUnusedImports 功能
              organizeImports = true,
              removeUnusedImports = true,

              maxTsServerMemory = 8192,
            },
          },
          keys = {
            {
              'gD',
              function()
                local params = vim.lsp.util.make_position_params()
                Editor.lsp.execute({
                  command = 'typescript.goToSourceDefinition',
                  arguments = { params.textDocument.uri, params.position },
                  open = true,
                })
              end,
              desc = 'Goto Source Definition',
            },
            {
              'gR',
              function()
                Editor.lsp.execute({
                  command = 'typescript.findAllFileReferences',
                  arguments = { vim.uri_from_bufnr(0) },
                  open = true,
                })
              end,
              desc = 'File References',
            },
            -- {
            --   '<leader>co',
            --   Editor.lsp.action['source.organizeImports'],
            --   desc = 'Organize Imports',
            -- },
            {
              '<leader>cM',
              Editor.lsp.action['source.addMissingImports.ts'],
              desc = 'Add missing imports',
            },
            {
              '<leader>cu',
              Editor.lsp.action['source.removeUnused.ts'],
              desc = 'Remove unused imports',
            },
            {
              '<leader>cD',
              Editor.lsp.action['source.fixAll.ts'],
              desc = 'Fix all diagnostics',
            },
            {
              '<leader>cV',
              function()
                Editor.lsp.execute({ command = 'typescript.selectTypeScriptVersion' })
              end,
              desc = 'Select TS workspace version',
            },
          },
        },
      },
      setup = {
        --- @deprecated -- tsserver renamed to ts_ls but not yet released, so keep this for now
        --- the proper approach is to check the nvim-lspconfig release version when it's released to determine the server name dynamically
        tsserver = function()
          -- disable tsserver
          return true
        end,
        ts_ls = function()
          -- disable tsserver
          return true
        end,
        -- Keep lspconfig's default tsc root_dir so it can resolve and cache
        -- the workspace-local TypeScript 7 binary. Only gate attachment.
        tsc = function(_, opts)
          local default_root_dir = vim.lsp.config.tsc and vim.lsp.config.tsc.root_dir
          opts.root_dir = function(bufnr, on_dir)
            if not is_typescript_7_project(bufnr) then
              return
            end
            if type(default_root_dir) == 'function' then
              return default_root_dir(bufnr, on_dir)
            end
            on_dir(typescript_root(bufnr))
          end
        end,
        vtsls = function(_, opts)
          -- Editor.lsp.on_attach(function(client, buffer)
          --   client.commands['_typescript.moveToFileRefactoring'] = function(command, ctx)
          --     ---@type string, string, lsp.Range
          --     local action, uri, range = unpack(command.arguments)

          --     local function move(newf)
          --       client.request('workspace/executeCommand', {
          --         command = command.command,
          --         arguments = { action, uri, range, newf },
          --       })
          --     end

          --     local fname = vim.uri_to_fname(uri)
          --     client.request('workspace/executeCommand', {
          --       command = 'typescript.tsserverRequest',
          --       arguments = {
          --         'getMoveToRefactoringFileSuggestions',
          --         {
          --           file = fname,
          --           startLine = range.start.line + 1,
          --           startOffset = range.start.character + 1,
          --           endLine = range['end'].line + 1,
          --           endOffset = range['end'].character + 1,
          --         },
          --       },
          --     }, function(_, result)
          --       ---@type string[]
          --       local files = result.body.files
          --       table.insert(files, 1, 'Enter new path...')
          --       vim.ui.select(files, {
          --         prompt = 'Select move destination:',
          --         format_item = function(f)
          --           return vim.fn.fnamemodify(f, ':~:.')
          --         end,
          --       }, function(f)
          --         if f and f:find('^Enter new path') then
          --           vim.ui.input({
          --             prompt = 'Enter move destination:',
          --             default = vim.fn.fnamemodify(fname, ':h') .. '/',
          --             completion = 'file',
          --           }, function(newf)
          --             return newf and move(newf)
          --           end)
          --         elseif f then
          --           move(f)
          --         end
          --       end)
          --     end)
          --   end
          -- end, 'vtsls')
          -- copy typescript settings to javascript
          opts.settings.javascript =
            vim.tbl_deep_extend('force', {}, opts.settings.typescript, opts.settings.javascript or {})
        end,
      },
    },
  },

  -- code actions
  {
    'nvimtools/none-ls.nvim',
    optional = true,
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = { ensure_installed = { 'eslint_d' } },
      },
      'nvimtools/none-ls-extras.nvim',
    },
    opts = function(_, opts)
      local nls = require('null-ls')
      opts.sources = vim.list_extend(opts.sources or {}, {
        require('none-ls.code_actions.eslint_d'),
      })
    end,
  },

  -- dap

  -- neotest
  {
    'nvim-neotest/neotest',
    optional = true,
    dependencies = {
      'marilari88/neotest-vitest',
      'nvim-neotest/neotest-jest',
    },
    opts = {
      adapters = {
        ['neotest-vitest'] = {},
        ['neotest-jest'] = {},
      },
    },
  },
}
