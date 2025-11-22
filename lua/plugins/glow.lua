-- https://github.com/ellisonleao/glow.nvim
-- Beautiful markdown rendering in Neovim using Glow

local glow_exe = vim.fn.exepath("glow")
if glow_exe == "" then
  glow_exe = nil
  vim.notify(
    "[glow.nvim] glow binary not found on PATH. Install it via `brew install glow` or see README.md.",
    vim.log.levels.WARN
  )
end

require("glow").setup({
  glow_path = glow_exe,
  -- Glow style to use (dark, light, or path to custom JSON)
  style = "dark",
  -- Disable pager so navigation stays in Neovim
  pager = false,
  -- Width of the glow window (default 100)
  width = 120,
  -- Height ratio of the glow window to the editor (default 0.8 = 80%)
  height_ratio = 0.85,
  -- Floating window border style
  border = "rounded", -- none, single, double, rounded, solid, shadow
})
