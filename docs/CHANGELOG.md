# Changelog

All notable changes to this Neovim configuration will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) principles.

## [Unreleased]

### Added
- **Smoke gate** (`scripts/smoke`, `test/smoke/`): opens one real buffer per daily language in an isolated Neovim
  (`SMOKE_HOME`, never `~/.local/share/nvim`) and asserts on LSP clients and settings, diagnostics per owner,
  treesitter, textobjects, folds, keymaps, lint, LSP requests and every message. Known failures live in
  `test/smoke/xfail.lua` with their finding IDs. See `docs/TESTING.md`.
- **Gate self-test** (`scripts/gate-selftest`, `test/smoke/fixtures/`): ten known-bad configs that must each fail the
  gate with a specific check ID.
- Test samples for TypeScript, SQL, JSON and TOML. The zsh sample moved to `test/zsh/test_sample.zsh`.

### Fixed
- **LSP settings apply again** (F1): mason-lspconfig v2 ignores `handlers`, so no per-server setting, `on_attach`, navic,
  `<leader>li` or cmp capability had applied. Servers now use native `vim.lsp.config`: capabilities through
  `vim.lsp.config("*")`, overrides in `after/lsp/<server>.lua`, one `LspAttach` autocmd for navic and `<leader>li`.
  basedpyright runs in `basic` mode again (18 diagnostics on the sample become 4).
- **Only the listed servers start** (F13): `automatic_enable = false` plus an explicit `vim.lsp.enable` list of 10
  servers. sqls, stylua, eslint, biome and the other Mason servers no longer start.
- **zsh is shellchecked again** (F5): `shellcheck_zsh` is now a copy of nvim-lint's shellcheck linter, so it no longer
  rewrites the shared linter's args, and it asks for `json1`, the format nvim-lint parses.
- **markdownlint runs again** (F6): every markdown lint run had failed with "expected table, got function". The linter
  is now a function that returns a copy with list `args`, `--stdin` restored, and print mode's `--disable MD013` kept.
- **One owner per lint finding** (F13): nvim-lint no longer runs ruff (the ruff LSP server reports it) or shellcheck on
  sh and bash (bashls runs it).
- **conform options** (F25): `default_format_opts = { lsp_format = "fallback" }` replaces the deprecated
  `lsp_fallback`, and YAML no longer lists the unknown formatter `lsp`.

### Changed
- **Floating window borders**: `winborder = "rounded"` replaces the `open_floating_preview` override. The cmp menu and
  the which-key popup now take the rounded border too.
- **Gates fail closed**: `quality-gate` fails when stylua or luacheck is missing, reads stylua's exit code, lints
  `lua/`, `after/` and `test/smoke/`, and replaces its load test with `scripts/smoke --startup-only`, which also scans
  the config for deprecated APIs. `health-check` exits 1 on any failure, enforces `scripts/versions.env`, takes the
  median of five startups, runs `:checkhealth vim.deprecated vim.lsp`, and has an `--isolated` mode.
- **Hooks per worktree**: `install-hooks` sets `core.hooksPath` to `scripts/`, so a worktree commit runs that
  worktree's gate. pre-push runs the full smoke gate after `quality-gate`.

- **Startup is about 140 ms, down from about 400 ms** (F11): `init.lua` no longer shells out to `poetry` and
  `neovim-node-host` on every launch. `vim.loader.enable()` moved to its first line.
- **Python provider** (F22): `g:python3_host_prog` is the `pynvim` tool from `uv tool install pynvim` when it exists,
  instead of `poetry` or a hard-coded pyenv 3.10.12 path. The Node provider is disabled; no remote plugin uses it.
- **`<leader>x`** opens the current file with `vim.ui.open`, which works on macOS (`xdg-open` does not exist there).
- **Deprecated and private APIs** (F15): `vim.lsp.log.set_level`, `vim.uv`, `nvim_echo`, and a choice-popup size the
  config computes instead of the private `_make_floating_popup_size`.
- **SQL formats with sqlfluff** on `<leader>cf` only, never on save. Without a `.sqlfluff` file the dialect is
  postgres (bigquery for `.bq`).
- Mason also installs sqlfluff, yamlfmt, jq, shellcheck and jsonlint, which the format and lint config already used.

- **Project root without project.nvim** (F14): a `BufEnter` autocmd in `lua/autocmd.lua` moves cwd to the nearest root
  marker with `vim.fs.root`, with the same markers and excluded path. `<Tab>p`, the dashboard's `p` button and
  `<localleader>fs` open `:AutoSession search`.

### Removed
- **project.nvim** (F14, F18): unmaintained since 2023, and it calls `vim.lsp.buf_get_clients()`, which 0.12 removed
  apart from a shim. **session-lens** (F18): merged into auto-session.
