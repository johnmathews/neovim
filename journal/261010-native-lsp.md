# Native LSP Configuration

**Date:** 2026-10-10

## Problem

`lua/plugins/lsp.lua` configured every server through mason-lspconfig's `handlers`. mason-lspconfig v2 dropped that
option without an error, so none of it ran (F1). basedpyright ran at its default strictness, with 18 diagnostics on the
sample instead of 4. yamlls formatted although formatting was meant to be off. zsh got no server, and navic,
`<leader>li` and the cmp capabilities never applied. Meanwhile `automatic_enable` started all 21 servers in Mason,
including sqls on every SQL file and a stylua server in Lua buffers (F13).

## Decisions

- **Native `vim.lsp.config`, not lspconfig's `setup()`.** nvim-lspconfig's setup framework is deprecated, so porting
  the handlers would have traded silence for deprecation warnings. lspconfig now only provides `lsp/<server>.lua`
  defaults, and `after/lsp/<server>.lua` holds the overrides.
- **`LspAttach` instead of `on_attach`.** nvim-lspconfig's basedpyright config defines its own `on_attach`, which a
  per-server one would replace.
- **An explicit enable list** of 10 servers, with `automatic_enable = false`, so every machine starts the same set.
- **Not ported:** the ts_ls block and the custom `root_dir` functions (lspconfig's defaults cover them), and
  `python.analysis.diagnosticMode` (basedpyright never reads `python.*`).
- **`winborder` replaces the `open_floating_preview` override.** A probe that listed every floating window found no
  double border in hover (noice), Mason, Telescope or the diagnostic float. Lazy passes an explicit border. The cmp
  menu and the which-key popup pick up the rounded border, so they look different, but each has one border.
- `pcall(vim.loader.enable)` stays in `lsp.lua` until the startup unit moves it to the top of `init.lua`.

## Testing

Deleting this unit's xfail rows turned the gate red on both versions: 39 failures on 0.11.6 and 38 on 0.12.6, covering
settings, `<leader>li`, navic, capabilities, the zsh client, the stylua and sqls clients, and five deprecated-API scan
hits. New checks: `python:restart` (a restarted basedpyright keeps `basic`) and `startup:enabled` (the enabled set is
exactly the 10 servers). With the old `lsp.lua`, the latter listed 21. After the change both versions pass.

Two gate bugs surfaced on the way and were fixed in the engine. The capabilities check read `have[k] or nil`, which
turned every `false` leaf into a missing one. And the folds check now retries for 5 s, after one run on a heavily
loaded machine counted folds before the parse finished.
