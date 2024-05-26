local keymap = vim.keymap.set
local saga = require('lspsaga')

-- DOCUMENTATION https://nvimdev.github.io/lspsaga/
-- lspsage.symbols in breadcrumbs
-- winbar?

saga.setup({
  outline = {
    layout = "normal",
    win_width = 40,
    close_after_jump = false,
    expand_nodes = false,
  },
  finder = {
    max_width = 100,
  },
  ui = {
    title = true,
    border = "rounded",
  },
  beacon = {
    enable = true,
    frequency = 7,
  },
  lightbulb = {
    enable = false,
    enable_in_insert = false,
    sign = true,
    sign_priority = 40,
    virtual_text = true,
  },
  symbol_in_winbar = {
    show_file  = false,
    enable = false,
  }
})

-- when you use action in finder like open vsplit then you can use <C-t> to jump back
keymap("n", "<leader>i", "<cmd>Lspsaga finder<CR>", { silent = true, desc = "LSP finder" })
keymap("n", "<leader>r", "<cmd>Lspsaga rename<CR>", { silent = true, desc = "LspSaga rename" })
-- keymap({ "n", "v" }, "<leader>a", saga.code_action, { silent = true, desc = "LspSaga code actions", buffer=bufnr })
keymap({ "n", "v" }, "<leader>a", "<cmd>Lspsaga code_action<CR>", { silent = true, desc = "LspSaga code actions" })

-- Peek Definition
-- you can edit the definition file in this floatwindow
-- also support open/vsplit/etc operation check definition_action_keys
-- support tagstack C-t jump back
keymap("n", "gld", "<cmd>Lspsaga peek_definition<CR>", { silent = true, desc = "LspSaga peek definition" })

keymap("n", "<leader>l", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true, desc = "LspSaga line diagnostics" })

-- Show cursor diagnostics
-- keymap("n", "<leader>lc", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { silent = true, desc = "LspSaga cursor diagnostics" })

-- Diagnostic jump can use `<c-o>` to jump back
keymap("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { silent = true, desc = "LspSaga prev diagnostic" })
keymap("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", { silent = true, desc = "LspSaga next diagnostic" })
keymap("n", "[E", function() require("lspsaga.diagnostic").goto_prev({ severity = vim.diagnostic.severity.ERROR }) end,
  { silent = true, desc = "LspSaga prev error" })
keymap("n", "]E", function() require("lspsaga.diagnostic").goto_next({ severity = vim.diagnostic.severity.ERROR }) end,
  { silent = true, desc = "LspSaga next error" })

-- Outline is buggy use AERIAL instead
-- keymap("n", "<leader>o", "<cmd>Lspsaga outline<CR>", { silent = true, desc = "LspSaga outline" })

-- Hover Doc
keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { silent = true, desc = "LspSaga documentation" })
