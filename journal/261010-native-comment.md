# Native Commenting and Plugin Removals

**Date:** 2026-10-10

## Problem

Four plugins were archived or unmaintained (F18): Comment.nvim (last commit 2024-06), glow.nvim, vim-numbers (last
push 2021) and lualine-lsp-progress. Neovim's built-in `gc` covers Comment.nvim. vim-numbers mapped visual and
operator-pending `an`/`in`, which on 0.12 hide the built-in treesitter node selection (F16). glow.nvim's
`ftplugin/markdown.vim` mapping was a global `<Leader>p`, set from a filetype plugin.

## Decisions

- **Native `gc`, same keys.** `gci` (invert each selected line) moved to `lua/mappings.lua` with a `desc`. `gco` and
  `gcO` are re-implemented as "open a line, comment it, enter insert mode". `gcA` is dropped, as approved.
- **nvim-ts-context-commentstring stays**, as planned: `lazy = true`, with the wiki's `vim.filetype.get_option`
  override in `init`, so the plugin loads on the first commentstring lookup. A control probe found it is probably
  redundant now. With its lookup disabled, `gcc` on a JSX line still gave `{/* ... */}`, because native `gc` first
  reads `bo.commentstring` metadata from treesitter captures, and nvim-treesitter's jsx query sets it. It is a
  candidate to remove once the treesitter `main` cutover confirms its queries carry the same metadata.
- The Dockerfile commentstring override went with Comment.nvim; the runtime ftplugin already sets `# %s`.
- Lockfile entries were removed by hand (plan section 1.3). On the Mac, `:Lazy clean` then
  `git checkout -- lazy-lock.json`. `brew uninstall glow` is optional.

## Testing

New checks: `comment:builtin` (gcc is the built-in "Toggle comment line", Comment.nvim not loaded, visual `an` is 0.12's
"Select parent (outer) node" or unmapped on 0.11), `typescript:comment` (`gcc`, `gco`, `gcO` on a TS line),
`tsx:comment` on a new `test/typescript/test_sample.tsx`, and `markdown:glow`. On the old config they failed on
both versions: gcc was "Comment toggle current line", Comment.nvim was loaded, `:Glow` existed, and on 0.12.6 visual
`an` had vim-numbers' mapping. The tsx and `gco`/`gcO` checks passed with Comment.nvim too, which is the point: the
behaviour is kept. After the change both versions pass.
