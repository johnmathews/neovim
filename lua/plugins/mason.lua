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
local tools = {
  -- formatters
  "stylua", -- Lua
  "shfmt", -- Shell
  "prettierd", -- Markdown
  "biome", -- JS/TS/JSON
  "ruff", -- Python
  "sqlfluff", -- SQL
  "yamlfmt", -- YAML
  "jq", -- JSON
  -- linters
  "eslint_d",
  "mypy",
  "markdownlint",
  "shellcheck", -- run by bashls (sh, bash, zsh)
  "jsonlint",
}

local ok_mti, mti = pcall(require, "mason-tool-installer")
if ok_mti then
  mti.setup({
    ensure_installed = tools,
    auto_update = false,
    run_on_start = true,
  })
end

-- scripts/sync-plugins and the smoke bootstrap check these are installed
return { tools = tools }
