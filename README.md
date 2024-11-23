# Notes about this Neovim config

## Upgrade to latest version of neovim

## Window (Split) management

1. `<C-w>` then lots of options in `which-key` window
2. Change layout uses capital `HJKL` letters.
3. Horizontal split to vertical split: `<C-w>H`
   - this rotates the splits anti-clockwise. Will work on any layout.
   - `J`, `K`, `L` keys also work.

## Leap(ing about like a ninja)

1. Jump to text based on character pairs. In normal mode type `s` (or `S` to search backwards from
   cursor). After a couple of chars, you will see labels in the text.

## Telescope

Things that can be searched:

1. Buffers
   - `<tab>r`
   - Command:
     `:lua require('telescope.builtin').buffers({ ignore_current_buffer = true, sort_mru = true })<CR>`
2. Files in repo
   - `<tab>f`
   - Command: `<CMD>lua require'plugins.telescope'.find_files_fallback()<CR>`
   - excludes git ignored files if in a git repository. If not in a git
     repository, searches all files.
3. All files
   - `<tab>a`
   - Command: `:Telescope find_files<CR>`
4. Text - whole project, respects .gitignore
   - `<tab>s`
   - Command:
     `:Telescope live_grep<CR>", { noremap = true, silent = true, desc = "Telescope ripgrep (not fuzzy)" }`
   - uses ripgrep, not FZF.
   - Search for a string in your current working directory, respects
     `.gitignore`. Requires Ripgrep.
5. Text - flexible
   - `<tab>x`
   - Command:
     `:lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>`
   - enables passing arguments to ripgrep
     - ` --no-ignore` - searches inside files ignored by git
     - `-tpy` or `--type python`- searches only in files with .py extension.
   - [ripgrep commands](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md)
   - [extension](https://github.com/nvim-telescope/telescope-live-grep-args.nvim)
6. Your command history
   - `<tab>tc`
   - Command: `:Telescope command_history<CR>`
   - a history of anything done in `EX` mode
7. Your search history
   - `<tab>ts`
   - Command: `:Telescope search_history<CR>`
8. Keymaps
   - `<tab>tk`
   - Command: `:Telescope keymaps<CR>`
9. Registers
   - `<tab>tr`
   - Command: `:Telescope registers<CR>`
10. Git
    - Commits
    - Branches
    - Status
    - Bcommits
11. Resume
    - whatever you were doing last in telescope
    - `<tab>z`
12. Autocommands
13. Treesitter things
14. Vim options
15. Help files
16. Projects

#### Telescope Extensions

- fzf
  - [fzf-native](https://github.com/nvim-telescope/telescope-fzf-native.nvim)
  - this gives better performance and sorting behavior. (Also includes FZF
    syntax `\!`, `\'`, `\^`, `\$` )
- projects
- harpoon
- live_grep_args
  [repo](https://github.com/nvim-telescope/telescope-live-grep-args.nvim)
- smart_history

## Marks

1. `m,` - create next sign
2. `m;` - toggle next available mark at current line
3. `dmx` - delete mark x
4. `dm<space>` - delete all marks in current buffer

5. `m:` - preview mark
6. `m]` - next mark
7. `m[` - previous mark

### Bookmarks

Not sure what these are, see `:h marks-bookmarks`

1. `m[0-9]` - Add a bookmark

## Gitsigns

1. blame current line `<leader>sb`
2. Symbols:
   - `|` - added or changed
   - `_` - deleted
   - `-` - top delete
   - `~` - change number
3. stage buffer `<leader>sS`

## LSP

- `toggle-lsp-diagnostics` can toggle virtual text diagnostic messages, but
  doesn't include the source of the diagnostic. Therefore I wrote a separate
  function for toggling diagnostic virtual text.
- View which language server generated a diagnostic message using `<Leader>l`.
  (LSPSaga line diagnostics includes server name.)

### LSPSaga

1. LSP-Finder `<Leader>i`
2. Outline `<Leader>o`
3. Documentation window hover `K`
4. Code actions `<Leader>a`
5. Rename `<Leader>r`
6. Go to previous diagnostic `[e`
7. Go to previous error `[E`
8. Go to definition `gd`
9. Peek definition `gld`
10. Line diagnostics `<Leader>ll`
11. Cursor diagnostics `<Leader>lc`

### Mason

1. List of errors: `<Leader>q`
2. Go to type definition `<Leader>D`
