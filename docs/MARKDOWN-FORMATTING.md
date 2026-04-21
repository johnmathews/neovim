# Markdown Formatting

How markdown prose formatting works in this Neovim configuration, including the
print mode toggle for external viewers.

---

## Overview

Markdown files are formatted by **prettierd** (via conform.nvim) and linted by
**markdownlint** (via nvim-lint). By default, prettier hard-wraps prose at 121
characters. This keeps lines readable in the terminal and produces clean git
diffs where changes are isolated to individual lines.

However, hard-wrapped files print poorly from external apps like Typora, because
the hard line breaks appear in the printed output instead of natural word
wrapping. The **Markdown Print Mode** toggle solves this.

---

## Formatting Pipeline

### Prettier (prettierd)

Configured in `lua/plugins/conform.lua`. Key settings:

| Setting         | Terminal mode (default) | Print mode         |
| --------------- | ----------------------- | ------------------ |
| `--prose-wrap`  | `always`                | `never`            |
| `--print-width` | `121`                   | `121` (irrelevant) |
| `--parser`      | `markdown`              | `markdown`         |

- `--prose-wrap=always`: Prettier inserts hard line breaks at `--print-width`
  characters. Each paragraph becomes multiple lines.
- `--prose-wrap=never`: Prettier removes hard line breaks within paragraphs.
  Each paragraph becomes a single long line.

Formatting runs automatically on save (`format_on_save` in conform) and
manually with `<leader>cf`.

### Markdownlint

Configured in `lua/plugins/nvim-lint.lua`. Uses config from
`.markdownlint.json` (project-local or global fallback at
`~/.config/nvim/.markdownlint.json`).

Key rule: **MD013** (line length) warns when lines exceed 120 characters. This
rule is automatically suppressed when print mode is active, since unwrapped
paragraphs will always exceed the limit.

### Filetype Settings

Set in `ftplugin/markdown.vim`:

- `textwidth=120` — used by Vim's built-in `gq`/`gw` reformatting
- `colorcolumn=121` — visual guide line (hidden in print mode)
- `formatoptions` does NOT include `t` — Neovim does not auto-hard-wrap as you
  type
- `wrap` and `linebreak` are on — long lines display with visual soft wrapping
  at word boundaries

---

## Markdown Print Mode

### What It Does

A buffer-local toggle that switches how prettier formats prose in the current
markdown buffer. When toggled, the buffer is immediately reformatted so you see
the result instantly.

| Aspect       | Terminal mode (default)          | Print mode                      |
| ------------ | -------------------------------- | ------------------------------- |
| Prose wrap   | Hard wraps at 121 chars          | No hard wraps (1 line/paragraph)|
| MD013 lint   | Enabled (warns >120 chars)       | Suppressed                      |
| Color column | Shown at 121                     | Hidden                          |
| Git diffs    | Clean (line-level changes)       | Noisy (paragraph-level changes) |
| Printing     | Ragged short lines               | Natural word wrap               |
| Typora       | Shows hard breaks                | Flows naturally                 |

### Keymap

`<leader>mp` — Toggle Markdown Print Mode (normal mode, markdown buffers only)

A notification shows the current state after toggling.

### How to Use

**Preparing a file for printing or external viewing:**

1. Open the markdown file in Neovim
2. Press `<leader>mp` to switch to print mode
3. The buffer is reformatted — paragraphs become single long lines
4. Open the file in Typora, or print it — text wraps naturally
5. Press `<leader>mp` to switch back to terminal mode
6. The buffer is reformatted — paragraphs are re-wrapped at 121 chars
7. Save and commit with clean, line-level diffs

**Important:** Toggle back to terminal mode before committing. Hard-wrapped
files produce much cleaner git diffs because editing a word only changes one
line, not an entire paragraph.

### Scope

The toggle is **buffer-local**. Opening a second markdown file starts in
terminal mode regardless of the state of other buffers. The toggle does not
persist across Neovim sessions — every buffer starts in terminal mode.

No global config files (`.prettierrc`, `.markdownlint.json`) are modified by the
toggle. Everything is controlled by the buffer-local variable
`vim.b.markdown_print_mode`.

---

## Implementation Details

Three files coordinate the toggle:

### 1. `lua/plugins/conform.lua`

The `prepend_args` for prettierd is a function (not a static table). It reads
`vim.b[ctx.buf].markdown_print_mode` on every format invocation to decide the
`--prose-wrap` value:

```lua
prettierd = {
  prepend_args = function(_self, ctx)
    local prose_wrap = vim.b[ctx.buf].markdown_print_mode and "never" or "always"
    return {
      "--parser=markdown",
      "--prose-wrap=" .. prose_wrap,
      "--print-width=121",
    }
  end,
},
```

### 2. `lua/plugins/nvim-lint.lua`

The markdownlint `args` function appends `--disable MD013` when print mode is
active:

```lua
if vim.b.markdown_print_mode then
  table.insert(args, "--disable")
  table.insert(args, "MD013")
end
```

### 3. `ftplugin/markdown.vim`

The toggle keymap is defined in the Lua block at the end of the file. It:

1. Flips `vim.b.markdown_print_mode` (boolean)
2. Sets or clears `vim.wo.colorcolumn`
3. Shows a notification via `vim.notify`
4. Runs `conform.format()` synchronously to reformat the buffer
5. Runs `lint.try_lint()` to refresh diagnostics

---

## Customization

### Change the wrap width

Edit the `--print-width` value in `lua/plugins/conform.lua`. Also update
`textwidth` and `colorcolumn` in `ftplugin/markdown.vim` and the MD013
`line_length` in `.markdownlint.json` to match.

### Disable format-on-save for markdown

If you don't want markdown auto-formatted on save (e.g., you want full control
over when wrapping happens), add a check in the `format_on_save` function in
`lua/plugins/conform.lua`:

```lua
format_on_save = function(bufnr)
  if vim.bo[bufnr].filetype == "markdown" then return nil end
  -- ... existing logic
end,
```

### Use a different print width for print mode

If you want print mode to use a specific width rather than no wrapping, change
the toggle logic to use `--prose-wrap=always` with a different `--print-width`
instead of `--prose-wrap=never`.
