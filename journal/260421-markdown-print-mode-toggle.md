# Markdown Print Mode Toggle

**Date:** 2026-04-21

## Problem

Markdown files hard-wrapped at 121 characters look great in the terminal — lines
are a comfortable reading width and git diffs are clean because edits only touch
individual lines. But when you open the same file in an external app like Typora
or print it, the hard line breaks appear in the output. Instead of natural word
wrap that fills the page width, you get ragged short lines that end at column
121.

The root cause is prettier's `--prose-wrap=always` setting, which inserts literal
newline characters at the print width. External apps and printers treat these as
hard breaks rather than reflowing the text.

## Alternatives Considered

1. **Convert to PDF with pandoc before printing** — rejected because the user
   wants to keep files as `.md` for use in Typora and other markdown editors.

2. **Stop hard-wrapping entirely** — would fix printing but makes git diffs
   noisy (editing one word changes an entire paragraph) and the raw file is
   harder to read in a plain terminal.

3. **Semantic line breaks (one sentence per line)** — a middle ground, but
   Typora and printers still show the line breaks.

4. **Buffer-local toggle** — chosen approach. Keeps both modes available.
   Prettier can reformat in both directions (`always` re-wraps, `never`
   unwraps), so the toggle is fully reversible.

## Solution

Added a buffer-local toggle bound to `<leader>mp` that switches between:

| Aspect           | Terminal mode (default)     | Print mode                  |
| ---------------- | --------------------------- | --------------------------- |
| Prettier         | `--prose-wrap=always` (121) | `--prose-wrap=never`        |
| MD013 lint       | Enabled (warns >120 chars)  | Suppressed                  |
| Color column     | Shown at 121                | Hidden                      |
| Good for         | Editing, git diffs          | Typora, printing            |

On toggle, the buffer is immediately reformatted so the change is visible
instantly. A notification confirms the current mode.

## Files Changed

- **`lua/plugins/conform.lua`** — `prepend_args` for prettierd changed from a
  static table to a function. Reads `vim.b[ctx.buf].markdown_print_mode` to
  decide `--prose-wrap` value (`always` or `never`).

- **`lua/plugins/nvim-lint.lua`** — markdownlint args function now appends
  `--disable MD013` when print mode is active, suppressing line-length warnings
  on unwrapped paragraphs.

- **`ftplugin/markdown.vim`** — added the `<leader>mp` keymap in the Lua block.
  Flips `vim.b.markdown_print_mode`, toggles colorcolumn visibility, runs
  conform format synchronously, and re-runs the linter.

- **`docs/KEYMAPS.md`** — added the keymap to the Markdown section with a
  description of print mode.

- **`docs/MARKDOWN-FORMATTING.md`** — new doc covering the full markdown
  formatting pipeline (prettier, markdownlint, ftplugin settings) and the print
  mode toggle with implementation details and customization options.

## Workflow

1. Edit markdown normally in Neovim (terminal mode, hard wraps at 121 chars)
2. Press `<leader>mp` to toggle print mode (paragraphs unwrap to single lines)
3. Open in Typora or print — text flows and wraps naturally
4. Press `<leader>mp` to toggle back (paragraphs re-wrap at 121 chars)
5. Commit with clean, line-level git diffs

## Key Design Decisions

- **Buffer-local, not global:** Each buffer starts in terminal mode. Toggling
  one buffer doesn't affect others.
- **No config file changes:** `.prettierrc` and `.markdownlint.json` are
  unchanged. The toggle is entirely runtime, controlled by
  `vim.b.markdown_print_mode`.
- **Synchronous format on toggle:** Uses `async = false` so the reformat
  completes before returning control. The user sees the result immediately.
- **Toggle back before committing:** Print mode produces noisy diffs (whole
  paragraph lines). The default terminal mode should be used for commits.
