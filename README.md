# Neovim Configuration

A robust, performant Neovim configuration optimized for Python, JavaScript/TypeScript, Lua, Bash, SQL, YAML, and
Markdown development.

**Version:** 1.2.0  
**Last Updated:** 2025-11-08  
**Repository:** https://github.com/johnmathews/neovim

---

## 🎯 Features

- **Full LSP Support** - Language servers for 10+ languages via Mason
- **Fuzzy Finding** - Telescope with multiple search modes and extensions
- **Git Integration** - Gitsigns for inline blame, diffs, and staging
- **Smart Completion** - nvim-cmp with LuaSnip snippets
- **Syntax Highlighting** - Treesitter with custom text objects
- **Fast Navigation** - Leap motion, Harpoon marks, project-root cwd and session search
- **Performance** - Lazy-loaded plugins, ~140ms startup time
- **Testing** - Automated LSP testing and comprehensive test suite
- **Documentation** - Detailed guides for LSP, keymaps, and performance

---

## 📋 Quick Start

### Requirements

- **Neovim:** v0.11.4+
- **Node.js:** v18+ (for LSP servers)
- **CLI Tools:**

  ```bash
  brew install luacheck stylua ripgrep fd glow
  ```

  `glow` powers the in-editor Markdown preview described below.

- **Optional:** the Python provider, for Python remote plugins such as vim-mundo. Install it with
  `uv tool install pynvim`; `init.lua` uses that interpreter when it exists. The Node provider is disabled.

### Installation

```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.backup

# Clone this repository
git clone https://github.com/johnmathews/neovim.git ~/.config/nvim

# Launch Neovim (plugins will auto-install)
nvim

# Install LSP servers via Mason
:Mason
```

### First Steps

1. **Install git hooks:** Run `./scripts/install-hooks` to enable automatic quality checks
2. **Check health:** `:checkhealth` or run `./scripts/health-check`
3. **View keymaps:** `<Tab>tk` or see [KEYMAPS.md](docs/KEYMAPS.md)
4. **Configure LSP:** See [LSP.md](docs/LSP.md) for language server setup
5. **Run the smoke gate:** `./scripts/smoke --seed-from ~/.local/share/nvim` opens a buffer per language in an isolated Neovim

---

## 🚀 Key Features Guide

### 1. Telescope (Fuzzy Finder)

**Prefix:** `<Tab>` (all Telescope commands start with Tab)

| Keymap    | Function                         |
| --------- | -------------------------------- |
| `<Tab>f`  | Find files (respects .gitignore) |
| `<Tab>a`  | Find all files                   |
| `<Tab>s`  | Search text (ripgrep)            |
| `<Tab>x`  | Search with ripgrep args         |
| `<Tab>r`  | Recent buffers                   |
| `<Tab>tk` | Search keymaps                   |
| `<Tab>tc` | Command history                  |
| `<Tab>gc` | Git commits                      |
| `<Tab>gb` | Git branches                     |
| `<Tab>z`  | Resume last search               |

**Telescope Extensions:**

- `fzf-native` - Better performance and FZF syntax support
- `live_grep_args` - Pass arguments to ripgrep (e.g., `--no-ignore`, `-tpy`)
- `smart_history` - Persistent search history

Entering a file buffer moves the working directory to its project root (the nearest `.git`, `Makefile`,
`package.json` or similar; `lua/autocmd.lua`). `<Tab>p` searches saved sessions (`:AutoSession search`).

### 2. LSP (Language Server Protocol)

**Available via Mason:** Python (pyright), Lua (lua_ls), JavaScript/TypeScript (ts_ls), YAML (yamlls), Bash, JSON, SQL,
Markdown, HTML, CSS

| Keymap       | Function                 |
| ------------ | ------------------------ |
| `K`          | Hover documentation      |
| `gd`         | Go to definition         |
| `gD`         | Go to declaration        |
| `gr`         | Go to references         |
| `gi`         | Go to implementation     |
| `<leader>rn` | Rename symbol            |
| `<leader>ca` | Code actions             |
| `<leader>cf` | Format document          |
| `[d`         | Previous diagnostic      |
| `]d`         | Next diagnostic          |
| `<leader>q`  | Diagnostic quickfix list |

**LSP Documentation:** See [LSP.md](docs/LSP.md) for detailed server configurations and troubleshooting.

### 3. Git Integration (Gitsigns)

| Keymap       | Function           |
| ------------ | ------------------ |
| `<leader>sb` | Blame current line |
| `<leader>sS` | Stage buffer       |
| `<leader>su` | Undo stage hunk    |
| `<leader>sr` | Reset hunk         |
| `<leader>sp` | Preview hunk       |
| `]c`         | Next git hunk      |
| `[c`         | Previous git hunk  |

**Visual Indicators:**

- `|` - Added or changed line
- `_` - Deleted line
- `~` - Changed line number

### 4. Navigation & Motion

**Leap Motion:**

- `s` - Jump forward by 2-character search
- `S` - Jump backward by 2-character search
- Type 2 characters → see labeled jump points → press label

