-- Lualine: Fast and customizable statusline with project-aware filepath display
local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
  return
end

local function symbols_outline()
  local symbols
  local exclude = {
    ["terminal"] = true,
    ["toggleterm"] = true,
    ["prompt"] = true,
    ["NvimTree"] = true,
    ["help"] = true,
    ["TelescopePrompt"] = true,
  }
  if exclude[vim.bo.filetype] then
    symbols = ""
  elseif not vim.api.nvim_win_get_config(0).zindex then
    -- Winbar symbols disabled (lspsaga removed)
    symbols = nil
  end
  return symbols
end

local function Current_col()
  ---@diagnostic disable-next-line: deprecated
  local unpack_fn = table.unpack or unpack -- 5.1 compatibility
  local _, column = unpack_fn(vim.api.nvim_win_get_cursor(0))
  return "c" .. column + 1
end

local function Row_max_row()
  ---@diagnostic disable-next-line: deprecated
  local unpack_fn = table.unpack or unpack -- 5.1 compatibility
  local row, _ = unpack_fn(vim.api.nvim_win_get_cursor(0))
  local max_row = vim.api.nvim_buf_line_count(0)
  return "r" .. row .. "/" .. max_row
end

local function find_project_root(current_dir)
  local root_markers = { ".git", ".hg", ".svn", "package.json", ".root" } -- Add more root markers as needed
  local path = current_dir
  -- Check if we're at the root '/' or the home directory to avoid infinite loops
  while path ~= "/" and path ~= vim.fn.expand("~") do
    for _, marker in ipairs(root_markers) do
      if
        vim.fn.isdirectory(vim.fn.expand(path .. "/" .. marker)) == 1
        or vim.fn.filereadable(vim.fn.expand(path .. "/" .. marker)) == 1
      then
        return path
      end
    end
    path = vim.fn.fnamemodify(path, ":h")
  end
  return nil -- No project root found
end

local function show_filepath()
  local current_file = vim.fn.expand("%:p")
  local project_root = find_project_root(vim.fn.expand("%:p:h"))
  if project_root then
    -- Get the project root directory name
    local project_root_name = vim.fn.fnamemodify(project_root, ":t")
    -- Construct the relative path including the project root name at the beginning
    local relative_path =
      vim.fn.fnamemodify(current_file, ":."):gsub(vim.pesc(vim.fn.fnamemodify(project_root, ":h")) .. "/", "")
    return project_root_name .. "/" .. relative_path .. " "
  else
    return current_file
  end
end

-- to make the statusline at the bottom of the buffer, add the config to the "tabline" section.
-- to make it appear at the bottom, add the config to the "sections" part of the setup config.
lualine.setup({
  options = {
    icons_enabled = true,
    globalstatus = true, -- true for laststatus=3, false by default
    theme = "ayu_mirage",
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = { "alpha", "dashboard", "NvimTree", "Outline", "toggleterm" },
    always_divide_middle = true,
  },
  sections = {
    lualine_a = {
      {
        "searchcount",
        maxcount = 999,
        timout = 500,
        color = { fg = "white", bg = "black", gui = "bold" },
        padding = { left = 2, right = 2 },
        separator = { left = "", right = "" },
      },
      { Row_max_row, color = { bg = "#04FBD1", gui = "bold" }, separator = { left = "", right = "" } },
      { Current_col, { "mode", color = { bg = "#04FBD1", gui = "bold" } } },
    },
    lualine_b = {
      {
        "branch",
        padding = { left = 3, right = 3 },
        color = { fg = "#000000", bg = "#FFFB7C", gui = "bold" },
        separator = { left = "", right = "" },
      },
      {
        "diff",
        padding = { left = 3, right = 3 },
        color = { fg = "#000000", bg = "#36454F", gui = "bold" },
        separator = { left = "", right = "" },
      },
    },
    lualine_c = {
      {
        show_filepath,
        padding = { left = 1, right = 0 },
        color = { fg = "#000000", bg = "#55F954", gui = "bold" },
        separator = { left = "", right = "" },
      },
      { "diagnostics", padding = { left = 2, right = 2 } },
      { symbols_outline, padding = { left = 2, right = 2 } },
      -- { "lsp_progress" },
    },
    lualine_x = {},
    lualine_y = { "encoding", "fileformat", "filetype" },
    lualine_z = {},
  },
  extensions = {
    "fzf",
    "lazy",
    "man",
    "mason",
    "mundo",
    "nerdtree",
    "nvim-dap-ui",
    "nvim-tree",
    "quickfix",
    "symbols-outline",
    "toggleterm",
  },
})
