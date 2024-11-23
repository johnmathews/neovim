-- https://github.com/ChristianChiarulli/nvim/blob/master/lua/user/whichkey.lua

local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

local setup = {
  plugins = {
    marks = true,       -- shows a list of your marks on ' and `
    registers = true,   -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    spelling = {
      enabled = true,   -- enabling this will show WhichKey when pressing z= to select spelling suggestions
      suggestions = 20, -- how many suggestions should be shown in the list?
    },
    -- the presets plugin, adds help for a bunch of default keybindings in Neovim
    -- No actual key bindings are created
    presets = {
      operators = true,    -- adds help for operators like d, y, ... and registers them for motion / text object completion
      motions = true,      -- adds help for motions
      text_objects = true, -- help for text objects triggered after entering an operator
      windows = true,      -- default bindings on <c-w>
      nav = true,          -- misc bindings to work with windows
      z = true,            -- bindings for folds, spelling and others prefixed with z
      g = true,            -- bindings for prefixed with g
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
    spacing = 3,                    -- spacing between columns
    align = "left",                 -- align columns left, center or right
  },
  show_help = true,                 -- show help message on the command line when the popup is visible
}

which_key.setup(setup)

-- which_key.register({
  -- { "D",  group = "Database" },
  -- { "Df", "<Cmd>DBUIFindBuffer<Cr>",    desc = "Find buffer" },
  -- { "Dq", "<Cmd>DBUILastQueryInfo<Cr>", desc = "Last query info" },
  -- { "Dr", "<Cmd>DBUIRenameBuffer<Cr>",  desc = "Rename buffer" },
  -- { "Du", "<Cmd>DBUIToggle<Cr>",        desc = "Toggle UI" }
-- })
