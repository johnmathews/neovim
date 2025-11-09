# AGENTS.md — Neovim Config

This is the configuration directory for my Neovim setup.
It contains configuration details for plugins, options for Neovim itself, custom functions, keybindings, and colorscheme settings.

This document is written for OpenCode (Anthropic models, plan mode)

---

## TL;DR for Agents

- Purpose: describe rules, structure, and safe edit scope for this Neovim configuration.
- Environment: macOS · Neovim v0.11+ · lazy.nvim · Stylua · Luacheck.
- Safe Actions: fix lint issues, adjust LSP config, improve keymaps, optimize startup.
- Guardrails: run lint/format before + after; never delete comments; avoid vendor files.
- Goal: maintain a clean, fast, low-maintenance setup (less than 150 ms cold-boot).

## Common Agent Tasks

- Add or adjust an LSP server with proper defaults and keymaps.
- Merge duplicate or inconsistent keymaps and generate a cheatsheet.
- Improve Treesitter textobjects and highlighting definitions.
- Tune Telescope pickers for better performance.
- Verify format-on-save and linting consistency.
- Modernize plugin declarations for Lazy.nvim.
- Ensure startup time stays under 150 ms cold boot.

### Edit Safety

Agents must:

- Run lint/format before and after edits.
- Never remove user comments or docstrings.
- Ask before mass-refactoring keymaps or plugin lists.

### Agent Interaction Summary

- Claude / OpenCode uses this file to guide coding decisions.
- All examples assume macOS + Neovim v0.11+.
- Output should follow Stylua + Luacheck rules.

---

## Environment

- **OS:** macOS (latest)
- **Neovim:** v0.11+
- **Plugin manager:** `lazy.nvim`
- **Required CLIs:** `stylua`, `luacheck`, `ripgrep`, `fd`, `node` > v18
  - Install luacheck: `brew install luacheck` (macOS)
- **Optional CLIs:** ...
- **Python:** used for data and scripting; ensure `pynvim` installed if needed.
- **Preferred shell:** zsh

---

## Development Flow

All changes should be tested before being accepted.
A test directory should exist that contains test files of different file types, with a variety of errors in them. These files can be used to verify that nvim and
its plugins behave as expected. they function like test data to test nvim against.
LSP features should be tested, but how can things like code actions, or go to definition be tested?

---

## Repo Map

- Entrypoint: `./init.lua` - loads files that loads other files
- Options: `./lua/options.lua`
- Keymaps: `./lua/mappings.lua`
- Autocmds: `./lua/autocmd.lua`
- Plugins: `./lua/plugins/`
- LSP setup: `./lua/plugins/lsp.lua` (and related files under `lua/plugins/`)
- Format/Lint: `./lua/plugins/conform.lua` + linters; Stylua for Lua
- Treesitter: `./lua/plugins/treesitter.lua`
- Telescope: `./lua/plugins/telescope.lua`
- Snippets: `./lua/snippets/`

---

## Design Principles

- **Consistency:** performance, behaviour, and naming.
- **Intuitive:** key bindings should be guessable and patterned.
- **Robust:** reliable startup and plugin handling.
- **Low Maintenance:** maintenance every ~2 years.
- **Capable:** handles large codebases (Python, Bash, SQL, JS, TS, YAML, JSON).
- **Clarity:** unambiguous, clean presentation with consistent colors.
- **Speed:** startup and runtime performance matter.
- **Naming:** consistent and predictable names for files, variables, and functions.

There should be _one good way_ to do a task (finding, applying, deciding, viewing) — not multiple overlapping methods.

---

## Functional Requirements

- **LSP stack:** full diagnostics, code actions, docstrings, goto definition/reference, and project-wide rename.
- **Git:** integrated diff, status, and history viewing.
- **Navigation:** Treesitter-based text objects, motions, and Telescope finders.
- **Overview:** class/function outline for each buffer.
- **Keymaps:** discoverable via searchable keymap list.
- **Editing:** strong support for Markdown, YAML, and structured text.

---

## Build / Lint / Test Commands

- **Lint Lua:** `luacheck lua/` (uses `.luacheckrc`)
  - Should report: `0 warnings / 0 errors in 51 files`
  - Config: `.luacheckrc` defines globals, disables line length, ignores unused vars in snippets
  - Run from config root: `cd ~/.config/nvim && luacheck lua/`
