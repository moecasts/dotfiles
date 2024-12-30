local function map(mode, lhs, rhs, opts)
  local keys = require('lazy.core.handler').handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

-- buffers
if Editor.has('bufferline.nvim') then
  map('n', '<S-h>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev buffer' })
  map('n', '<S-l>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })
  map('n', '[b', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev buffer' })
  map('n', ']b', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })
else
  map('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Prev buffer' })
  map('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next buffer' })
  map('n', '[b', '<cmd>bprevious<cr>', { desc = 'Prev buffer' })
  map('n', ']b', '<cmd>bnext<cr>', { desc = 'Next buffer' })
end
map('n', '<leader>bb', '<cmd>e #<cr>', { desc = 'Switch to Other Buffer' })
map('n', '<leader>`', '<cmd>e #<cr>', { desc = 'Switch to Other Buffer' })

-- tabs
map('n', '<leader>th', '<cmd>:tabfirst<CR>', { desc = 'First tab' })
map('n', '<leader>tj', '<cmd>:tabnext<CR>', { desc = 'Next tab' })
map('n', '<leader>tk', '<cmd>:tabprev<CR>', { desc = 'Prev tab' })
map('n', '<leader>tl', '<cmd>:tablast<CR>', { desc = 'Last tab' })
map('n', '<leader>tt', '<cmd>:tabedit<Space>', { desc = 'Edit tab' })
map('n', '<leader>tn', '<cmd>:tabnew<CR>', { desc = 'New tab' })
map('n', '<leader>tm', '<cmd>:tabm<Space>', { desc = 'Move tab' })
map('n', '<leader>td', '<cmd>:tabclose<CR>', { desc = 'Close tab' })

-- diagnostic
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end
map('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line Diagnostics' })
map('n', ']d', diagnostic_goto(true), { desc = 'Next Diagnostic' })
map('n', '[d', diagnostic_goto(false), { desc = 'Prev Diagnostic' })
map('n', ']e', diagnostic_goto(true, 'ERROR'), { desc = 'Next Error' })
map('n', '[e', diagnostic_goto(false, 'ERROR'), { desc = 'Prev Error' })
map('n', ']w', diagnostic_goto(true, 'WARN'), { desc = 'Next Warning' })
map('n', '[w', diagnostic_goto(false, 'WARN'), { desc = 'Prev Warning' })

-- stylua: ignore start

-- toggle options
map("n", "<leader>uf", Editor.format.toggle, { desc = "Toggle format on Save" })
map("n", "<leader>us", function() Editor.toggle("spell") end, { desc = "Toggle Spelling" })
map("n", "<leader>uw", function() Editor.toggle("wrap") end, { desc = "Toggle Word Wrap" })
map("n", "<leader>ul", function() Editor.toggle("relativenumber", true) Editor.toggle("number") end, { desc = "Toggle Line Numbers" })
map("n", "<leader>ud", Editor.toggle_diagnostics, { desc = "Toggle Diagnostics" })
local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 3
map("n", "<leader>uc", function() Editor.toggle("conceallevel", false, {0, conceallevel}) end, { desc = "Toggle Conceal" })

-- stylua: ignore end
