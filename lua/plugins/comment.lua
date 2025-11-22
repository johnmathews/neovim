-- Comment: Smart commenting with support for embedded languages

local status_ok, _ = pcall(require, "Comment")
if not status_ok then
  return
end

local map = vim.api.nvim_set_keymap

-- invert commenting of visually selected lines
-- https://github.com/numToStr/Comment.nvim/issues/17#issuecomment-939410954
map("v", "gci", ":normal gcc<cr>", { noremap = true, silent = true })

-- Add support for Dockerfile comments
-- https://github.com/numToStr/Comment.nvim#%EF%B8%8F-filetypes--languages
local ft = require("Comment.ft")
ft.Dockerfile = { "#%s", "#%s" }

local setup = {

  context_commentstring = {
    enable = true,
    enable_autocmd = false,
    config = {
      -- You can specify the commentstring for various types of text objects
      -- For example, for JavaScript inside TSX:
      typescript = "// %s",
      tsx = {
        __default = "// %s",
        jsx_element = "{/* %s */}",
        jsx_fragment = "{/* %s */}",
        jsx_attribute = "{/* %s */}",
        comment = "// %s",
      },
      html = "<!-- %s -->",
    },
  },

  ---Add a space b/w comment and the line
  ---@type boolean|fun():boolean
  padding = true,

  ---Whether the cursor should stay at its position
  ---NOTE: This only affects NORMAL mode mappings and doesn't work with dot-repeat
  ---@type boolean
  sticky = true,

  ---Lines to be ignored while comment/uncomment.
  ---Could be a regex string or a function that returns a regex string.
  ---Example: Use '^$' to ignore empty lines
  ---@type string|fun():string
  ignore = "^$",

  ---LHS of toggle mappings in NORMAL + VISUAL mode
  ---@type table
  toggler = {
    ---Line-comment toggle keymap
    line = "gcc",
    ---Block-comment toggle keymap
    -- block = 'gbc',
  },

  ---LHS of operator-pending mappings in NORMAL + VISUAL mode
  ---@type table
  opleader = {
    ---Line-comment keymap
    line = "gc",
    ---Block-comment keymap
    -- block = 'gb',
  },

  ---LHS of extra mappings
  ---@type table
  extra = {
    ---Add comment on the line above
    above = "gcO",
    ---Add comment on the line below
    below = "gco",
    ---Add comment at the end of line
    eol = "gcA",
  },

  ---Create basic (operator-pending) and extended mappings for NORMAL + VISUAL mode
  ---NOTE: If `mappings = false` then the plugin won't create any mappings
  ---@type boolean|table
  mappings = {
    ---Operator-pending mapping
    ---Includes `gcc`, `gbc`, `gc[count]{motion}` and `gb[count]{motion}`
    ---NOTE: These mappings can be changed individually by `opleader` and `toggler` config
    basic = true,
    ---Extra mapping
    ---Includes `gco`, `gcO`, `gcA`
    extra = true,
    ---Extended mapping
    ---Includes `g>`, `g<`, `g>[count]{motion}` and `g<[count]{motion}`
    extended = false,
  },

  pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
}

require("Comment").setup(setup)
