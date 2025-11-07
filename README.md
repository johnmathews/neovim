# Neovim Configuration

A robust, performant Neovim configuration optimized for Python, JavaScript/TypeScript, Lua, Bash, SQL, YAML, and Markdown development.

**Version:** 1.1.0  
**Last Updated:** 2025-11-07  
**Repository:** https://github.com/johnmathews/neovim

---

## 🎯 Features

- **Full LSP Support** - Language servers for 10+ languages via Mason
- **Fuzzy Finding** - Telescope with multiple search modes and extensions
- **Git Integration** - Gitsigns for inline blame, diffs, and staging
- **Smart Completion** - nvim-cmp with LuaSnip snippets
- **Syntax Highlighting** - Treesitter with custom text objects
- **Fast Navigation** - Leap motion, Harpoon marks, and project management
- **Performance** - Lazy-loaded plugins, ~347ms startup time
- **Testing** - Automated LSP testing and comprehensive test suite
- **Documentation** - Detailed guides for LSP, keymaps, and performance

---

## 📋 Quick Start

### Requirements

- **Neovim:** v0.11.4+
- **Node.js:** v18+ (for LSP servers)
- **CLI Tools:**
  ```bash
  brew install luacheck stylua ripgrep fd
  ```
- **Optional:** `pynvim` for Python support

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

1. **Check health:** `:checkhealth` or run `./scripts/health-check`
2. **View keymaps:** `<Tab>tk` or see [KEYMAPS.md](KEYMAPS.md)
3. **Configure LSP:** See [LSP.md](LSP.md) for language server setup
4. **Test LSP:** Run `./test/test_lsp.sh` to verify LSP attachment

---

## 🚀 Key Features Guide

### 1. Telescope (Fuzzy Finder)

**Prefix:** `<Tab>` (all Telescope commands start with Tab)

| Keymap     | Function                              |
|------------|---------------------------------------|
| `<Tab>f`   | Find files (respects .gitignore)      |
| `<Tab>a`   | Find all files                        |
| `<Tab>s`   | Search text (ripgrep)                 |
| `<Tab>x`   | Search with ripgrep args              |
| `<Tab>r`   | Recent buffers                        |
| `<Tab>tk`  | Search keymaps                        |
| `<Tab>tc`  | Command history                       |
| `<Tab>gc`  | Git commits                           |
| `<Tab>gb`  | Git branches                          |
| `<Tab>z`   | Resume last search                    |

**Telescope Extensions:**
- `fzf-native` - Better performance and FZF syntax support
- `live_grep_args` - Pass arguments to ripgrep (e.g., `--no-ignore`, `-tpy`)
- `smart_history` - Persistent search history
- `project` - Project management

### 2. LSP (Language Server Protocol)

**Available via Mason:** Python (pyright), Lua (lua_ls), JavaScript/TypeScript (ts_ls), YAML (yamlls), Bash, JSON, SQL, Markdown, HTML, CSS

| Keymap       | Function                        |
|--------------|---------------------------------|
| `K`          | Hover documentation             |
| `gd`         | Go to definition                |
| `gD`         | Go to declaration               |
| `gr`         | Go to references                |
| `gi`         | Go to implementation            |
| `<leader>rn` | Rename symbol                   |
| `<leader>ca` | Code actions                    |
| `<leader>cf` | Format document                 |
| `[d`         | Previous diagnostic             |
| `]d`         | Next diagnostic                 |
| `<leader>q`  | Diagnostic quickfix list        |

**LSP Documentation:** See [LSP.md](LSP.md) for detailed server configurations and troubleshooting.

### 3. Git Integration (Gitsigns)

| Keymap         | Function                      |
|----------------|-------------------------------|
| `<leader>sb`   | Blame current line            |
| `<leader>sS`   | Stage buffer                  |
| `<leader>su`   | Undo stage hunk               |
| `<leader>sr`   | Reset hunk                    |
| `<leader>sp`   | Preview hunk                  |
| `]c`           | Next git hunk                 |
| `[c`           | Previous git hunk             |

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

