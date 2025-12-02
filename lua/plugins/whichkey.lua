-- WhichKey: Display available keybindings in popup menu
-- https://github.com/ChristianChiarulli/nvim/blob/master/lua/user/whichkey.lua

local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

local setup = {
  plugins = {
    marks = true, -- shows a list of your marks on ' and `
    registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    spelling = {
      enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
      suggestions = 20, -- how many suggestions should be shown in the list?
    },
    -- the presets plugin, adds help for a bunch of default keybindings in Neovim
    -- No actual key bindings are created
    presets = {
      operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
      motions = true, -- adds help for motions
      text_objects = true, -- help for text objects triggered after entering an operator
      windows = true, -- default bindings on <c-w>
      nav = true, -- misc bindings to work with windows
      z = true, -- bindings for folds, spelling and others prefixed with z
      g = true, -- bindings for prefixed with g
    },
  },

  icons = {
    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
    separator = "➜", -- symbol used between a key and it's label
    group = "+", -- symbol prepended to a group
  },

  layout = {
    height = { min = 4, max = 25 }, -- min and max height of the columns
    width = { min = 20, max = 50 }, -- min and max width of the columns
    spacing = 3, -- spacing between columns
    align = "left", -- align columns left, center or right
  },
  show_help = true, -- show help message on the command line when the popup is visible
}

which_key.setup(setup)

-- Register key groups and LSP bindings for better discoverability
which_key.add({
  -- Telescope groups
  { "<Tab>", group = "Telescope" },
  { "<Tab>g", group = "Git" },
  { "<Tab>t", group = "Tools" },

  -- LSP keybindings (Neovim v0.11+ built-in + Telescope overrides)
  { "g", group = "Go-to / LSP" },
  { "gd", desc = "Go to definition" },
  { "gD", desc = "Go to declaration" },
  { "gr", desc = "Show references (Telescope picker)" },
  { "gra", desc = "Code actions" },
  { "gi", desc = "Go to implementation (Telescope picker)" },
  { "grn", desc = "Rename symbol (workspace-wide)" },
  { "grt", desc = "Go to type definition" },

  -- Treesitter text objects
  { "a", group = "Text objects (Treesitter)" },
  { "af", desc = "Function (outer)" },
  { "if", desc = "Function (inner)" },
  { "ac", desc = "Class (outer)" },
  { "ic", desc = "Class (inner)" },

  -- Leader groups
  { "<leader>", group = "Leader" },
  { "<leader>c", group = "Code (format/lint)" },
  { "<leader>cf", desc = "Format" },
  { "<leader>cl", desc = "Lint" },
  { "<leader>li", desc = "Toggle inlay hints" },
  { "<leader>d", group = "Peek definition (Treesitter)" },
  { "<leader>df", desc = "Peek function definition" },
  { "<leader>dF", desc = "Peek class definition" },
  { "<leader>m", group = "Markdown" },
  { "<leader>mg", desc = "Preview (Glow)" },
  { "<leader>s", group = "Source (Git)" },
  { "<leader>sh", group = "Hunk" },
  { "<leader>t", group = "Treesitter" },
  { "<leader>tc", desc = "Show item under cursor" },
  { "<leader>tp", desc = "Playground" },
  { "<leader>ts", group = "Swap parameter" },
  { "<leader>tsa", desc = "Swap next" },
  { "<leader>tsA", desc = "Swap previous" },
  { "<leader>v", group = "Vim config" },
  { "<leader>ve", desc = "Edit init.lua" },
  { "<leader>vf", desc = "Edit ftplugin" },
  { "<leader>vr", desc = "Reload vimrc" },
  { "<leader>x", desc = "Open in default app" },

  -- LocalLeader groups
  { "<LocalLeader>", group = "LocalLeader (Backslash)" },
  { "<LocalLeader>d", desc = "Telescope: Find definitions" },
  { "<LocalLeader>i", desc = "Telescope: Find implementations" },
  { "<LocalLeader>n", desc = "Toggle nvim-tree visibility" },
  { "<LocalLeader>r", desc = "Telescope: Find references" },
  { "<LocalLeader>s", desc = "Cycle diagnostics display" },
  { "<LocalLeader>t", desc = "Show active LSP/formatters/linters" },
  { "<LocalLeader>fs", desc = "Search sessions" },
})

-- which_key.register({
-- { "D",  group = "Database" },
-- { "Df", "<Cmd>DBUIFindBuffer<Cr>",    desc = "Find buffer" },
-- { "Dq", "<Cmd>DBUILastQueryInfo<Cr>", desc = "Last query info" },
-- { "Dr", "<Cmd>DBUIRenameBuffer<Cr>",  desc = "Rename buffer" },
-- { "Du", "<Cmd>DBUIToggle<Cr>",        desc = "Toggle UI" }
-- })