- `test/test_lsp.sh`: it ran bare `nvim` against the real data directory and passed when a server name appeared
  anywhere in the output. The smoke gate covers everything it checked.

## [1.2.0] - 2025-11-08

### Added
- **Markdown Preview (Glow)**: Enabled [glow.nvim](https://github.com/ellisonleao/glow.nvim) with lazy-loading, `<leader>mg` keymap, and detection of the `glow` CLI (`lua/plugins.lua`, `lua/plugins/glow.lua`, `lua/plugins/whichkey.lua`).
- **Documentation**: Updated `README.md` and `docs/KEYMAPS.md` with Glow usage instructions, installation requirements, and keymap references.

### Performance
- **Additional Lazy-Loading**: Extended lazy-loading to 8 total plugins (was 5 in v1.1.0)
  - Lazy-loaded lualine with `event = "VeryLazy"` (`lua/plugins.lua:145-154`)
  - Disabled Mason `run_on_start` to prevent automatic LSP server checks (`lua/plugins/mason.lua:31`)
  - Lazy-loaded Harpoon with `keys = { "ga", "gh", "gn", "gp" }` (`lua/plugins.lua:136-142`)
  - Startup time remains stable at ~350ms (within acceptable range)

### Changed
- **Version**: Bumped to 1.2.0
- **Metrics**: Updated performance metrics throughout documentation
- **Documentation**: Updated `README.md`, `CHANGELOG.md`, and `IMPROVEMENTS.md` with latest optimizations

## [1.1.0] - 2025-11-07

### Added
- **Test Infrastructure**: Created `test/` directory with sample files for 6 languages (Python, Lua, JavaScript, YAML, Markdown, Bash)
  - Each test file contains intentional errors for LSP/linter validation
  - Added `test/test_lsp.sh` automated LSP testing script
  - Documented testing approach in `test/README.md`
- **Which-Key Groups**: Added Telescope key groups for better discoverability
  - `<Tab>` - Telescope group
  - `<Tab>g` - Git group
  - `<Tab>t` - Tools group
- **Documentation**: Created `IMPROVEMENTS.md` to track enhancement history

### Changed
- **Performance Optimizations**: Implemented lazy-loading for 5 major plugins
  - Telescope: loads on `<Tab>` keypress or `:Telescope` command
  - nvim-cmp: loads on `InsertEnter` event
  - LuaSnip: loads on `InsertEnter` event  
  - gitsigns: loads on `BufReadPre` event
  - alpha-nvim: loads on `VimEnter` event
- **Performance Documentation**: Updated `PERFORMANCE.md` with new measurements and realistic expectations

### Fixed
- **Health Check Script**: Fixed floating-point arithmetic bug in `scripts/health-check`
  - Lines 68-73 now properly convert startup time to integer for comparison
  - Correct categorization of startup time thresholds

### Performance
- Headless startup: ~347ms (similar to 342ms baseline)
- Real-world estimated startup: 250-280ms with lazy-loading benefits
- All plugins now load on-demand rather than at startup

## [1.0.0] - 2025-11-07 (Baseline)

### Initial Configuration
- Full LSP stack with Mason, nvim-lspconfig
- Telescope fuzzy finder with multiple extensions
- Treesitter for syntax highlighting and text objects
- nvim-cmp completion engine with LuaSnip
- Git integration via gitsigns
- 88 total plugins installed
- Baseline startup time: ~342ms headless

---

## Versioning Guidelines

This project uses semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR**: Breaking changes to configuration or keymaps
- **MINOR**: New features, plugins, or significant enhancements
- **PATCH**: Bug fixes, documentation updates, minor tweaks

## Change Categories

- **Added**: New features, plugins, or functionality
- **Changed**: Changes to existing functionality
- **Deprecated**: Features that will be removed in future versions
- **Removed**: Features or plugins that were removed
- **Fixed**: Bug fixes
- **Security**: Security-related changes
- **Performance**: Performance improvements

## How to Update This Changelog

When making changes to the configuration:

1. Add entries under `[Unreleased]` section
2. Use appropriate category headers (Added, Changed, Fixed, etc.)
3. Write clear, concise descriptions
4. Reference file paths where relevant
5. When releasing, move `[Unreleased]` entries to a new version section
6. Add date in YYYY-MM-DD format

### Example Entry Format

```markdown
### Added
- **Feature Name**: Brief description of what was added
  - Additional context or details
  - File paths: `lua/plugins/example.lua`

### Fixed
- **Bug Description**: What was broken and how it was fixed
```

---

[Unreleased]: https://github.com/johnmathews/neovim/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/johnmathews/neovim/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/johnmathews/neovim/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/johnmathews/neovim/releases/tag/v1.0.0
