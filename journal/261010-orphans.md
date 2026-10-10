# Orphan and Inert Config

**Date:** 2026-10-10

## Problem

Several pieces of config did nothing or did harm (F25, F27). fidget.nvim showed LSP progress next to noice, and the
installed 2023 fidget called the deprecated `vim.lsp.get_active_clients`. lsp_signature.nvim was installed but never
set up. Eight files under `lua/` were never required, including `lua/plugins/filetype.lua`, whose `uv.lock` mapping
Neovim already has. lualine's symbols component returned `nil`, which the statusline printed as "nil".

Planning also noticed, outside the evaluation, that `lua/options.lua` set `filetype = "on"` as an option. `'filetype'` is
buffer-local, so it tags the buffer that is current at startup: the empty buffer a bare `nvim` opens.

## Decisions

- Remove fidget (noice owns LSP progress) and lsp_signature, with their lockfile entries removed by hand. On the Mac,
  `:Lazy clean` then `git checkout -- lazy-lock.json`.
- Delete the eight unused files.
- `symbols = ""` instead of `nil`.
- Drop `filetype = "on"`. Filetype detection is on by default in Neovim. `syntax = "on"` stays; it is outside this
  unit.

## Testing

New `inert_checks` in the lua case. On the old config, `:enew` already had no filetype, so the first check passed; a
probe found the bug on the startup buffer instead (`buf 1 ft=on`, "Last set from …/init.lua", both versions). The check
now also fails on any buffer with filetype `on`. Red on both versions: "buffer 1 ("") has filetype 'on'", the
statusline " … 󰌶 4    nil    lua    utf-8 ", and "fidget.nvim is loaded". After the change both versions pass. The
progress check asserts noice's `lsp.progress.enabled`; it does not look at the rendered mini view. lsp_signature never
ran, so its removal has nothing to observe. luacheck now checks 69 files instead of 77.
