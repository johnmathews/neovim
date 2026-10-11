# Treesitter Main-Branch Cutover

**Date:** 2026-10-11

## Problem

nvim-treesitter's `master` branch breaks on Neovim 0.12 (F2, F3), and its `main` branch is a rewrite with no modules:
no `configs.setup`, no `ensure_installed`, no textobjects keymap tables. `lazy-lock.json` already pinned `main`
commits, so a machine bootstrapped from the lockfile (CI, a fresh VM) got `main` code under a `master` config. There
`pcall(require, "nvim-treesitter.configs")` failed and the file returned silently: no highlighting, folds or text
objects anywhere, and no message to say so. This Mac still ran `master` from its November plugin snapshot. zsh never
had a parser (F30).

## Decisions

- **`lua/plugins/treesitter.lua` follows the planning prototype**, which was tested on 0.12.6. It installs the missing
  parsers from an exported list (the old 14 plus bash, sql, vim and vimdoc), registers the bash parser for zsh, and
  starts treesitter in one `FileType` autocmd: highlighting, native `vim.treesitter.foldexpr()` folds for python, yaml
  and lua, nvim-treesitter's `indentexpr` except yaml and markdown, and textobject maps.
- **Textobject maps are buffer-local and only where a textobjects query exists.** Runtime ftplugins map `]]` and `]m`
  themselves. Buffer-local maps beat them in python and markdown, and SQL, which has no textobjects query, keeps its
  ftplugin's `]]` (next `BEGIN`).
- **Only missing parsers are installed**, and only when the tree-sitter CLI is on PATH; otherwise one WARN names them.
  A machine with every parser installed starts no install task and needs no CLI to start.
- **A loud guard instead of the silent return.** With `master` still checked out, the file raises an ERROR that names
  `scripts/sync-plugins`.
- **`init.lua` refuses Neovim below 0.12** with one ERROR and returns before lazy.nvim loads. A single lockfile cannot
  hold both treesitter branches (F8), and an old Neovim that got as far as lazy would install plugins and rewrite the
  lockfile. `scripts/smoke --expect-guard` checks this on 0.11.6: exactly that ERROR, lazy never loaded, the lockfile
  untouched.
- **Removed:** the `master` keys (`autopairs`, `fold`, `rainbow`, `query_linter`, `lsp_interop`), the `tsx`
  `filetype_to_parsername` override, `<leader>df`/`dF` (`gd` covers it), the `]o ]s ]z ]d [d` moves (Vim's spell and
  fold jumps, 0.12's diagnostic jumps and vim-unimpaired's `]o` come back), `lua/autocmd.lua`'s
  `nvim_treesitter#foldexpr()` autocmd, `vim.g.skip_ts_context_commentstring_module` (it only told the `master`
  module system to skip a module), and the comments that described `master`, as the plan approved.
- `<leader>tc` and `<leader>tp` now run the built-in `:Inspect` and `:InspectTree`. `scripts/versions.env` requires
  Neovim 0.12.0 and tree-sitter 0.26.1, so `health-check` fails without either.
- The smoke bootstrap lost its `master` path: a parser list missing from `lua/plugins/treesitter.lua` is now a failure.

## Testing

New gate checks, written before the code: `]m` buffer-local with a callback in Python, Python's `foldexpr` is
`v:lua.vim.treesitter.foldexpr()`, markdown's `foldmethod` is `manual`, SQL's `]]` is the ftplugin's `search()`,
`<leader>tc`/`tp` run `:Inspect`/`:InspectTree`, `<leader>df`/`dF` are unmapped, `]o ]s ]z` have no buffer-local map,
and `]d`/`[d` are the built-in diagnostic jumps. W12's xfail rows (F3, F30) were deleted first.

On 0.12.6 with a home bootstrapped from the lockfile, the red run had 51 failures: no highlighter in any language,
`af`/`if` unmapped everywhere, `vaf` selecting 12-12, folds from the `master` foldexpr. The first draft of the
removed-keys check also failed on `]o`, which turned out to be vim-unimpaired's option-toggle prefix, not a leftover
treesitter map; the check now looks for buffer-local maps only. After the change every W12 check passes: each case
reports its parser (`zsh … ts=bash`, `sql … ts=sql`), and the only failures left are W13's stale rainbow rows.
`scripts/smoke --expect-guard` passes on 0.11.6 and fails on 0.12.6 (no guard fired, lazy loaded, lockfile rewritten).

Native `gc` still comments JSX as `{/* … */}`: `main`'s `queries/jsx/highlights.scm` keeps the `bo.commentstring`
metadata, so nvim-ts-context-commentstring now looks redundant. Removing it is a question for the owner, not part of
this unit.
