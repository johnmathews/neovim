# Neovim Keymaps Reference

Complete reference of all custom keybindings in this Neovim configuration.

- \*Leader Key:\*\* `<Space>`
- Local Leader Key:\*\* `\`

--

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
- [Miscellaneous](#miscellaneous)

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

| Key              | Mode   | Description                                                   |
| ---------------- | ------ | ------------------------------------------------------------- |
| `<C-H>`          | Normal | Move to left window                                           |
| `<C-J>`          | Normal | Move to bottom window                                         |
| `<C-K>`          | Normal | Move to top window                                            |
| `<C-L>`          | Normal | Move to right window                                          |
| `<Leader>n`      | Normal | Toggle focus between buffer and nvim-tree                     |
| `<LocalLeader>n` | Normal | Toggle nvim-tree visibility (show/hide)                       |
| `<Tab>ww`        | Normal | Write all buffers                                             |
| `<Tab>qq`        | Normal | Quit Vim                                                      |
| `qq`             | Normal | Quit current buffer (vanilla: go to previous, delete current) |
| `wq`             | Normal | Save and quit buffer (smartQ)                                 |
| `QE`             | Normal | Wipe empty buffers (smartQ)                                   |
| `<C-Q>`          | Normal | BDelete menu (choose buffer to delete)                        |
| `<Tab>qo`        | Normal | Close all other buffers                                       |
| `gq`             | Normal | Toggle QuickFix window                                        |

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

| Key      | Mode   | Description                            |
| -------- | ------ | -------------------------------------- |
| `<Tab>s` | Normal | Live grep (ripgrep search in project)  |
| `<Tab>x` | Normal | Live grep with args (advanced ripgrep) |
| `<Tab>y` | Normal | Fuzzy-find text in PWD                 |
| `` ` ``  | Normal | Search (alternative to `/`)            |
| ` ` ``   | Normal | Clear search highlight                 |

### Git

| Key       | Mode   | Description                               |
| --------- | ------ | ----------------------------------------- |
| `<Tab>gc` | Normal | Git commits (search)                      |
| `<Tab>gb` | Normal | Git buffer commits (current file history) |
| `<Tab>gr` | Normal | Git branches                              |
| `<Tab>gs` | Normal | Git status                                |

### Telescope Utilities

| Key      | Mode   | Description                        |
| -------- | ------ | ---------------------------------- |
| `<Tab>p` | Normal | Projects (switch between projects) |
| `<Tab>h` | Normal | Help tags (search Vim help)        |
| `<Tab>z` | Normal | Resume last Telescope picker       |
| `<Tab>b` | Normal | LSP workspace symbols              |

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

| Key           | Mode          | Description                                |
| ------------- | ------------- | ------------------------------------------ |
| `<Leader>shs` | Normal/Visual | GitSigns: Stage hunk                       |
| `<Leader>shr` | Normal/Visual | GitSigns: Reset hunk                       |
| `<Leader>sS`  | Normal        | GitSigns: Stage buffer                     |
| `<Leader>shu` | Normal        | GitSigns: Unstage hunk                     |
| `<Leader>shR` | Normal        | GitSigns: Reset buffer                     |
| `<Leader>shp` | Normal        | GitSigns: Preview hunk                     |
| `<Leader>sb`  | Normal        | GitSigns: Blame current line               |
| `<Leader>sB`  | Normal        | GitSigns: Blame with preview               |
| `<Leader>sd`  | Normal        | GitSigns: Diff current buffer              |
| `<Leader>sD`  | Normal        | GitSigns: Diff (advanced)                  |
| `<Leader>st`  | Normal        | GitSigns: Toggle deleted lines             |
| `ih`          | Operator      | GitSigns: Select hunk (text object)        |
| `gG`          | Normal        | Quietly push all changes to remote (async) |

---

## LSP & Code Actions

### Built-in LSP Navigation (Neovim v0.11+)

| Key          | Mode   | Description                              |
| ------------ | ------ | ---------------------------------------- |
| `gd`         | Normal | Go to definition (built-in LSP)          |
| `gD`         | Normal | Go to declaration (built-in LSP)         |
| `gra`        | Normal | Code actions (quick fix, refactor, etc.) |
| `grn`        | Normal | Rename symbol (workspace-wide)           |
| `grt`        | Normal | Go to type definition                    |
| `K`          | Normal | Hover documentation                      |
| `<leader>li` | Normal | Toggle inlay hints                       |
| `<F4>`       | Normal | Restart LSP server                       |

