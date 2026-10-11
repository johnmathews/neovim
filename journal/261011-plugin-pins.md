# Plugin Pins and telescope-ui-select

**Date:** 2026-10-11

## Problem

On 0.12 the lockfile's aerial threw on every buffer once treesitter started everywhere (F4:
`aerial/backends/treesitter/helpers.lua:13: attempt to call method 'start'`) and outlined nothing. The lockfile held
`snacks.nvim` with no spec, and dressing.nvim, which the plan replaces (F18). Replaying CI in a fresh container also
showed that a fresh install rewrote lazy.nvim's own lockfile entry (F33).

## Decisions

- **aerial moves to `28fe6e8`**, upstream master past its 0.12 fix, which needs 0.12. Its
  `enabled = vim.fn.has("nvim-0.12") == 1` gate goes: `init.lua` refuses older Neovim anyway.
- **dressing.nvim becomes telescope-ui-select.** `vim.ui.select` opens a Telescope dropdown with dressing's old
  options (half width, no previewer), code actions included: dressing had sent those to its own window. The extension
  loads after `telescope.setup()`, because it reads its options from there. An `init` stub loads Telescope on the
  first `vim.ui.select` if nothing has loaded it yet, and falls back to the native select if the extension did not
  take over. `vim.ui.input` returns to native, which noice renders.
- **Lockfile, by hand** (plan §1.3): aerial's commit, `snacks.nvim` and `dressing.nvim` removed, telescope-ui-select
  added at its upstream head `6e51d7d`.
- **F33: the lazy.nvim bootstrap checks out the locked commit.** `plugins.lua` clones lazy.nvim with
  `--branch=stable` (v11.17.5); the lockfile pins `306a055` on `main`. lazy clones every other plugin at its locked
  commit, but records whatever commit it finds installed, so the first start of a fresh machine rewrote lazy.nvim's
  entry. The bootstrap now runs `git checkout <locked commit>` right after the clone.
- **The same mechanism in the smoke bootstrap.** Installing any missing plugin at startup makes lazy rewrite every
  entry from the installed commits, so a plugin installed at another commit (aerial in an existing home) was then
  "restored" to itself. `test/smoke/bootstrap.lua` now copies the repository's lockfile back and makes lazy re-read it
  before restoring. `scripts/sync-plugins` (W11b) has to do the same on a real machine.
- `xfail.lua` is now empty: the rest of its rows (F4, including the 0.12-only `zsh:diags` and `mundo:open`) are gone.

## Testing

New checks: aerial finds at least one symbol in the Python sample, and `gra` on its unused `import os` opens a
Telescope picker with dressing not loaded. The first draft of the second check called `vim.ui.select` directly and
passed on the old code, because dressing also uses Telescope for an ordinary select. Only code actions differed.
A synthetic code-action select then crashed telescope-ui-select, which reads the action's LSP context, so the check
now types a real `gra`. It also exposed a test-harness trap: Telescope enters insert mode by feeding `A`, which waits
in the typeahead of a headless Neovim, so closing the picker through its API left the `A` for the next case's keys
(`typescript:comment` got `gcoadded` appended to a line). The check now closes the picker with `<Esc><Esc>`, as a
user would.

Red (W12's code with the new checks): `python:aerial` "aerial found no symbols", `python:ui-select` "gra opened
filetype "DressingSelect"" and "dressing.nvim is loaded", and aerial's error in all 11 other cases. Green on 0.12.6:
`SMOKE PASS: 0 failed, 0 xfailed, 0 warnings`. A fresh data dir's first start keeps lazy.nvim at `306a055` and leaves
`lazy-lock.json` unchanged; on W12's code the same start leaves `85c7ff3` and rewrites the entry.
