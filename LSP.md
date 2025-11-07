# LSP & Tooling Documentation

Complete reference for Language Server Protocol (LSP), formatters, and linters configured in this Neovim setup.

**Last updated:** 2025-01-13

---

## Quick Reference

| Language | LSP Server | Formatter | Linter | Status |
|----------|-----------|-----------|--------|--------|
| **Lua** | lua_ls | stylua | - | ✅ Complete |
| **Python** | basedpyright + ruff | ruff_format | ruff | ✅ Optimized |
| **JavaScript** | ts_ls | biome | eslint_d | ✅ Modern |
| **TypeScript** | ts_ls | biome | eslint_d | ✅ Modern |
| **Shell/Bash** | bashls | shfmt | shellcheck | ✅ Complete |
| **JSON** | jsonls | biome, jq | - | ✅ Complete |
| **YAML** | yamlls | yamlfmt, lsp | - | ✅ Complete |
| **Markdown** | - | prettierd, prettier | markdownlint-cli2 | ✅ Complete |
| **Docker** | dockerls | - | - | ✅ Basic |

---

## Language-Specific Details

### Python 🐍

**LSP Servers:**
- **basedpyright** - Type checking, hover documentation, completions
  - Mode: `basic` type checking (can upgrade to `standard` or `strict`)
  - Auto-import completions enabled
  - Configured in: `lua/plugins/lsp.lua:120-140`

- **ruff** - Fast linting + quick fixes
  - Hover disabled (delegated to basedpyright)
  - Signature help disabled (delegated to basedpyright)
  - Configured in: `lua/plugins/lsp.lua:145-155`

**Formatter:**
- **ruff_format** - Fast, Black-compatible Python formatter
  - Configured in: `lua/plugins/conform.lua:21`
  - Format on save: ✅ Enabled (timeout: 1000ms)
  - Manual format: `<leader>cf`

**Linter:**
- **ruff** - Fast Python linter (Flake8, isort, pyupgrade, etc.)
  - Configured in: `lua/plugins/nvim-lint.lua:5`
  - Runs on: BufWritePost, InsertLeave
  - Manual lint: `<leader>cl`

**Additional Tools:**
- **mypy** - Static type checker (installed but configured separately per project)

**Why this stack?**
- **ruff** is the modern standard (10-100x faster than Black + Flake8)
- **basedpyright** is a maintained fork of pyright with better defaults
- Complementary roles: ruff for linting/formatting, basedpyright for types

---

### JavaScript / TypeScript 📜

**LSP Server:**
- **ts_ls** (formerly tsserver) - TypeScript language server
  - Handles .js, .ts, .jsx, .tsx files
  - Configured in: `lua/plugins/lsp.lua:69`

**Formatter:**
- **biome** - Fast, modern formatter and linter
  - All-in-one tool for JS/TS/JSON
  - Configured in: `lua/plugins/conform.lua:22-23`
  - Replaces: prettier, eslint for formatting

**Linter:**
- **eslint_d** - Fast ESLint daemon
  - Configured in: `lua/plugins/nvim-lint.lua:6-7`
  - Runs on: BufWritePost, InsertLeave

**Why biome?**
- 20x faster than Prettier
- Built-in linting rules
- Modern, actively maintained
- Zero config for most projects

---

### Lua 🌙

**LSP Server:**
- **lua_ls** - Official Lua language server
  - Neovim-specific configuration included
  - Workspace: Neovim runtime + config directory
  - Configured in: `lua/plugins/lsp.lua:90-120`

**Formatter:**
- **stylua** - Opinionated Lua formatter
  - Configured in: `lua/plugins/conform.lua:20`
  - Settings: `.stylua.toml` or `stylua.toml` in project root

**Settings:**
- Diagnostics: Neovim globals enabled
- Workspace: Loads Neovim runtime library
- Format on save: ✅ Enabled

---

### Shell Scripts 🐚

**LSP Server:**
- **bashls** - Bash language server
  - Configured in: `lua/plugins/lsp.lua:69`

**Formatter:**
- **shfmt** - Shell script formatter
  - Configured in: `lua/plugins/conform.lua:27`

**Linter:**
- **shellcheck** - Shell script static analysis
  - Configured in: `lua/plugins/nvim-lint.lua:9-10`
  - Checks: sh, bash files
  - Runs on: BufWritePost, InsertLeave

---

### JSON 📄

**LSP Server:**
- **jsonls** - JSON language server
  - Schema validation
  - Configured in: `lua/plugins/lsp.lua:69`

**Formatters:**
- **biome** (first choice) - Fast, modern
- **jq** (fallback) - Command-line JSON processor
- Configured in: `lua/plugins/conform.lua:24`

---

### YAML 📋

**LSP Server:**
- **yamlls** - YAML language server
  - Schema validation (Kubernetes, GitHub Actions, etc.)
  - Configured in: `lua/plugins/lsp.lua:69`

**Formatters:**
- **yamlfmt** (first choice)
- **lsp** (fallback) - Use LSP formatting
- Configured in: `lua/plugins/conform.lua:25`

---

### Markdown 📝

**Formatters:**
- **prettierd** (fast daemon)
- **prettier** (fallback)
- Configured in: `lua/plugins/conform.lua:26`

