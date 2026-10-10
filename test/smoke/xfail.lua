-- Known failures of the smoke gate, each tied to a finding in the 0.12 upgrade
-- evaluation (journal/261010-nvim-012-evaluation-and-plan.md). A failure that
-- matches an entry is reported as XFAIL instead of FAIL. The list is strict: an
-- entry that no longer fails turns the run red, so the unit that fixes a finding
-- must delete its entries in the same commit. The list must be empty before the
-- 0.12 cutover.
--
-- Entry fields:
--   id       check ID from the report, or "*:<check>" for that check in any case
--   match    plain substring the failure message must contain
--   finding  finding ID, and the unit planned to fix it
--   nvim     only on these versions ("0.12" matches 0.12.x); omit for every version
return {
  -- F1: mason-lspconfig v2 ignores `handlers`, so no per-server setting, on_attach,
  -- navic, <leader>li or cmp capability applies (W3)
  { id = "python:settings", match = "typeCheckingMode=nil", finding = "F1 (W3)" },
  { id = "python:diags", match = "lsp:basedpyright=18, want 4", finding = "F1 (W3)" },
  { id = "lua:settings", match = "Lua.runtime.version=nil", finding = "F1 (W3)" },
  { id = "yaml:settings", match = "yaml.format.enable=true", finding = "F1 (W3)" },
  { id = "zsh:clients", match = "LSP clients {}, want exactly {bashls}", finding = "F1 (W3)" },
  { id = "*:capabilities", match = "did not receive the cmp-nvim-lsp completion capabilities", finding = "F1 (W3)" },
  { id = "*:keymaps", match = "<leader>li (inlay hints) is not buffer-mapped", finding = "F1 (W3)" },
  { id = "*:navic", match = "nvim-navic is not attached", finding = "F1 (W3)" },

  -- F13: automatic_enable starts every Mason server, and ruff reports twice (W3, W4)
  { id = "lua:clients", match = "LSP clients {lua_ls,stylua}", finding = "F13 (W3)" },
  { id = "sql:clients", match = "LSP clients {sqls}", finding = "F13 (W3)" },
  { id = "python:diags", match = "ruff=4, want 0", finding = "F13 (W4)" },
  { id = "python:duplicates", match = "from lsp:ruff and ruff", finding = "F13 (W4)" },

  -- F5: the shellcheck override aliases the shared linter and asks for the wrong JSON (W4)
  { id = "zsh:diags", match = "shellcheck_zsh=0, want 3", finding = "F5 (W4)" },

  -- F6: markdownlint `args` is a function, so every markdown lint run errors (W4)
  { id = "markdown:diags", match = "markdownlint=0, want 3", finding = "F6 (W4)" },
  { id = "markdown:notify", match = "t: expected table, got function", finding = "F6 (W4)" },

  -- F25: conform lists an unknown formatter "lsp" for yaml (W4)
  { id = "tools:formatters", match = "conform formatter lsp (yaml)", finding = "F25 (W4)" },

  -- F30: zsh gets no treesitter parser (W12)
  { id = "zsh:treesitter", match = "highlighter not active (want parser bash)", finding = "F30 (W12)" },
  { id = "zsh:textobjects", match = "is not mapped in mode", finding = "F30 (W12)" },

  -- F15: deprecated API in the config's own code (W5)
  {
    id = "startup:deprecated",
    match = "vim.lsp.set_log_level() (use vim.lsp.log.set_level()) called from config init.lua:110",
    finding = "F15 (W5)",
    nvim = "0.12",
  },

  -- F15 and F25: deprecated or private APIs in the config's own files (the text scan)
  { id = "scan:deprecated", match = 'lua/plugins/lsp.lua: require("lspconfig")', finding = "F15 (W3)" },
  { id = "scan:deprecated", match = "lua/plugins/lsp.lua: lspconfig.util", finding = "F15 (W3)" },
  { id = "scan:deprecated", match = "lua/plugins/lsp.lua: open_floating_preview override", finding = "F15 (W3)" },
  { id = "scan:deprecated", match = "lua/plugins/lsp.lua: find_git_ancestor", finding = "F15 (W3)" },
  { id = "scan:deprecated", match = "lua/plugins/conform.lua: vim.loop", finding = "F15 (W4)" },
  { id = "scan:deprecated", match = "lua/plugins/nvim-lint.lua: vim.loop", finding = "F15 (W4)" },
  { id = "scan:deprecated", match = "lua/plugins/conform.lua: conform lsp_fallback", finding = "F25 (W4)" },
  { id = "scan:deprecated", match = "ftplugin/markdown.vim: conform lsp_fallback", finding = "F25 (W4)" },
  { id = "scan:deprecated", match = "init.lua: vim.lsp.set_log_level", finding = "F15 (W5)" },
  { id = "scan:deprecated", match = "lua/plugins.lua: vim.loop", finding = "F15 (W5)" },
  { id = "scan:deprecated", match = "lua/functions.lua: vim.loop", finding = "F15 (W5)" },
  { id = "scan:deprecated", match = "lua/functions.lua: nvim_out_write", finding = "F15 (W5)" },
  { id = "scan:deprecated", match = "lua/plugins/luasnip.lua: _make_floating_popup_size", finding = "F15 (W5)" },

  -- F3: the installed nvim-treesitter master branch breaks on 0.12 (W12)
  { id = "*:folds", match = "no folds computed", finding = "F3 (W12)", nvim = "0.12" },
  { id = "python:textobjects", match = "vaf from line 12 selected 12-12", finding = "F3 (W12)", nvim = "0.12" },
  {
    id = "*:messages",
    match = "treesitter.lua:197: attempt to call method 'range'",
    finding = "F3 (W12)",
    nvim = "0.12",
  },

  -- F4: the installed aerial and rainbow-delimiters throw on every buffer on 0.12 (W13)
  {
    id = "*:messages",
    match = "rainbow-delimiters/lib.lua:200: attempt to index local 'parser'",
    finding = "F4 (W13)",
    nvim = "0.12",
  },
  {
    id = "*:messages",
    match = "aerial/backends/treesitter/helpers.lua:13: attempt to call method 'start'",
    finding = "F4 (W13)",
    nvim = "0.12",
  },
  {
    id = "markdown:messages",
    match = "aerial/backends/treesitter/extensions.lua:115: attempt to call method 'type'",
    finding = "F4 (W13)",
    nvim = "0.12",
  },
  { id = "zsh:open", match = "rainbow-delimiters/lib.lua:200", finding = "F4 (W13)", nvim = "0.12" },
}
