# Changelog

All notable changes to this Neovim configuration will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) principles.

## [Unreleased]

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
