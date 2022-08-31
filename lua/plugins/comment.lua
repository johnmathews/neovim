local status_ok, comment = pcall(require, "Comment")
if not status_ok then
  return
end

local map = vim.api.nvim_set_keymap

-- invert commenting of visually selected lines
-- https://github.com/numToStr/Comment.nvim/issues/17#issuecomment-939410954
map("v", "gci", ":normal gcc<cr>",  { noremap = true, silent = true })

-- Add support for Dockerfile comments
-- https://github.com/numToStr/Comment.nvim#%EF%B8%8F-filetypes--languages
local ft = require('Comment.ft')
ft.Dockerfile = {'#%s', '#%s'}

setup = {
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
  ignore = '^$',

  ---LHS of toggle mappings in NORMAL + VISUAL mode
  ---@type table
  toggler = {
    ---Line-comment toggle keymap
    line = 'gcc',
    ---Block-comment toggle keymap
    -- conflicts with bufferline
    -- block = 'gbc',
  },

  ---LHS of operator-pending mappings in NORMAL + VISUAL mode
  ---@type table
  opleader = {
    ---Line-comment keymap
    line = 'gc',
    ---Block-comment keymap
    -- conflicts with bufferline
    -- block = 'gb',
  },

  ---LHS of extra mappings
  ---@type table
  extra = {
    ---Add comment on the line above
    above = 'gcO',
    ---Add comment on the line below
    below = 'gco',
    ---Add comment at the end of line
    eol = 'gcA',
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


  pre_hook = function(ctx)
    -- Only calculate commentstring for tsx filetypes
    if vim.bo.filetype == 'typescriptreact' then
      local U = require('Comment.utils')

      -- Determine whether to use linewise or blockwise commentstring
      local type = ctx.ctype == U.ctype.line and '__default' or '__multiline'

      -- Determine the location where to calculate commentstring from
      local location = nil
      if ctx.ctype == U.ctype.block then
        location = require('ts_context_commentstring.utils').get_cursor_location()
      elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
        location = require('ts_context_commentstring.utils').get_visual_start_location()
      end

      return require('ts_context_commentstring.internal').calculate_commentstring({
        key = type,
        location = location,
      })
    end
  end,

  post_hook = function(ctx)
    if ctx.range.srow == ctx.range.erow then
      -- do something with the current line
      -- this can be left empty, you don't need a `pass` statement like in python.
      -- https://stackoverflow.com/questions/19927055/is-there-a-pass-statement-in-lua-like-in-python
    else
      -- do something with lines range
    end
  end
}

require('Comment').setup(setup)
