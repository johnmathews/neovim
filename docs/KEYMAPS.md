# Neovim Keymaps Reference

Complete reference of all custom keybindings in this Neovim configuration.

- **Leader key:** `<Space>`
- **Local leader key:** `\`

The smoke gate checks this file against the running config (`keymaps:*` in `test/smoke/cases.lua`): every key in a
`Key | Mode` table must be mapped in the modes listed, and every mapping with a description under `<Leader>`,
`<LocalLeader>`, `<Tab>`, `g` or an F-key must appear here. Keys under [Markdown](#markdown) are checked in a Markdown
buffer, the rest in a Python buffer. `<Tab>tk` lists every live mapping.

---

## Table of Contents

- [Core Editing](#core-editing)
- [Window & Buffer Management](#window--buffer-management)
- [File Navigation (Telescope)](#file-navigation-telescope)
- [Git Operations](#git-operations)
- [LSP & Code Actions](#lsp--code-actions)
- [Formatting & Linting](#formatting--linting)
- [Terminal](#terminal)
- [Harpoon (Quick Navigation)](#harpoon-quick-navigation)
- [Treesitter](#treesitter)
- [Markdown](#markdown)
- [Miscellaneous](#miscellaneous)
- [Plugin-Specific Keymaps](#plugin-specific-keymaps)

---

## Core Editing

| Key       | Mode          | Description                              |
| --------- | ------------- | ---------------------------------------- |
| `kj`      | Insert        | Exit insert mode (alternative to ESC)    |
| `<C-h>`   | Insert        | Jump back one word                       |
| `<C-e>`   | Insert        | Delete the next word                     |
| `j` / `k` | Normal        | Move down/up (respects wrapped lines)    |
| `o`       | Normal        | Insert line below (stays in normal mode) |
| `O`       | Normal        | Insert line above (stays in normal mode) |
| `;`       | Normal/Visual | Enter command mode (swapped with `:`)    |
| `:`       | Normal/Visual | Repeat last f/F/t/T (swapped with `;`)   |

---

## Window & Buffer Management

| Key              | Mode   | Description                                                     |
| ---------------- | ------ | --------------------------------------------------------------- |
| `<C-H>`          | Normal | Move to left window                                             |
| `<C-J>`          | Normal | Move to bottom window                                           |
| `<C-K>`          | Normal | Move to top window                                              |
| `<C-L>`          | Normal | Move to right window                                            |
| `<Leader>n`      | Normal | Toggle focus between buffer and nvim-tree                       |
| `<Leader>f`      | Normal | Toggle focus between buffer and nvim-tree (same as `<Leader>n`) |
| `<LocalLeader>n` | Normal | Toggle nvim-tree visibility (show/hide)                         |
| `<Tab>ww`        | Normal | Write all buffers                                               |
| `<Tab>qq`        | Normal | Quit Vim                                                        |
| `qq`             | Normal | Quit current buffer (vanilla: go to previous, delete current)   |
| `wq`             | Normal | Save and quit buffer (smartQ)                                   |
| `QE`             | Normal | Wipe empty buffers (smartQ)                                     |
| `<C-Q>`          | Normal | BDelete menu (choose buffer to delete)                          |
| `<Tab>qo`        | Normal | Close all other buffers                                         |

---

## File Navigation (Telescope)

### Buffer & File Finding

| Key      | Mode   | Description                                   |
| -------- | ------ | --------------------------------------------- |
| `<Tab>f` | Normal | Find files (git-aware, fallback to all files) |
| `<Tab>a` | Normal | Find ALL files (ignores .gitignore)           |
| `<Tab>r` | Normal | Recent buffers (MRU sort)                     |
| `<Tab>o` | Normal | Old files (recently opened)                   |
| `<Tab>i` | Normal | Current buffer fuzzy find                     |

### Search

| Key             | Mode   | Description                            |
| --------------- | ------ | -------------------------------------- |
| `<Tab>s`        | Normal | Live grep (ripgrep search in project)  |
| `<Tab>x`        | Normal | Live grep with args (advanced ripgrep) |
| `<Tab>y`        | Normal | Fuzzy-find text in PWD                 |
| `` ` ``         | Normal | Search (alternative to `/`)            |
| <code>``</code> | Normal | Clear search highlight                 |

