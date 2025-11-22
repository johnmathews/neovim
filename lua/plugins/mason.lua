-- Mason: Package manager for LSP servers, formatters, and linters
local ok_mason, mason = pcall(require, "mason")
if not ok_mason then
  return
end

mason.setup({
  ui = {
    border = "rounded",
    check_outdated_packages_on_open = false,
  },
})

-- Ensure non-LSP tools are installed (formatters/linters/dap/etc.)
local ok_mti, mti = pcall(require, "mason-tool-installer")
if ok_mti then
  mti.setup({
    ensure_installed = {
      -- formatters
      "stylua", -- Lua
      "shfmt", -- Shell
      "prettierd", -- Markdown
      "biome", -- JS/TS/JSON
      "ruff", -- Python
      -- linters
      "eslint_d",
      "shellcheck",
      "mypy",
      "markdownlint",
    },
    auto_update = false,
    run_on_start = false, -- Don't check tools on startup (use :Mason to check manually)
  })
end
