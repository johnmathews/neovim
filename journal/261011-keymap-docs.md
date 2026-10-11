# Keymap Documentation Audit with a Drift Check

**Date:** 2026-10-11

## Problem

A sample of the keymap docs was 40% wrong (F20), and Stage A's audit listed the rest in issue #8: documented keys that
nothing maps, mapped keys nobody documented, and descriptions that were simply wrong. Issue #7 was a real bug: gitsigns'
`<Leader>shs` and `<Leader>shr` mapped to the text `Gitsigns: stage_hunk<CR>`, so pressing them typed into the buffer.

## Decisions

- **`docs/KEYMAPS.md` stays hand-written**, because `<Tab>tk` already gives the live searchable list, and the gate
  enforces it in both directions (`keymaps:*` in `test/smoke/cases.lua`):
  - every key in a `Key | Mode` table resolves with `maparg` in each mode the row lists. The Markdown section is checked
    in the Markdown buffer, the rest in the Python buffer, where the LSP, textobject and gitsigns maps are buffer-local.
    `<C-o>` is exempt: it is a Vim command, not a mapping. (A first version also exempted `gd` and `gD`, wrongly:
    `lua/mappings.lua` maps them to the LSP. W16 removed the exemption and the "built-in" wording);
  - every mapping with a `desc` under `<Leader>`, `<LocalLeader>`, `<Tab>`, `g` or an F-key appears in the doc (global
    maps plus each case buffer's own), except which-key's trigger maps and the bare leader key;
  - every label in `lua/plugins/whichkey.lua` names a real mapping;
  - `<Leader>shs`/`shr` are callbacks (#7).
- **#7 fixed**: Normal mode calls `stage_hunk`/`reset_hunk`; Visual mode passes the selected line range. Both have a desc
  now. Harpoon's lazy-load trigger listed `ga`, which nothing maps; it is `gm`, the add key.
- **Docs corrected** from the check's findings and #8: removed `gq`, `<Tab>dd`, lazydocker's `<Leader>d`, Leap's `gs` and
  Harpoon's `ga`; added `<Leader>f`, `<Tab>dq/dl/dc`, the Trouble keys, aerial's outline keys, minimap, `gm`, `gO`,
  `grx`, `]c`/`[c`, the Markdown helpers `<leader>mt/mb/mi/mc` and autolist's `<leader>cn/cp`, the ftplugin debug-print
  keys and nvim-tree's bookmark keys (the empty `### NvimTree` heading). Leap's `s`/`S` are described as they work.
  README's tour tables lost the nonexistent `<leader>su/sr/sp` and `<leader>ha/hh/h1-4`, `<Tab>gb` says what it does,
  `<C-w>H/J/K/L` move windows rather than rotate the layout, and the sign column descriptions match the config. LSP.md's
  duplicate key tables now point at KEYMAPS.md.
- The docs went through the same prettierd settings as format on save. TESTING.md's two widest tables were compacted
  again: prettier padded them to 1096 columns.

## Testing

The check was written first. Red, against the old docs and code: 30 failures, then 25 once markdown-only keys were
checked in a Markdown buffer: `keymaps:gitsigns` "<Leader>shs (n) maps to "Gitsigns: stage_hunk<CR>", want a gitsigns
call" (and `shr`, and both in Visual mode), six documented keys not mapped (`gq`, `<Tab>dd`, `<Leader>d`, `ga`, `gs`, and
`<leader>mp`, which only Markdown buffers map), and 14 described mappings not documented. Green:
`SMOKE PASS: 0 failed, 0 xfailed, 0 warnings`. Two new fixtures prove each direction can fail: `documented-unmapped` (a
doc row for `<leader>zq`) gives `keymaps:documented`, and `undocumented-map` (a described `<leader>zq` mapping) gives
`keymaps:undocumented`. gate-selftest now has 18 cases.

Seen while auditing, not changed: nvim-tree's bookmark keys `zc`, `zn`, `zl` and `zs` are global and replace Vim's fold
and sideways-scroll commands of the same names (F16's class of collision). The doc now says so.
