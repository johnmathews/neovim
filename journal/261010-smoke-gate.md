# Buffer-Opening Smoke Gate

**Date:** 2026-10-10

## Problem

Every existing gate was green on a broken config. The quality-gate load test printed `OK` after an `error()` in
`lua/options.lua`, because headless Neovim keeps going and exits 0. `test/test_lsp.sh` passed when a server name
appeared anywhere in its output, and it ran bare `nvim` against the real data directory. Meanwhile no per-server LSP
setting applied, zsh and markdown lint were dead, and on Neovim 0.12 every buffer threw tracebacks. The 0.12 upgrade
needs a gate that can see those failures before anything else changes.

## Decisions

- **Assert on runtime state, not output text.** The gate opens one sample file per daily language and reads the
  attached clients, their settings, diagnostics grouped by owner, the treesitter highlighter, maps, and LSP request
  results.
- **Isolated environment.** `SMOKE_HOME` holds its own XDG directories, and the working tree is copied in on every
  run, because lazy rewrites `lazy-lock.json` and fixtures must break a copy. Seeding clones `lazy/` and `mason/`
  copy-on-write, so a run never touches `~/.local/share/nvim`.
- **Fire `UIEnter` headless.** Headless Neovim never fires it, so lazy never fires `VeryLazy`, and noice, nvim-notify,
  lualine and navic would never load under test. Probes showed this on both 0.11.6 and 0.12.6.
- **Read messages from three places.** With noice attached, `:messages` is empty on 0.11.6 and errors reach only
  stderr. On 0.12.6 they reach `:messages` and not stderr. The gate reads `:messages`, stderr and noice's history,
  and every line must be explained by a recorded notify, a recorded deprecation, or `allow.lua`.
- **Serve `vim.notify` through the `vim` metatable.** Re-wrapping on lazy events leaves gaps between a replacement and
  the next event. The metatable sees every assignment, so the recorder survives nvim-notify and noice.
- **Nvim deprecations are recorded at the call.** `vim.deprecate` echoes only the first hard deprecation per session
  (`_truncated_echo_once`), so counting messages would miss all but one. The wrapper records every call and the first
  caller outside the runtime.
- **Strict, precise xfail.** Each entry matches a check ID plus a message substring, so a fixture that breaks the same
  check differently still fails. Stale entries and entries made redundant by another entry fail the run, which makes
  "deleting any one entry turns the run red" true by construction.

## Surprises

- 0.12's default client capabilities already send `insertReplaceSupport`, so the first cmp-capabilities check passed on
  0.12 for the wrong reason. The strict xfail list caught it as a stale entry. The check now compares each client's
  capabilities against `cmp_nvim_lsp.default_capabilities()` leaf by leaf.
- The yaml sample's deliberate syntax errors leave treesitter no fold ranges with either foldexpr, so yaml has no fold
  expectation.
- project.nvim's `buf_get_clients` deprecation never fires in the gate: the copy has a `.git`, so pattern detection
  wins before the LSP fallback runs.
- `--bootstrap` runs in two Nvim processes. A restore swaps plugin code on disk that the restoring process has already
  loaded, so parsers and tools install from a fresh process.
- A seeded `--bootstrap` on 0.12.6 reproduces F8 through the gate's lockfile check: the restore rewrote 4 entries.
  nvim-treesitter and textobjects flipped from `main` to `master`, snacks.nvim was dropped, and winresizer stayed at
  `9bd559a` although its lock commit `299076f` exists in the clone. The first three are already planned for the
  cutover. The winresizer entry is new and needs a look at the same time.

## Result

On the seeded Mac environment the gate is red without `xfail.lua` on both versions. 0.11.6 names F1, F5, F6, F13, F25
and F30. 0.12.6 adds F3, F4 and F15 (`init.lua:110`). With the seeded `xfail.lua` both pass. `scripts/gate-selftest`
catches all nine fixtures on both versions.
