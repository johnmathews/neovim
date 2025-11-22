-- Dashboard
local dashboard = require("alpha.themes.dashboard")
math.randomseed(os.time())

local function pick_color()
  local colors = { "String", "Identifier", "Keyword", "Number" }
  return colors[math.random(#colors)]
end

local function footer()
  -- local total_plugins = #vim.tbl_keys(packer_plugins)
  local datetime = os.date(" %d-%m-%Y   %H:%M:%S")
  return datetime
    -- .. "   " .. total_plugins .. " plugins"
    .. "   v"
    .. vim.version().major
    .. "."
    .. vim.version().minor
    .. "."
    .. vim.version().patch
end

dashboard.section.header.val = {
  [[                       ]],
  [[                       ]],
  [[                       ]],
  [[                       ]],
  [[  @@@@@\ @@\      @@\  ]],
  [[   \__@@ |@@@\    @@@ |]],
  [[      @@ |@@@@\  @@@@ |]],
  [[      @@ |@@\@@\@@ @@ |]],
  [[@@\   @@ |@@ \@@@  @@ |]],
  [[@@ |  @@ |@@ |\@  /@@ |]],
  [[\@@@@@@  |@@ | \_/ @@ |]],
  [[ \______/ \__|     \__|]],
  [[                       ]],
  [[                       ]],
  [[                       ]],
}

dashboard.section.header.opts.hl = pick_color()

dashboard.section.buttons.val = {
  dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
  dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
  dashboard.button("p", "  Find project", ":Telescope projects <CR>"),
  dashboard.button("r", "  Recently used files", ":Telescope oldfiles <CR>"),
  dashboard.button("t", "  Find text", ":Telescope live_grep <CR>"),
  dashboard.button("c", "  Configuration", ":e ~/.config/nvim/init.lua <CR>"),
  dashboard.button("q", "  Quit Neovim", ":qa<CR>"),
}

dashboard.section.footer.val = footer()
dashboard.section.footer.opts.hl = "Constant"

require("alpha").setup(dashboard.opts)