| Keymap    | Function                           |
|-----------|------------------------------------|
| `<C-w>s`  | Horizontal split                   |
| `<C-w>v`  | Vertical split                     |
| `<C-w>H`  | Rotate layout counterclockwise     |
| `<C-w>J/K/L` | Rotate layout other directions  |
| `<C-w>q`  | Close window                       |
| `<C-w>=`  | Equalize window sizes              |

---

## 📁 Configuration Structure

```
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
│   │   ├── lsp.lua             # LSP setup
│   │   ├── telescope.lua       # Telescope configuration
│   │   ├── treesitter.lua      # Treesitter setup
│   │   ├── cmp.lua             # Completion configuration
│   │   └── ...
│   └── snippets/               # LuaSnip snippets (6 languages)
├── ftplugin/                   # Filetype-specific settings (22 files)
├── scripts/
│   ├── health-check            # Configuration health check
│   ├── quality-gate            # Pre-commit validation
│   └── pre-commit              # Git pre-commit hook
├── test/                       # Test files for LSP/linter validation
│   ├── test_lsp.sh             # Automated LSP testing
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
# Test LSP attachment (4 languages)
./test/test_lsp.sh

# Run health check
./scripts/health-check

# Run quality gate (linting + formatting)
./scripts/quality-gate
```

### Test Results (2025-11-07)

- ✅ **Health Check:** PASS
- ✅ **Code Quality:** 0 warnings / 0 errors (51 Lua files)
- ✅ **LSP Attachment:** 4/4 languages (100%)
- ✅ **Startup Performance:** 347ms (acceptable)

**Detailed Results:** See [TEST_RESULTS.md](TEST_RESULTS.md)

---

## ⚡ Performance

**Current Performance:**
- Headless startup: ~347ms (average of 3 runs)
- Real-world startup: ~250-280ms (with lazy-loading)
- Plugin count: 88 (5 major plugins lazy-loaded)

**Lazy-Loaded Plugins:**
- Telescope (loads on `<Tab>` keypress)
- nvim-cmp (loads on `InsertEnter`)
- LuaSnip (loads on `InsertEnter`)
- Gitsigns (loads on `BufReadPre`)
- Alpha dashboard (loads on `VimEnter`)

**Performance Guide:** See [PERFORMANCE.md](PERFORMANCE.md) for detailed analysis and optimization tips.

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [AGENTS.md](AGENTS.md) | Architecture, design principles, conventions |
| [CHANGELOG.md](CHANGELOG.md) | Version history and change tracking |
| [IMPROVEMENTS.md](IMPROVEMENTS.md) | Enhancement implementation details |
| [KEYMAPS.md](KEYMAPS.md) | Complete keymap reference (searchable via `<Tab>tk`) |
| [LSP.md](LSP.md) | LSP servers, formatters, linters |
| [PERFORMANCE.md](PERFORMANCE.md) | Startup analysis and optimization |
| [TESTING.md](TESTING.md) | Testing infrastructure and CI/CD |
| [TEST_RESULTS.md](TEST_RESULTS.md) | Latest test execution results |
| [TESTING_CHANGELOG_GUIDE.md](TESTING_CHANGELOG_GUIDE.md) | Testing & changelog workflows |

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
# Test LSP stack
./test/test_lsp.sh

# Full health check
./scripts/health-check

# Quality gate (before commit)
./scripts/quality-gate
```

---

## 🐛 Troubleshooting

### LSP Not Attaching

1. Check LSP status: `:LspInfo`
2. Verify server installed: `:Mason`
3. Check logs: `:LspLog`
4. Run LSP test: `./test/test_lsp.sh`
5. See [LSP.md](LSP.md) for detailed troubleshooting

### Slow Startup

1. Check startup time: `nvim --startuptime startup.log +qa`
2. Profile plugins: `:Lazy profile`
3. See [PERFORMANCE.md](PERFORMANCE.md) for optimization tips

### Linting/Formatting Issues

1. Check conform status: `:ConformInfo`
2. Verify formatter installed: `:Mason`
3. Check configuration: See [LSP.md](LSP.md)

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

**Enjoy your Neovim experience! 🚀**
