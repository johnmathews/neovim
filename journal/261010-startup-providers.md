# Startup, Providers and Deprecated Calls

**Date:** 2026-10-10

## Problem

Startup took about 400 ms against a 150 ms target (F11). `docs/PERFORMANCE.md` blamed lazy.nvim, but most of the time
went to two shell-outs in `init.lua` on every launch: `poetry env info -p` to choose a Python host, with a fallback to a
hard-coded pyenv 3.10.12 path, and `command -v neovim-node-host`, with a fallback that put an nvm node v20 on `PATH`
(F22). `<leader>x` ran `:!xdg-open %`, which does not exist on macOS. The config also called `vim.lsp.set_log_level`,
`vim.loop`, `nvim_out_write` and the private `_make_floating_popup_size` (F15).

## Decisions

- **The Python host is uv's `pynvim` tool**, looked up the way uv does: `$UV_TOOL_DIR`, else `$XDG_DATA_HOME/uv/tools`,
  else `~/.local/share/uv/tools`, then `pynvim/bin/python`. It is set only when that file exists; otherwise Neovim
  auto-detects. No subprocess. Each machine needs `uv tool install pynvim` once.
- **The Node provider is disabled.** No remote plugin needs it.
- **`vim.loader.enable()` is the first line of `init.lua`**, so the module cache covers every require, not only those
  after `lua/plugins/lsp.lua`.
- **The choice popup sizes itself** from `strdisplaywidth` and the line count.
- **`t.scope(name)` in the smoke engine.** The Mundo check needs a real Python host, so it runs only where uv's pynvim
  exists. Its xfail entry for 0.12 would be stale on every other run, so the check marks its own scope as run, and
  entries are judged only for scopes that ran.

## Testing

Deleting this unit's xfail rows and adding the new checks turned the gate red: 16 failures on 0.11.6 and 14 on 0.12.6.
They were 7 deprecated-API scan hits, `python:provider` (the pyenv path, and the node provider enabled),
`markdown:open` ("`<leader>x` called vim.ui.open(nil)", with "command not found: xdg-open"), and on 0.12.6
`startup:deprecated` for `set_log_level`. With pynvim installed into a sandbox `UV_TOOL_DIR`, the old config chose the
pyenv path over it. After the change both versions pass, and `:checkhealth vim.provider` reports the uv interpreter
(Python 3.13.11, pynvim 0.6.0) and "Disabled (loaded_node_provider=0)".

`:MundoToggle` opens on 0.11.6. On 0.12.6 it fails in the Mundo preview buffer with the same rainbow-delimiters error
(F4) that breaks zsh, so it carries a 0.12-only xfail entry for the plugin-pin unit.

An interleaved A/B (10 runs each, isolated data directories, load average 5.6 to 6.2) gave medians of 422 ms before and
139 ms after on 0.11.6, and 398 ms and 138 ms on 0.12.6. `health-check --isolated` measured 129 ms.

A probe expanded a two-choice snippet: the choice popup is 20x2 on both versions, the longest choice by the line count.

basedpyright occasionally reports no diagnostics within the gate's 30 s wait on 0.12.6 (about 3 of 13 runs, never on
0.11.6). A probe opening the same buffer 6 times got all 4 within about 2 s each time, and 8 repeated gate runs all
passed, so the cause is not found yet.
