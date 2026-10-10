# Neovim 0.12 Upgrade: Evaluation and Plan

**Date:** 2026-10-10

## Why

The config ran on Neovim 0.11.6 on macOS and was to move to 0.12.6 on macOS and Linux. An evaluation ran the config in
isolated sandboxes on both versions before any change. It found that the upgrade breaks a small, well-defined set of
things, and that more was already broken on 0.11.6 without anything noticing.

## Findings

30 findings, F1 to F30, graded by how they were verified. Stage A found one more, F31.

- **Critical.** mason-lspconfig v2 silently ignored the `handlers` that held every per-server setting (F1). A lockfile
  install strips all treesitter config (F2). nvim-treesitter `master` breaks on 0.12 (F3). aerial and
  rainbow-delimiters throw on every buffer on 0.12 (F4).
- **High.** zsh lint returned nothing and markdown lint errored on every run (F5, F6). No gate opened a buffer, so none
  of this was caught (F7). Lockfile drift makes the upgrade order matter (F8). The `main` branch needs the tree-sitter
  CLI on every machine (F9). There was no Linux path to 0.12 (F10) and no CI (F12). Startup took about 400 ms against a
  150 ms target, mostly a `poetry` subprocess (F11).
- **Medium.** Every Mason server started (F13), project.nvim leaned on a removed API (F14), deprecated calls (F15),
  keys shadowing built-in defaults (F16), `main` migration hazards (F17), unmaintained plugins (F18), docs describing
  the broken mechanisms (F19, F20), hooks that did not guard worktrees (F21), host-specific paths (F22).
- **Low.** Plugin deprecations (F23), dead treesitter keys (F24), orphan files (F25), doc-set conventions (F26), the
  statusline "nil" (F27), two claims to verify (F28 noice's "written" route, F29 `vim.NIL`), zsh without treesitter
  (F30).
- **Found in Stage A.** On 0.12, basedpyright switched to pull diagnostics and about one buffer in four opened without
  them (F31). Fixed by keeping it on push.

## Decisions

- **Modernise where natural.** Keep lazy.nvim and nvim-cmp. Use native `vim.lsp.config`, native `gc`, `vim.fs.root`
  and `vim.ui.open` where they are now the documented path.
- **SQL:** dadbod only, no SQL LSP; sqlfluff formats on `<leader>cf`. **Python lint:** the ruff LSP server owns it.
- **Plugins replaced or removed:** project.nvim, Comment.nvim, dressing.nvim; glow.nvim, vim-numbers,
  lualine-lsp-progress; and the inert fidget and lsp_signature.
- **Linux:** Ubuntu 24.04+, Debian 13+ and Codespaces, with a CI job.
- **Two stages.** Stage A (W1-W10, W18) works on both 0.11.6 and 0.12.6 and merges early. Stage B (W11-W17, W19) is the
  0.12 cutover in one PR: the treesitter `main` branch, plugin pins, Linux bootstrap, CI, keymap audit and per-machine
  cutover.
- **Lockfile:** `:Lazy restore` only. Units that add or remove plugins edit `lazy-lock.json` by hand until every
  machine has converged.
- All keymap changes in the plan were approved: `grr`/`gri` instead of `gr`/`gi`, `:AutoSession search` on `<Tab>p`,
  native `gc`, `<leader>x` through `vim.ui.open`, and the Trouble panel on `<leader>cL`.

## Unit order

The gate comes first, because every later unit is proven against it: W1 the buffer-opening smoke gate, W2 gates that
fail closed, then the riskiest changes, W3 native LSP and W4 lint and format ownership. W5 to W9 are the quick wins
(startup, project root, commenting, keymaps, orphans), and W10 is this doc hygiene. W18 verifies F28. Each fix unit
deletes its rows from `test/smoke/xfail.lua`, which must be empty before the cutover.

## Where the detail lives

The full evaluation report and plan were run artifacts and are not tracked. The decisions above, the per-unit journal
entries dated 2026-10-10, `docs/CHANGELOG.md` and `docs/TESTING.md` carry what they established.
