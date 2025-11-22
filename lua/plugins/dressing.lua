-- Dressing: Improved UI for vim.ui.select and vim.ui.input

local ok, dressing = pcall(require, "dressing")
if not ok then
  return
end

local telescope_theme = {}
local has_telescope, themes = pcall(require, "telescope.themes")
if has_telescope then
  telescope_theme = themes.get_dropdown({
    layout_config = { width = 0.5 },
    previewer = false,
  })
end

dressing.setup({
  input = {
    border = "rounded",
    title_pos = "center",
    win_options = {
      winblend = 10,
      winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
    },
  },
  select = {
    backend = { "telescope", "builtin" },
    get_config = function(opts)
      if opts.kind == "codeaction" then
        return {
          backend = "builtin",
        }
      end
    end,
    builtin = {
      border = "rounded",
      relative = "editor",
      win_options = {
        winblend = 10,
      },
    },
    telescope = telescope_theme,
  },
})
