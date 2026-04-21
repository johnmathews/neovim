# Markdown Print Mode Toggle

**Date:** 2026-04-21

## Problem

Markdown files hard-wrapped at 80-121 characters look great in the terminal but
print poorly from external apps like Typora. The hard line breaks appear in the
printed output instead of natural word wrapping.

## Solution

Added a buffer-local toggle (`<leader>mp`) that switches between two modes:

| Aspect           | Terminal mode (default)     | Print mode                  |
| ---------------- | --------------------------- | --------------------------- |
| Prettier         | `--prose-wrap=always` (121) | `--prose-wrap=never`        |
| MD013 lint       | Enabled (warns >120 chars)  | Suppressed                  |
| Color column     | Shown at 121                | Hidden                      |
| Good for         | Editing, git diffs          | Typora, printing            |

The toggle is fully reversible - prettier can reflow in both directions.

## Files Changed

- `lua/plugins/conform.lua` - `prepend_args` is now a function that reads
  `vim.b.markdown_print_mode` to decide `prose-wrap` value
- `lua/plugins/nvim-lint.lua` - markdownlint args function appends
  `--disable MD013` when print mode is active
- `ftplugin/markdown.vim` - added the `<leader>mp` keymap and toggle logic

## Workflow

1. Edit markdown normally (terminal mode, hard wraps)
2. `<leader>mp` to toggle print mode (unwraps paragraphs)
3. Open in Typora or print - text flows naturally
4. `<leader>mp` to toggle back (re-wraps paragraphs)
5. Commit with clean, hard-wrapped diffs