### Git

| Key       | Mode   | Description                               |
| --------- | ------ | ----------------------------------------- |
| `<Tab>gc` | Normal | Git commits (search)                      |
| `<Tab>gb` | Normal | Git buffer commits (current file history) |
| `<Tab>gr` | Normal | Git branches                              |
| `<Tab>gs` | Normal | Git status                                |

### Telescope Utilities

| Key      | Mode   | Description                              |
| -------- | ------ | ---------------------------------------- |
| `<Tab>p` | Normal | Sessions: search (`:AutoSession search`) |
| `<Tab>h` | Normal | Help tags (search Vim help)              |
| `<Tab>z` | Normal | Resume last Telescope picker             |
| `<Tab>b` | Normal | LSP workspace symbols                    |

### Telescope Meta

| Key       | Mode   | Description                      |
| --------- | ------ | -------------------------------- |
| `<Tab>tk` | Normal | Keymaps (searchable keymap list) |
| `<Tab>tc` | Normal | Command history                  |
| `<Tab>ts` | Normal | Search history                   |
| `<Tab>ta` | Normal | Autocommands                     |
| `<Tab>tr` | Normal | Registers                        |
| `<Tab>to` | Normal | Vim options                      |
| `<Tab>tt` | Normal | Treesitter symbols               |

---

## Git Operations

GitSigns keys are buffer-local: they exist in buffers inside a git repository, tracked or not.

| Key           | Mode            | Description                                                           |
| ------------- | --------------- | --------------------------------------------------------------------- |
| `]c` / `[c`   | Normal          | GitSigns: Next / previous hunk (diff mode: the built-in change jumps) |
| `<Leader>shs` | Normal/Visual   | GitSigns: Stage hunk (Visual: the selected lines)                     |
| `<Leader>shr` | Normal/Visual   | GitSigns: Reset hunk (Visual: the selected lines)                     |
| `<Leader>sS`  | Normal          | GitSigns: Stage buffer                                                |
| `<Leader>shu` | Normal          | GitSigns: Unstage hunk                                                |
| `<Leader>shR` | Normal          | GitSigns: Reset buffer                                                |
| `<Leader>shp` | Normal          | GitSigns: Preview hunk                                                |
| `<Leader>sb`  | Normal          | GitSigns: Blame current line                                          |
| `<Leader>sB`  | Normal          | GitSigns: Blame with preview                                          |
| `<Leader>sd`  | Normal          | GitSigns: Diff current buffer                                         |
| `<Leader>sD`  | Normal          | GitSigns: Diff (advanced)                                             |
| `<Leader>st`  | Normal          | GitSigns: Toggle deleted lines                                        |
| `ih`          | Visual, Pending | GitSigns: Select hunk (text object)                                   |
| `gG`          | Normal          | Quietly push all changes to remote (async)                            |

---

## LSP & Code Actions

### Built-in LSP Navigation (Neovim 0.12)

| Key          | Mode   | Description                              |
| ------------ | ------ | ---------------------------------------- |
| `gd`         | Normal | Go to definition (built-in LSP)          |
| `gD`         | Normal | Go to declaration (built-in LSP)         |
| `gra`        | Normal | Code actions in a Telescope dropdown     |
| `grn`        | Normal | Rename symbol (workspace-wide)           |
| `grt`        | Normal | Go to type definition                    |
| `grx`        | Normal | Run the code lens on the current line    |
| `gO`         | Normal | Document symbols (Markdown: the outline) |
| `K`          | Normal | Hover documentation                      |
| `<leader>li` | Normal | Toggle inlay hints                       |
| `<F4>`       | Normal | Restart LSP server                       |

