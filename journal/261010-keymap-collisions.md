# Keymap Collisions with Built-in Defaults

**Date:** 2026-10-10

## Problem

`lua/mappings.lua` mapped `gr` and `gi` globally to Telescope pickers (F16). A global `gr` makes every `gr*` default
(`gra`, `grn`, `grr`, `gri`, `grt`) wait for `timeoutlen` before it can run, and `gi` hid Vim's "insert where insert
mode last stopped". `<leader>cl` was claimed twice: "Run lint" in `lua/plugins/nvim-lint.lua`, and the Trouble LSP panel
in the lazy.nvim spec.

## Decisions

- `grr` and `gri` take the Telescope pickers, overriding the defaults of the same name. `gr` and `gi` are unmapped.
- `<leader>cl` stays "Run lint", as AGENTS.md documents. The Trouble panel moves to `<leader>cL`.
- README's LSP table also listed `<leader>rn`, `<leader>ca` and `<leader>q`, which no code maps. They became the
  defaults that do exist (`grn`, `gra`), and the `<leader>q` row went. Its `[d`/`]d` rows stay: those keys are
  treesitter textobject jumps until the treesitter cutover (W12) removes them and the built-in diagnostic jumps return.

## Testing

New checks `keymaps:defaults` (lua case) and `python:grr`. On the old config both versions failed six times: `gr` and
`gi` mapped, `grr` and `gri` still the built-ins, `<leader>cL` unmapped, and `grr` opened the quickfix list. The first
`python:grr` draft expected a Telescope picker and failed on the new config too. calculate_sum has two references, and
Telescope drops the one on the cursor line and jumps to the other instead of opening a picker. The check now expects the
jump to line 10; against the old mappings it still fails ("grr left filetype qf").