**Harpoon (Quick Marks):**

- `<leader>ha` - Add file to harpoon
- `<leader>hh` - Toggle harpoon menu
- `<leader>h1-4` - Jump to harpooned file 1-4

**Marks:**

- `m,` - Create next available mark
- `m;` - Toggle mark at current line
- `dmx` - Delete mark x
- `dm<space>` - Delete all marks in buffer
- `m]` - Next mark
- `m[` - Previous mark

### 5. Window (Split) Management

**Prefix:** `<C-w>` (Control+W, then see which-key options)

| Keymap       | Function                       |
| ------------ | ------------------------------ |
| `<C-w>s`     | Horizontal split               |
| `<C-w>v`     | Vertical split                 |
| `<C-w>H`     | Rotate layout counterclockwise |
| `<C-w>J/K/L` | Rotate layout other directions |
| `<C-w>q`     | Close window                   |
| `<C-w>=`     | Equalize window sizes          |

### 6. Markdown Authoring

| Keymap/Command | Function                                                 |
| -------------- | -------------------------------------------------------- |
| `<leader>mg`   | Open a live Glow preview for the current Markdown buffer |
| `:Glow`        | Manually trigger the Glow preview command                |

**Details:**

- Uses [glow.nvim](https://github.com/ellisonleao/glow.nvim) with a 120-column floating window, rounded border, and 85%
  screen height.
- Automatically lazy-loads when editing Markdown, running `:Glow`, or pressing `<leader>mg`.
- Requires the [`glow`](https://github.com/charmbracelet/glow) CLI (install via `brew install glow`).
- Falls back with a warning if the CLI is missing so you know why the preview did not start.

---

## 📁 Configuration Structure

```text
~/.config/nvim/
├── init.lua                    # Entry point
├── lua/
│   ├── options.lua             # Neovim options
│   ├── mappings.lua            # Keybindings
│   ├── autocmd.lua             # Autocommands
│   ├── functions.lua           # Custom functions
│   ├── colorscheme.lua         # Theme configuration
│   ├── plugins.lua             # Plugin declarations (lazy.nvim)
│   ├── plugins/                # Plugin configurations (45 files)
│   │   ├── lsp.lua             # LSP setup (vim.lsp.config, LspAttach, enabled servers)
│   │   ├── telescope.lua       # Telescope configuration
│   │   ├── treesitter.lua      # Treesitter setup
│   │   ├── cmp.lua             # Completion configuration
│   │   └── ...
│   └── snippets/               # LuaSnip snippets (6 languages)
├── after/lsp/                  # Per-server LSP overrides (merged over nvim-lspconfig's defaults)
├── ftplugin/                   # Filetype-specific settings (22 files)
├── scripts/
│   ├── health-check            # Configuration health check
│   ├── quality-gate            # Pre-commit validation
│   ├── smoke                   # Buffer-opening smoke gate (isolated Neovim)
│   ├── gate-selftest           # Proves the smoke gate fails on known-bad configs
│   └── pre-commit              # Git pre-commit hook
├── test/                       # Test files for LSP/linter validation
│   ├── smoke/                  # Smoke gate engine, cases, xfail list, fixtures
│   ├── python/                 # Python test files
│   ├── lua/                    # Lua test files
│   ├── javascript/             # JavaScript test files
│   └── ...
└── docs/
    ├── AGENTS.md               # Architecture & conventions
    ├── CHANGELOG.md            # Version history
    ├── IMPROVEMENTS.md         # Enhancement tracking
    ├── KEYMAPS.md              # Complete keymap reference
    ├── LSP.md                  # LSP documentation
    ├── PERFORMANCE.md          # Performance analysis
    ├── TESTING.md              # Testing infrastructure
    ├── TEST_RESULTS.md         # Latest test results
    └── TESTING_CHANGELOG_GUIDE.md # Testing & changelog guide
```

---

## 🧪 Testing & Validation

### Automated Tests

```bash
# Open a buffer per language and check LSP, lint, treesitter and messages
./scripts/smoke

# Run health check
./scripts/health-check

# Run quality gate (linting + formatting)
./scripts/quality-gate
```

### Test Results (2025-11-08)

- ✅ **Health Check:** PASS
- ✅ **Code Quality:** 0 warnings / 0 errors (58 Lua files)
- ✅ **LSP Attachment:** 4/4 languages (100%)
- ✅ **Startup Performance:** 350ms (excellent, <500ms threshold)

**Detailed Results:** See [docs/TEST_RESULTS.md](docs/TEST_RESULTS.md)

---

## ⚡ Performance

**Current Performance:**

- Headless startup: ~350ms (average of 5 runs)
- Real-world startup: ~250-280ms (with lazy-loading)
- Plugin count: 88 (8 plugins lazy-loaded)

**Lazy-Loaded Plugins:**

- Telescope (loads on `<Tab>` keypress)
- nvim-cmp (loads on `InsertEnter`)
- LuaSnip (loads on `InsertEnter`)
- Gitsigns (loads on `BufReadPre`)
- Alpha dashboard (loads on `VimEnter`)
- Lualine (loads on `VeryLazy`)
- Mason (deferred with `run_on_start = false`)
- Harpoon (loads on keypress)

**Performance Guide:** See [docs/PERFORMANCE.md](docs/PERFORMANCE.md) for detailed analysis and optimization tips.

---

## 📚 Documentation

| Document                                                      | Purpose                                              |
| ------------------------------------------------------------- | ---------------------------------------------------- |
| [AGENTS.md](AGENTS.md)                                        | Architecture, design principles, conventions         |
| [CHANGELOG.md](docs/CHANGELOG.md)                             | Version history and change tracking                  |
| [IMPROVEMENTS.md](docs/IMPROVEMENTS.md)                       | Enhancement implementation details                   |
| [KEYMAPS.md](docs/KEYMAPS.md)                                 | Complete keymap reference (searchable via `<Tab>tk`) |
| [LSP.md](docs/LSP.md)                                         | LSP servers, formatters, linters                     |
| [PERFORMANCE.md](docs/PERFORMANCE.md)                         | Startup analysis and optimization                    |
| [TESTING.md](docs/TESTING.md)                                 | Testing infrastructure and CI/CD                     |
| [TEST_RESULTS.md](docs/TEST_RESULTS.md)                       | Latest test execution results                        |
| [TESTING_CHANGELOG_GUIDE.md](docs/TESTING_CHANGELOG_GUIDE.md) | Testing & changelog workflows                        |

---

## 🔧 Common Tasks

### Update Plugins

```bash
# Inside Neovim
:Lazy update

# Check for issues
:Lazy health
```

### Update LSP Servers

```bash
# Inside Neovim
:Mason

# Or update all
:MasonUpdateAll
```

### Format Code

```bash
# Format current buffer
<leader>cf

# Or via command
:lua require('conform').format()
```

### Lint Code

```bash
# Lint current buffer
<leader>cl

# Or via command
:lua require('lint').try_lint()
```

### Run Tests

```bash
# Install git hooks (one-time setup)
./scripts/install-hooks

# Smoke gate: real buffers in an isolated Neovim
./scripts/smoke

# Full health check
./scripts/health-check

# Quality gate (linting + formatting)
./scripts/quality-gate
```

### Git Hooks (Automatic Quality Assurance)

`./scripts/install-hooks` sets `core.hooksPath` to `scripts/`, so every worktree runs its own hooks. The smoke gate
needs a one-time `./scripts/smoke --seed-from ~/.local/share/nvim` per Neovim version.

**Pre-commit hook** (runs before each commit):

- Luacheck validation
- Code formatting check
- Startup check in an isolated Neovim (`scripts/smoke --startup-only`)
- Common issue detection

**Pre-push hook** (runs before push to remote):

- Full quality gate
- Full smoke gate: a real buffer per language (about 1 to 1.5 minutes)

**Bypass hooks** (emergency only):

```bash
git commit --no-verify
git push --no-verify
```

---

## 🐛 Troubleshooting

### LSP Not Attaching

1. Check LSP status: `:LspInfo`
2. Verify server installed: `:Mason`
3. Check logs: `:LspLog`
4. Run the smoke gate for that language: `./scripts/smoke --only python`
5. See [LSP.md](docs/LSP.md) for detailed troubleshooting

### Slow Startup

1. Check startup time: `nvim --startuptime startup.log +qa`
2. Profile plugins: `:Lazy profile`
3. See [docs/PERFORMANCE.md](docs/PERFORMANCE.md) for optimization tips

### Linting/Formatting Issues

1. Check conform status: `:ConformInfo`
2. Verify formatter installed: `:Mason`
3. Check configuration: See [docs/LSP.md](docs/LSP.md)

### Plugin Errors

1. Check plugin health: `:Lazy health`
2. Update plugins: `:Lazy sync`
3. Check Lazy logs: `:Lazy log`

---

## 🤝 Contributing

This is a personal configuration, but suggestions are welcome!

### Making Changes

1. Create a feature branch
2. Make changes
3. Update `CHANGELOG.md` under `[Unreleased]`
4. Run tests: `./scripts/quality-gate`
5. Commit with descriptive message

### Commit Messages

Follow conventional commits:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `perf:` - Performance improvements
- `refactor:` - Code refactoring
- `test:` - Test changes

---

## 📜 License

MIT License - Feel free to use and modify as needed.

---

## 🙏 Acknowledgments

Built with:

- [lazy.nvim](https://github.com/folke/lazy.nvim) - Plugin manager
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - LSP configuration
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Fuzzy finder
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - Syntax highlighting
- [mason.nvim](https://github.com/williamboman/mason.nvim) - LSP installer

And 80+ other amazing plugins. See `lua/plugins.lua` for complete list.

---

## 📞 Support

- **Issues:** https://github.com/johnmathews/neovim/issues
- **Documentation:** See docs in this repository
- **Neovim Help:** `:help` or https://neovim.io/doc/

---

Enjoy your Neovim experience! 🚀