### Telescope-based LSP Navigation

`grr` and `gri` replace Neovim's default LSP keys of the same name. `gr` and `gi` themselves are not mapped, so the other
`gr*` defaults work and `gi` is Vim's "insert where insert mode last stopped".

| Key   | Mode   | Description                             |
| ----- | ------ | --------------------------------------- |
| `grr` | Normal | Show references (Telescope picker)      |
| `gri` | Normal | Go to implementation (Telescope picker) |

### LSP with Telescope (Advanced Searching)

| Key              | Mode   | Description                         |
| ---------------- | ------ | ----------------------------------- |
| `<LocalLeader>r` | Normal | Telescope: Find all references      |
| `<LocalLeader>d` | Normal | Telescope: Find all definitions     |
| `<LocalLeader>i` | Normal | Telescope: Find all implementations |
| `<Tab>b`         | Normal | Telescope: Workspace symbols        |

### Diagnostics & Configuration

| Key              | Mode   | Description                                      |
| ---------------- | ------ | ------------------------------------------------ |
| `<LocalLeader>s` | Normal | Cycle diagnostics display modes                  |
| `<LocalLeader>t` | Normal | Show active LSP/formatters/linters for buffer    |
| `<Tab>dq`        | Normal | All diagnostics into the quickfix list           |
| `<Tab>dl`        | Normal | This buffer's diagnostics into the location list |
| `<Tab>dc`        | Normal | Clear the quickfix list                          |

### Trouble

| Key          | Mode   | Description                                    |
| ------------ | ------ | ---------------------------------------------- |
| `<leader>xx` | Normal | Diagnostics (Trouble)                          |
| `<leader>xX` | Normal | This buffer's diagnostics (Trouble)            |
| `<leader>cs` | Normal | Symbols (Trouble)                              |
| `<leader>cL` | Normal | LSP definitions, references and more (Trouble) |
| `<leader>xL` | Normal | Location list (Trouble)                        |
| `<leader>xQ` | Normal | Quickfix list (Trouble)                        |

### Outline (aerial)

| Key         | Mode   | Description                                         |
| ----------- | ------ | --------------------------------------------------- |
| `<leader>o` | Normal | Toggle the symbol outline                           |
| `{` / `}`   | Normal | Previous / next symbol (buffers aerial attaches to) |

---

## Formatting & Linting

| Key              | Mode          | Description                                      |
| ---------------- | ------------- | ------------------------------------------------ |
| `<leader>cf`     | Normal/Visual | Format file or selection (conform.nvim)          |
| `<leader>cl`     | Normal        | Run linter manually (nvim-lint)                  |
| `<LocalLeader>t` | Normal        | Show active LSP servers, formatters, and linters |

