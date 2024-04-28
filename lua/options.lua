local options = {
  encoding = "utf-8",
  hidden = true,
  clipboard = "unnamedplus",
  termguicolors = true, -- required for bufferline

  linespace = 8,
  scrolloff = 2,
  sidescrolloff = 8,
  splitbelow = true,
  splitright = true,
  backspace = { "indent", "eol", "start" },
  expandtab = true,
  shiftwidth = 2, -- Size of an indent
  tabstop = 2,    -- Number of spaces tabs count for

  wildmode = "longest:full,full",
  wrap = true,       -- long lines dont disappear off the screen
  wrapscan = true,   -- searchees wrap around to beginning or end
  whichwrap = "h,l", -- this seems to mess up intuitive col count when jumping lines
  virtualedit = "block",
  list = true,       -- Show some invisible characters
  listchars = { tab = " ", trail = "·" },

  undofile = true,
  undolevels = 10000,

  backup = true,
  backupdir = "/tmp/,/private/tmp",
  directory = "/tmp/,/private/tmp", -- maybe this is swapfile location?

  winbar = nil, -- force winbar to be disabled. because lspsaga winbar doesnt seem to work as documented

  timeout = true,
  timeoutlen = 300,
  ttimeoutlen = 200,

  mouse = "a",
  startofline = false,
  number = true,
  signcolumn = "auto",

  shortmess = "filnxtToOFc",
  completeopt = "menu,menuone,noselect",

  -- swap file is written if nothing happens for this many milliseconds
  updatetime = 2000,

  redrawtime = 500,

  -- this is only meant to be set temporarily,
  lazyredraw = false,

  cmdheight = 2,


  spelllang = { "en_us" },

  -- opt.spellfile = vim.fn.stdpath("config") .. "/spell"
  -- opt.spellsuggest = 10

  incsearch = true,
  ignorecase = true,
  smartcase = true,
  hlsearch = true,

  background = "dark",

  filetype = "on",
  -- opt.plugin = "on"
  -- opt.indent = "on"
  syntax = "on",

  -- Cursor settings https://vim.fandom.com/wiki/Change_cursor_shape_in_different_modes
  -- let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  -- let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
  -- let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"

  cursorline = false,
  cursorcolumn = false,

  smartindent = false, -- Insert indents automatically
  cindent = true,      -- https://vim.fandom.com/wiki/Restoring_indent_after_typing_hash
  guicursor = "n-v-c-sm:block-blinkwait50-blinkon50-blinkoff50,i-ci-ve:ver25-Cursor-blinkon100-blinkoff100,r-cr-o:hor20",


  laststatus = 3,
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.cmd("set indentkeys-=0#") -- https://vim.fandom.com/wiki/Restoring_indent_after_typing_hash

-- this is for the cursorhold plugin https://github.com/antoinemadec/FixCursorHold.nvim
vim.cmd([[
  let g:cursorhold_updatetime = 100
]])


vim.cmd("au TextYankPost * lua vim.highlight.on_yank {on_visual = true}")

-- this lets you do `gf` (go to file) on e.g.: "plugins/monokai.lua"
vim.cmd("set path+=~/.config/nvim/lua/plugins/")

vim.g.markdown_fenced_languages = { "html", "javascript", "typescript", "css", "scss", "lua", "vim" }

-- opt.hlsearch = true -- Highlight found searches
-- opt.ignorecase = true -- Ignore case
-- opt.inccommand = "split" -- Get a preview of replacements
-- opt.incsearch = true -- Shows the match while typing
-- opt.joinspaces = false -- No double spaces with join
-- opt.linebreak = true -- Stop words being broken on wrap
-- opt.shiftround = true -- Round indent
-- opt.signcolumn = "yes:1" -- always show signcolumns
-- opt.smartcase = true -- Do not ignore case with capitals
-- vim.o.whichwrap = vim.o.whichwrap .. "<,>" -- Wrap movement between lines in edit mode with arrows
-- opt.wrap = true
-- -- opt.cc = "80"

-- vim.opt.shortmess:append("c") -- already appended

-- autoswap plugin, if using tmux, switch to the tmux pain containing the open buffer.
vim.g.autoswap_detect_tmux = 1
