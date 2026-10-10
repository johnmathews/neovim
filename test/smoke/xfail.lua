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

  -- F15: deprecated or private APIs in the config's own files (the text scan)
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
  -- with that error zsh gets no lint diagnostics on 0.12; F5 itself is fixed (0.11 passes)
  { id = "zsh:diags", match = "shellcheck_zsh=0, want 3", finding = "F4 (W13)", nvim = "0.12" },
}