`<leader>cL` (Trouble's LSP panel) is under [Trouble](#trouble).

---

## Terminal

| Key         | Mode   | Description     |
| ----------- | ------ | --------------- |
| `<Tab>\`    | Normal | Toggle terminal |
| `<Leader>g` | Normal | Open lazygit    |

---

## Harpoon (Quick Navigation)

| Key      | Mode   | Description                |
| -------- | ------ | -------------------------- |
| `gm`     | Normal | Harpoon: Add current file  |
| `gh`     | Normal | Harpoon: Toggle quick menu |
| `gn`     | Normal | Harpoon: Next file         |
| `gp`     | Normal | Harpoon: Previous file     |
| `<Tab>1` | Normal | Harpoon: Jump to file 1    |
| `<Tab>2` | Normal | Harpoon: Jump to file 2    |
| `<Tab>3` | Normal | Harpoon: Jump to file 3    |
| `<Tab>4` | Normal | Harpoon: Jump to file 4    |
| `<Tab>5` | Normal | Harpoon: Jump to file 5    |

---

## Treesitter

### Text Objects & Navigation

Buffer-local, and only in buffers whose language has a textobjects query (Python, Lua, JavaScript, TypeScript, Bash and
others). Elsewhere a filetype plugin's own `]]` and `[[` stay, for example SQL's jump to the next `BEGIN`.

| Key  | Mode                    | Description                     |
| ---- | ----------------------- | ------------------------------- |
| `af` | Visual, Pending         | Select outer function           |
| `if` | Visual, Pending         | Select inner function           |
| `ac` | Visual, Pending         | Select outer class              |
| `ic` | Visual, Pending         | Select inner class              |
| `]m` | Normal, Visual, Pending | Jump to next function start     |
| `[m` | Normal, Visual, Pending | Jump to previous function start |
| `]M` | Normal, Visual, Pending | Jump to next function end       |
| `[M` | Normal, Visual, Pending | Jump to previous function end   |
| `]]` | Normal, Visual, Pending | Jump to next class start        |
| `[[` | Normal, Visual, Pending | Jump to previous class start    |
| `][` | Normal, Visual, Pending | Jump to next class end          |
| `[]` | Normal, Visual, Pending | Jump to previous class end      |

`]d`, `[d`, `]s` and `]z` are Neovim's built-in diagnostic, spell and fold jumps, and `]o` is vim-unimpaired's.

### Text Object Operations

| Key           | Mode   | Description             |
| ------------- | ------ | ----------------------- |
| `<leader>tsa` | Normal | Swap next parameter     |
| `<leader>tsA` | Normal | Swap previous parameter |

### Treesitter Tools

| Key          | Mode   | Description                                    |
| ------------ | ------ | ---------------------------------------------- |
| `<leader>tp` | Normal | Inspect the syntax tree (`:InspectTree`)       |
| `<leader>tc` | Normal | Highlight groups under the cursor (`:Inspect`) |

---

## Markdown

| Key          | Mode          | Description                                          |
| ------------ | ------------- | ---------------------------------------------------- |
| `<leader>mp` | Normal        | Toggle Markdown Print Mode (see below)               |
| `<leader>mt` | Normal/Visual | Title Case the line (or selection)                   |
| `<leader>mb` | Normal/Visual | Bold the word (or selection)                         |
| `<leader>mi` | Normal/Visual | Italicise the word (or selection)                    |
| `<leader>mc` | Normal/Visual | Inline code for the word (or selection)              |
| `<leader>cn` | Normal        | Next list type for this list (autolist, dot-repeats) |
| `<leader>cp` | Normal        | Previous list type for this list (autolist)          |

autolist also maps `<Tab>` and `<S-Tab>` in Insert mode (indent and outdent a list item) and adds a renumbering step to
`>>` and `<<`. It loads with the first Markdown, text or TeX buffer.

### Markdown Print Mode (`<leader>mp`)

Toggles between two formatting modes for the current buffer:

- **Terminal mode** (default): Prettier hard-wraps prose at 121 characters. Good for editing in Neovim with clean git
  diffs.
- **Print mode**: Prettier removes hard wraps (one paragraph per line). Good for opening in Typora or printing, where the
  app handles word wrap.

When toggled, the buffer is immediately reformatted. The color column is hidden in print mode. MD013 (line length) lint
warnings are suppressed in print mode.

Toggle back to terminal mode before committing to keep diffs clean.

---

## Miscellaneous

### Function Keys

| Key    | Mode   | Description                  |
| ------ | ------ | ---------------------------- |
| `<F1>` | Normal | Refresh buffer               |
| `<F2>` | Normal | Toggle line wrap             |
| `<F3>` | Normal | Toggle relative line numbers |
| `<F4>` | Normal | LSP: Restart                 |
| `<F5>` | Normal | Toggle spell checker         |

### Config Management

| Key          | Mode   | Description                        |
| ------------ | ------ | ---------------------------------- |
| `<leader>ve` | Normal | Edit init.lua (vimrc)              |
| `<leader>vr` | Normal | Reload vimrc                       |
| `<leader>vf` | Normal | Edit ftplugin for current filetype |

### Utilities

| Key               | Mode   | Description                             |
| ----------------- | ------ | --------------------------------------- |
| `wc`              | Normal | Get highlight group under cursor        |
| `<leader>x`       | Normal | Open current file in default app        |
| `<leader>X`       | Normal | Open current file in Typora (macOS)     |
| `<C-p>`           | Normal | Jump forward in jump list               |
| `<localleader>fs` | Normal | Search sessions (`:AutoSession search`) |
| `<leader>mm`      | Normal | Toggle the minimap (mini.map)           |
| `<leader>mr`      | Normal | Refresh the minimap                     |

### Debug Print Helpers (filetype plugins)

Buffer-local, from `ftplugin/`. Each opens a line below with a print of the word under the cursor (Normal) or of the
selection (Visual). `<localleader>p` exists for Python, Lua, JavaScript and TypeScript; `o` and `l` only for Python.

| Key              | Mode          | Description                                 |
| ---------------- | ------------- | ------------------------------------------- |
| `<localleader>p` | Normal/Visual | Print it (`print(f"--- {x = }")` in Python) |
| `<localleader>o` | Normal/Visual | Print it across lines (Python)              |
| `<localleader>l` | Normal/Visual | Log it with `logger.info` (Python)          |

### Jump List

| Key     | Mode   | Description                          |
| ------- | ------ | ------------------------------------ |
| `<C-o>` | Normal | Jump backward (Vim default)          |
| `<C-p>` | Normal | Jump forward (remapped from `<C-i>`) |

---

## Plugin-Specific Keymaps

### Commenting (native `gc`)

Neovim's built-in commenting. The comment style follows the treesitter node under the cursor, so JSX in a `.tsx` file
gets `{/* ... */}` and the TypeScript around it `// ...`.