### Telescope-based LSP Navigation

| Key  | Mode   | Description                             |
| ---- | ------ | --------------------------------------- |
| `gr` | Normal | Show references (Telescope picker)      |
| `gi` | Normal | Go to implementation (Telescope picker) |

### LSP with Telescope (Advanced Searching)

| Key              | Mode   | Description                         |
| ---------------- | ------ | ----------------------------------- |
| `<LocalLeader>r` | Normal | Telescope: Find all references      |
| `<LocalLeader>d` | Normal | Telescope: Find all definitions     |
| `<LocalLeader>i` | Normal | Telescope: Find all implementations |
| `<Tab>b`         | Normal | Telescope: Workspace symbols        |

### Diagnostics & Configuration

| Key              | Mode   | Description                                   |
| ---------------- | ------ | --------------------------------------------- |
| `<LocalLeader>s` | Normal | Cycle diagnostics display modes               |
| `<LocalLeader>t` | Normal | Show active LSP/formatters/linters for buffer |
| `<Tab>dd`        | Normal | Cycle diagnostics display modes               |

---

## Formatting & Linting

| Key              | Mode          | Description                                      |
| ---------------- | ------------- | ------------------------------------------------ |
| `<leader>cf`     | Normal/Visual | Format file or selection (conform.nvim)          |
| `<leader>cl`     | Normal        | Run linter manually (nvim-lint)                  |
| `<LocalLeader>t` | Normal        | Show active LSP servers, formatters, and linters |

---

## Terminal

| Key         | Mode   | Description     |
| ----------- | ------ | --------------- |
| `<Tab>\`    | Normal | Toggle terminal |
| `<Leader>g` | Normal | Open lazygit    |
| `<Leader>d` | Normal | Open lazydocker |

---

## Harpoon (Quick Navigation)

| Key      | Mode   | Description                |
| -------- | ------ | -------------------------- |
| `ga`     | Normal | Harpoon: Add current file  |
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

| Key  | Mode   | Description                     |
| ---- | ------ | ------------------------------- |
| `af` | Normal | Select outer function           |
| `if` | Normal | Select inner function           |
| `ac` | Normal | Select outer class              |
| `ic` | Normal | Select inner class              |
| `]m` | Normal | Jump to next function start     |
| `[m` | Normal | Jump to previous function start |
| `]]` | Normal | Jump to next class start        |
| `[[` | Normal | Jump to previous class start    |

### Text Object Operations

| Key           | Mode   | Description              |
| ------------- | ------ | ------------------------ |
| `<leader>tsa` | Normal | Swap next parameter      |
| `<leader>tsA` | Normal | Swap previous parameter  |
| `<leader>df`  | Normal | Peek function definition |
| `<leader>dF`  | Normal | Peek class definition    |

### Treesitter Tools

| Key          | Mode   | Description                                 |
| ------------ | ------ | ------------------------------------------- |
| `<leader>tp` | Normal | Treesitter Playground (inspect syntax tree) |
| `<leader>tc` | Normal | Treesitter: Show item under cursor          |

---

## Markdown

| Key          | Mode   | Description                                   |
| ------------ | ------ | --------------------------------------------- |
| `<leader>mg` | Normal | Preview the current Markdown buffer with Glow |

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

| Key               | Mode   | Description                      |
| ----------------- | ------ | -------------------------------- |
| `wc`              | Normal | Get highlight group under cursor |
| `<leader>x`       | Normal | Open current file in default app |
| `<C-p>`           | Normal | Jump forward in jump list        |
| `<localleader>fs` | Normal | Search sessions (auto-session)   |

### Jump List

| Key     | Mode   | Description                          |
| ------- | ------ | ------------------------------------ |
| `<C-o>` | Normal | Jump backward (Vim default)          |
| `<C-p>` | Normal | Jump forward (remapped from `<C-i>`) |

---

## Plugin-Specific Keymaps

### Comment.nvim

| Key   | Mode   | Description                    |
| ----- | ------ | ------------------------------ |
| `gcc` | Normal | Toggle comment on current line |
| `gc`  | Visual | Toggle comment on selection    |
| `gci` | Visual | Invert comment on selection    |

### Leap.nvim (Motion)

| Key  | Mode   | Description       |
| ---- | ------ | ----------------- |
| `s`  | Normal | Leap forward      |
| `S`  | Normal | Leap backward     |
| `gs` | Normal | Leap from windows |

### NvimTree

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

**Last updated:** 2025-01-13  
**Neovim version:** v0.11+
