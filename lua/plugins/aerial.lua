-- Aerial: Code outline window for navigating symbols and structure
local aerial = require("aerial")

local keymap = vim.keymap.set
keymap("n", "<leader>o", "<cmd>AerialToggle!<CR>")

aerial.setup({
  -- optionally use on_attach to set keymaps when aerial has attached to a buffer
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '{' and '}'
    vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
    vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
  end,

  layout = {
    -- Dynamically size to content, within sensible bounds
    resize_to_content = true,
    max_width = { 60, 0.3 }, -- cap absolute and % of screen
    min_width = 20,
  },

  filter_kind = false, -- all filetypes
  highlight_on_hover = false, -- Highlight the symbol in the source buffer when cursor is in the aerial win
  preview = false, -- moves buffer to show current symbol
  show_guides = false,

  -- Keymaps in aerial window. Can be any value that `vim.keymap.set` accepts OR a table of keymap
  -- options with a `callback` (e.g. { callback = function() ... end, desc = "", nowait = true })
  -- Additionally, if it is a string that matches "actions.<name>",
  -- it will use the mapping at require("aerial.actions").<name>
  -- Set to `false` to remove a keymap
  keymaps = {
    ["?"] = "actions.show_help",
    ["g?"] = "actions.show_help",
    ["<ESC>"] = "actions.show_help",
    ["q"] = "actions.close",
    ["<CR>"] = "actions.jump",
    ["<2-LeftMouse>"] = "actions.jump",
    ["<C-v>"] = "actions.jump_vsplit",
    ["<C-s>"] = "actions.jump_split",

    ["o"] = "actions.tree_toggle",
    ["O"] = "actions.tree_toggle_recursive",

    ["p"] = "actions.scroll",
    ["<C-j>"] = "actions.down_and_scroll",
    ["<C-k>"] = "actions.up_and_scroll",
    ["{"] = "actions.prev",
    ["}"] = "actions.next",
    ["[["] = "actions.prev_up",
    ["]]"] = "actions.next_up",

    ["l"] = "actions.tree_open",
    ["L"] = "actions.tree_open_recursive",
    ["h"] = "actions.tree_close",
    ["H"] = "actions.tree_close_recursive",

    ["e"] = "actions.tree_open",
    ["E"] = "actions.tree_open_all",
    ["w"] = "actions.tree_close",
    ["W"] = "actions.tree_close_all",

    ["zr"] = "actions.tree_increase_fold_level",
    ["zm"] = "actions.tree_decrease_fold_level",

    ["zx"] = "actions.tree_sync_folds",
    ["zX"] = "actions.tree_sync_folds",
  },
})
