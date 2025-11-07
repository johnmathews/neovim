# AGENTS.md — Neovim Config

This is the configuration directory for my Neovim setup.  
It contains configuration details for plugins, options for Neovim itself, custom functions, keybindings, and colorscheme settings.

---

## Environment

- **OS:** macOS (latest)
- **Neovim:** v0.11+
- **Plugin manager:** `lazy.nvim`
- **Required CLIs:** `stylua`, `luacheck`, `ripgrep`, `fd`, `node` > v18
- **Optional CLIs:** ...
- **Python:** used for data and scripting; ensure `pynvim` installed if needed.

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
- **Format on save:** Auto via `conform.nvim`
- **Manual format:** `<leader>cf`
- **Manual lint:** `<leader>cl`
- **Run single test:** `t<leader>n` (nearest), `t<leader>f` (file)
- **Health check:** `:checkhealth` or `nvim --headless "+CheckHealth" +qa`

---

## Code Style & Conventions

- **Formatting:** Stylua, 2-space indents, spaces not tabs.
- **Files:** plugin configs in `lua/plugins/`, snippets in `lua/snippets/`.
- **Globals allowed:** `vim`, `P`, `Functions` (per `.luacheckrc`).
- **Naming:** snake_case for files/functions; PascalCase for modules.
- **Error handling:** `pcall(require, "module")` for safety.
- **Keymaps:** define in `lua/mappings.lua` with `desc` for discoverability.
- **Imports:** lazy-load plugins when possible; require locally in functions.
- **Comments:** use single-line `--`, avoid multi-line comment blocks.
- **Commits:** atomic, tested with `:checkhealth` before commit.

---

## Commands (for Agents & CI)

| Purpose           | Command                              |
| ----------------- | ------------------------------------ |
| Format all Lua    | `stylua .`                           |
| Lint Lua          | `luacheck lua/`                      |
| Validate setup    | `nvim --headless "+CheckHealth" +qa` |
| Re-index OpenCode | `:reload` inside OpenCode            |
| Export summaries  | `:export summary.md` inside OpenCode |

---

## Guardrails

- Don’t edit generated or vendor files.
- Avoid introducing plugins that slow startup.
- Keep lazy-loading logic consistent.
- No hard-coded paths or credentials.
- Don’t break Treesitter or LSP initialization flow.
- Maintain functional parity across macOS and Linux.
- Preserve keymap consistency and naming patterns.

---

## Common Agent Tasks

- Add or adjust an LSP server with proper defaults and keymaps.
- Merge duplicate or inconsistent keymaps and generate a cheatsheet.
- Improve Treesitter textobjects and highlighting definitions.
- Tune Telescope pickers for better performance.
- Verify format-on-save and linting consistency.
- Modernize plugin declarations for Lazy.nvim.
- Ensure startup time stays under 150 ms cold boot.

---

✅ This file is designed for OpenCode and AI agents to understand and safely modify this Neovim configuration.
