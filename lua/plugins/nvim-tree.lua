-- NvimTree: File explorer with git integration and custom keybindings

-- following options are the default
-- each of these are documented in `:help nvim-tree.OPTION_NAME`
local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

local api_status_ok, nvim_tree_api = pcall(require, "nvim-tree.api")
if not api_status_ok then
  return
end

-- Dynamic width configuration
local width_opts = {
  enabled = true,
  min_width = 30,
  max_width = 60,
  padding = 2,
}

-- Calculate optimal width based on visible, expanded nodes
local function calculate_optimal_width()
  local tree_api = require("nvim-tree.api")
  local nodes = tree_api.tree.get_nodes()

  if not nodes or not nodes.nodes or #nodes.nodes == 0 then
    return width_opts.min_width
  end

  local max_width = 0
  local Iterator = require("nvim-tree.iterators.node-iterator")

  Iterator.builder(nodes.nodes)
    :applier(function(node, _)
      if not node.group_next then
        -- Calculate depth by traversing parents
        local depth = 0
        local parent = node.parent
        while parent do
          depth = depth + 1
          parent = parent.parent
        end
        -- Width = indent(2 chars per level) + icon + name + padding
        local width = (depth * 2) + 3 + vim.fn.strdisplaywidth(node.name) + width_opts.padding
        max_width = math.max(max_width, width)
      end
    end)
    :recursor(function(node)
      -- Only recurse into open directories with children
      return node.open and #node.nodes > 0 and node.nodes or nil
    end)
    :iterate()

  return math.max(width_opts.min_width, math.min(max_width, width_opts.max_width))
end

-- Debounced resize handler
local width_calculation_timer = nil
local function schedule_width_recalc()
  if width_calculation_timer then
    vim.fn.timer_stop(width_calculation_timer)
  end
  width_calculation_timer = vim.fn.timer_start(150, function()
    local view = require("nvim-tree.view")
    local tree_winid = view.get_winnr()
    if tree_winid and vim.api.nvim_win_is_valid(tree_winid) then
      local ok, new_width = pcall(calculate_optimal_width)
      if ok then
        pcall(vim.api.nvim_win_set_width, tree_winid, new_width)
      end
    end
  end)
end

local function on_attach(bufnr)
  local api = require("nvim-tree.api")

  api.config.mappings.default_on_attach(bufnr)

  -- Remove Tab mapping to allow global Tab-based keybinds (Telescope, etc.)
  pcall(vim.keymap.del, "n", "<Tab>", { buffer = bufnr })

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
  vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))

  if width_opts.enabled then
    vim.schedule(schedule_width_recalc)
    vim.api.nvim_create_autocmd({ "CursorMoved" }, {
      buffer = bufnr,
      callback = schedule_width_recalc,
      desc = "Recalc nvim-tree width on cursor movement",
    })
  end
end

vim.keymap.set(
  "n",
  "zc",
  require("nvim-tree.api").marks.clear,
  { noremap = true, silent = true, desc = "Clear nvim-tree bookmarks" }
)
vim.keymap.set(
  "n",
  "zn",
  require("nvim-tree.api").marks.navigate.next,
  { noremap = true, silent = true, desc = "Next nvim-tree bookmark" }
)
vim.keymap.set(
  "n",
  "zp",
  require("nvim-tree.api").marks.navigate.prev,
  { noremap = true, silent = true, desc = "Previous nvim-tree bookmark" }
)
vim.keymap.set(
  "n",
  "zl",
  require("nvim-tree.api").marks.navigate.select,
  { noremap = true, silent = true, desc = "List nvim-tree bookmarks" }
)
vim.keymap.set(
  "n",
  "zs",
  require("nvim-tree.api").marks.navigate.select,
  { noremap = true, silent = true, desc = "Select nvim-tree bookmark" }
)

nvim_tree.setup({
  on_attach = on_attach,
  actions = {
    open_file = {
      resize_window = false,
    },
  },
  -- https://github.com/ahmedkhalf/project.nvim
  renderer = {
    root_folder_label = false,
    highlight_opened_files = "all",
    icons = {
      webdev_colors = true,
      glyphs = {
        default = "",
        symlink = "",
        git = {
          unstaged = "",
          staged = "S",
          unmerged = "",
          renamed = "➜",
          deleted = "",
          untracked = "U",
          ignored = "◌",
        },
        folder = {
          default = "",
          open = "",
          empty = "",
          empty_open = "",
          symlink = "",
        },
      },
    },
  },

  respect_buf_cwd = true,
  disable_netrw = true,
  hijack_netrw = true,
  hijack_cursor = true,
  hijack_directories = {
    enable = true,
    auto_open = true,
  },
  update_cwd = false,
  diagnostics = {
    enable = false,
    icons = {
      hint = "H", --""",
      info = "I", --""",
      warning = "W", --"",
      error = "E", --""",
    },
  },
  update_focused_file = {
    enable = false,
    update_cwd = false,
    ignore_list = {},
  },
  filters = {
    dotfiles = false,
    custom = {},
  },
  git = {
    enable = true,
    ignore = true,
    timeout = 500,
  },
  view = {
    width = 30,
    side = "left",
    number = false,
    relativenumber = false,
  },
  trash = {
    cmd = "trash",
    require_confirm = true,
  },
})

-- this might conflict with session manager plugin
local function open_nvim_tree()
  nvim_tree_api.tree.toggle({ focus = false, find_file = true })
end
vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