**Linter:**
- **markdownlint-cli2** - Markdown style checker
  - Configured in: `lua/plugins/nvim-lint.lua:8`

---

## Installation & Management

### Mason (Tool Installer)

All LSP servers, formatters, and linters are installed via **Mason**.

**View installed tools:**
```vim
:Mason
```

**Tools installed automatically on startup:**
- LSP servers: lua_ls, basedpyright, ruff, ts_ls, bashls, yamlls, jsonls, dockerls
- Formatters: stylua, shfmt, prettierd, biome, ruff
- Linters: eslint_d, markdownlint-cli2, shellcheck, mypy

**Configuration:**
- LSP servers: `lua/plugins/lsp.lua`
- Mason setup: `lua/plugins/mason.lua`
- Tool list: `lua/plugins/mason.lua:17-30`

---

## Configuration Files

| Component | Location | Description |
|-----------|----------|-------------|
| LSP setup | `lua/plugins/lsp.lua` | LSP server configurations |
| Mason | `lua/plugins/mason.lua` | Tool installation |
| Formatters | `lua/plugins/conform.lua` | conform.nvim setup |
| Linters | `lua/plugins/nvim-lint.lua` | nvim-lint setup |
| Keymaps | `lua/mappings.lua` + plugin files | LSP/format/lint keybinds |

---

## Keybindings

### LSP
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `<leader>li` | Toggle inlay hints |
| `<Localleader>r` | Telescope LSP references |
| `<Localleader>a` | Telescope LSP code actions |
| `<F4>` | Restart LSP |

### Formatting
| Key | Action |
|-----|--------|
| `<leader>cf` | Format file or selection |

### Linting
| Key | Action |
|-----|--------|
| `<leader>cl` | Run linter manually |

### Diagnostics
| Key | Action |
|-----|--------|
| `<Tab>dd` | Cycle diagnostics display modes |
| `<leader>ta` | Show active LSP/formatters/linters |

---

## Troubleshooting

### LSP not starting

1. **Check LSP is installed:**
   ```vim
   :Mason
   ```

2. **Check LSP is attached:**
   ```vim
   :LspInfo
   ```

3. **Check active tools for current buffer:**
   - Press `<leader>ta` to see active LSP/formatters/linters

4. **Restart LSP:**
   - Press `<F4>` or `:LspRestart`

5. **Check logs:**
   ```vim
   :lua vim.cmd('e'..vim.lsp.get_log_path())
   ```

### Formatter not working

1. **Check formatter is installed:**
   ```vim
   :Mason
   ```

2. **Check format-on-save is enabled:**
   - It's enabled by default in `lua/plugins/conform.lua:9-17`
   - Skips files >200KB

3. **Manual format:**
   - Press `<leader>cf` to format manually
   - Check for errors in `:messages`

4. **Verify formatter for filetype:**
   ```vim
   :lua print(vim.inspect(require('conform').list_formatters(0)))
   ```

### Linter not running

1. **Check linter is installed:**
   ```vim
   :Mason
   ```

2. **Check linter is configured for filetype:**
   ```lua
   -- In lua/plugins/nvim-lint.lua, check linters_by_ft
   ```

3. **Manual lint:**
   - Press `<leader>cl` to run linter manually
   - Check output in diagnostics

4. **Check auto-lint events:**
   - Linters run on: BufWritePost, InsertLeave
   - Configured in: `lua/plugins/nvim-lint.lua:12-20`

---

## Adding a New Language

### Step 1: Install LSP Server
```vim
:Mason
" Search for your language server
" Press 'i' to install
```

### Step 2: Configure LSP
Edit `lua/plugins/lsp.lua`, add to `ensure_installed`:
```lua
ensure_installed = {
  "your_lsp_name",
  -- ... existing servers
}
```

### Step 3: Add Formatter (optional)
Edit `lua/plugins/conform.lua`:
```lua
formatters_by_ft = {
  your_filetype = { "your_formatter" },
}
```

### Step 4: Add Linter (optional)
Edit `lua/plugins/nvim-lint.lua`:
```lua
lint.linters_by_ft = {
  your_filetype = { "your_linter" },
}
```

### Step 5: Install Tools
Add to `lua/plugins/mason.lua`:
```lua
ensure_installed = {
  "your_formatter",
  "your_linter",
}
```

### Step 6: Restart Neovim
```bash
# Tools will auto-install on next startup
```

---

## Philosophy

### Why these tools?

1. **Modern & Fast:** Prefer new-generation tools (ruff, biome) over legacy ones
2. **Single Responsibility:** Each tool has a clear role (no overlaps)
3. **Minimal Configuration:** Use sensible defaults, configure only when needed
4. **Auto-install:** Mason handles installation automatically
5. **Lazy Load:** Heavy plugins load only when needed (via lazy.nvim)

### Tool Selection Criteria

- **Speed:** Prefer fast tools (ruff vs black, biome vs prettier)
- **Maintenance:** Actively maintained and modern
- **Integration:** Works well with Neovim + Mason
- **Standards:** Follows language community standards

---

**For detailed keybindings, see `KEYMAPS.md`**  
**For performance analysis, see `PERFORMANCE.md`**