| Key          | Mode   | Description                                    |
| ------------ | ------ | ---------------------------------------------- |
| `gcc`        | Normal | Toggle comment on current line                 |
| `gc{motion}` | Normal | Toggle comment over a motion                   |
| `gc`         | Visual | Toggle comment on selection                    |
| `gci`        | Visual | Invert comment on each selected line           |
| `gco`        | Normal | Add a comment line below and enter insert mode |
| `gcO`        | Normal | Add a comment line above and enter insert mode |

### Leap.nvim (Motion)

| Key | Mode                    | Description                                  |
| --- | ----------------------- | -------------------------------------------- |
| `s` | Normal, Visual, Pending | Leap: jump to a labelled spot in this window |
| `S` | Normal                  | Leap to a labelled spot in another window    |

### NvimTree

Bookmarks of nvim-tree, mapped globally. They take over Vim's `zc` (close fold), `zn` (no folds), `zl` and `zs` (scroll
sideways).

| Key  | Mode   | Description                 |
| ---- | ------ | --------------------------- |
| `zc` | Normal | Clear nvim-tree bookmarks   |
| `zn` | Normal | Next nvim-tree bookmark     |
| `zp` | Normal | Previous nvim-tree bookmark |
| `zl` | Normal | List nvim-tree bookmarks    |
| `zs` | Normal | Select nvim-tree bookmark   |

## Tips

- **Discover keymaps:** Press `<Tab>tk` to search all keymaps via Telescope
- **Which-key:** Press `<Space>` and wait to see available leader key mappings
- **Help:** Use `:h <topic>` or `<Tab>h` (Telescope help) to search documentation

---

## Keymap Patterns

- **`<Tab>` prefix:** File/buffer navigation, Telescope commands
- **`<Leader>` (Space):** General commands, config management
- **`<Leader>s` prefix:** Git/source control (GitSigns)
- **`g` prefix:** Go-to commands, Harpoon, Git push
- **`<F1-F12>`:** Quick toggles and utilities
- **`<LocalLeader>` (\):** LSP-specific commands

---

**Last updated:** 2026-10-11 (checked against the running config by the smoke gate's `keymaps:*` checks)  
**Neovim version:** v0.12.6