- **Format Lua:** `stylua .` (formats all Lua files)
- **Format on save:** Auto via `conform.nvim`
- **Manual format:** `<leader>cf`
- **Manual lint:** `<leader>cl`
- **Run single test:** `t<leader>n` (nearest), `t<leader>f` (file)
- **Health check:** `:checkhealth` or `nvim --headless "+CheckHealth" +qa`

---

## Code Style & Conventions

- **Formatting:** Stylua, 2-space indents, spaces not tabs.
- **Files:** plugin configs in `lua/plugins/`, snippets in `lua/snippets/`.
- **Globals allowed:** `vim`, `P`, `Functions`, `KeymapOptions`, and plugin-specific globals (see `.luacheckrc`).
- **Naming:** snake_case for files/functions; PascalCase for modules.
- **Error handling:** `pcall(require, "module")` for safety.
- **Keymaps:** define in `lua/mappings.lua` with `desc` for discoverability.
- **Imports:** lazy-load plugins when possible; require locally in functions.
- **Comments:** use single-line `--`, avoid multi-line comment blocks.
- **Linting:** All code must pass `luacheck lua/` with 0 warnings before commit.
- **Commits:** atomic, tested with `:checkhealth` and linted before commit.

---

## Commands (for Agents & CI)

| Purpose           | Command                              |
| ----------------- | ------------------------------------ |
| Format all Lua    | `stylua .`                           |
| Lint Lua          | `luacheck lua/`                      |
| Lint single file  | `luacheck lua/plugins/telescope.lua` |
| Health check      | `./scripts/health-check`             |
| Quality gate      | `./scripts/quality-gate`             |
| Pre-commit hook   | `./scripts/pre-commit`               |
| Validate setup    | `nvim --headless "+CheckHealth" +qa` |
| Re-index OpenCode | `:reload` inside OpenCode            |
| Export summaries  | `:export summary.md` inside OpenCode |

### Testing & Quality Scripts

Three automation scripts are provided in `scripts/`:

1. **`health-check`** - Comprehensive configuration health check
2. **`quality-gate`** - Pre-commit/pre-push validation
3. **`pre-commit`** - Git pre-commit hook (optional)

### Luacheck Configuration

The `.luacheckrc` file configures luacheck behavior:

- **Allowed globals:** Neovim-specific globals like `vim`, `KeymapOptions`, plugin toggle functions
- **Line length:** Maximum 150 characters (`max_line_length = 150`)
- **Snippet exceptions:** Unused variables/functions allowed in `lua/snippets/` (common for snippet helpers)
- **Target:** Zero warnings/errors across all 51 Lua files

---

## Guardrails

- Don’t edit generated or vendor files.
- Avoid introducing plugins that slow startup.
- Keep lazy-loading logic consistent.
- No hard-coded paths or credentials.
- Don’t break Treesitter or LSP initialization flow.
- Maintain functional parity across macOS and Linux.
- Preserve keymap consistency and naming patterns.

### For Agents

Do not modify scripts/, .luacheckrc, or vendor plugins without instruction.

---

## Performance Benchmarks

This section is informational only, not actionable.

informational only, not actionable

**Target:** less than 150ms cold boot startup  
**Current:** ~342ms (as of 2025-01-13)  
**Status:** 2.3x slower than target

### Startup Profiling

```bash
# Quick check
nvim --startuptime /dev/stdout --headless +qa | grep "NVIM STARTED"

# Detailed profile
nvim --startuptime startup.log --headless +qa
cat startup.log | awk '{if ($2 > 1) print $0}'

# Interactive profiling (vim-startuptime plugin installed)
nvim +StartupTime
```

### Top Contributors to Startup Time

1. **Lazy.nvim plugin loading** (~108ms) - Plugin manager overhead
2. **LSP configuration** (~15ms) - Mason + multiple servers
3. **Telescope setup** (~16ms) - Fuzzy finder + extensions
4. **Completion stack** (~10ms) - nvim-cmp + LuaSnip
5. **Treesitter** (~11ms) - Core + plugins

**See `PERFORMANCE.md` for detailed analysis and optimization recommendations.**

---

## Documentation

- **`KEYMAPS.md`** - Complete keymap reference (searchable via `<Tab>tk`)
- **`LSP.md`** - Language Server Protocol, formatters, and linters documentation
- **`PERFORMANCE.md`** - Startup performance analysis and optimization guide
- **`TESTING.md`** - Testing infrastructure, quality gates, and CI/CD setup
- **`AGENTS.md`** - This file (architecture and conventions)

---

✅ This file is designed for OpenCode and AI agents to understand and safely modify this Neovim configuration.
