# LSP & Tooling Documentation

Complete reference for Language Server Protocol (LSP), formatters, and linters configured in this Neovim setup.

**Last updated:** 2026-10-10

---

## How Servers Start

LSP servers use Neovim's native configuration (`vim.lsp.config` and `vim.lsp.enable`, Neovim 0.11+). nvim-lspconfig
only supplies a default config file per server (`lsp/<server>.lua` on the runtimepath). Its old
`require("lspconfig")[server].setup()` framework is deprecated and is not used.

`lua/plugins/lsp.lua` does four things:

1. `vim.lsp.config("*", { capabilities = ... })` gives every server the nvim-cmp completion capabilities.
2. One `LspAttach` autocmd (augroup `UserLspAttach`) runs for every client that attaches (see below).
3. `mason-lspconfig.setup({ ensure_installed = servers, automatic_enable = false })` makes Mason install the servers.
   It does not start them.
4. `vim.lsp.enable(servers)` starts exactly the servers in the list, on every machine.

The enabled servers are an explicit list, so the set that starts does not depend on what Mason happens to hold:

`lua_ls`, `basedpyright`, `ruff`, `ts_ls`, `bashls`, `yamlls`, `jsonls`, `dockerls`, `taplo`, `marksman`.

Everything else Mason may have installed (html, jinja_lsp, lemminx, clangd, rust_analyzer, svelte, bicep, sqls, and
the stylua, eslint and biome servers) stays off. SQL deliberately has no LSP: vim-dadbod completes and sqlfluff formats.

### Merge order

A server's final config is merged, later winning, from:

1. `vim.lsp.config("*", ...)` in `lua/plugins/lsp.lua` (capabilities for all servers)
2. nvim-lspconfig's `lsp/<server>.lua` (command, filetypes, root markers, the server's own defaults)
3. this config's `after/lsp/<server>.lua` (the overrides)

Each file in `after/lsp/` returns only the fields it changes:

| File | Overrides |
| --- | --- |
| `after/lsp/basedpyright.lua` | `typeCheckingMode = "basic"`, auto-import completions |
| `after/lsp/bashls.lua` | filetypes `sh`, `bash`, `zsh`; glob pattern; shellcheck `-x` |
| `after/lsp/lua_ls.lua` | LuaJIT runtime, Neovim globals, hints, no telemetry |
| `after/lsp/yamlls.lua` | validation on, formatting off (conform owns YAML formatting), no key-order warnings |

Root detection and single-file support come from nvim-lspconfig's defaults. Inspect the merged result of a running
client with `:lua vim.print(vim.lsp.get_clients({ bufnr = 0 })[1].config.settings)`.

### LspAttach

The `LspAttach` autocmd replaces per-server `on_attach` functions. An `on_attach` in a server's config would replace the
one nvim-lspconfig ships for that server (basedpyright has one), so this config never sets one. For each attaching
client it:

- attaches nvim-navic (breadcrumbs) when the client supports `textDocument/documentSymbol`
- maps `<leader>li` (toggle inlay hints) buffer-locally when the client supports `textDocument/inlayHint`

The other LSP keymaps are global, in `lua/mappings.lua`.

### Floating windows

`winborder = "rounded"` in `lua/options.lua` gives every floating window (hover, signature help, diagnostics) a rounded
border. Diagnostic floats also set `float.border` in `vim.diagnostic.config`.

---

## Quick Reference

One owner per job: each language has one LSP server set, one formatter chain and one linter, so no finding appears
twice.

| Language       | LSP Server          | Formatter           | Linter            |
| -------------- | ------------------- | ------------------- | ----------------- |
| **Lua**        | lua_ls              | stylua              | luacheck          |
| **Python**     | basedpyright + ruff | ruff_format         | ruff (LSP)        |
| **JavaScript** | ts_ls               | biome               | eslint_d          |
| **TypeScript** | ts_ls               | biome               | eslint_d          |
| **Shell/Bash** | bashls              | shfmt               | shellcheck (via bashls) |
| **Zsh**        | bashls              | shfmt               | shellcheck (nvim-lint, bash mode) |
| **JSON**       | jsonls              | biome, jq           | jsonlint          |
| **YAML**       | yamlls              | yamlfmt             | yamlls            |
| **TOML**       | taplo               | taplo               | taplo             |
| **Markdown**   | marksman            | prettierd           | markdownlint      |
| **Docker**     | dockerls            | -                   | dockerls          |
| **SQL**        | -                   | sqlfluff            | -                 |

Python lint comes from the ruff LSP server and sh/bash lint from bashls, so nvim-lint runs neither. Zsh is the one
shell nvim-lint covers, because bashls does not shellcheck it. The smoke gate (`test/smoke/cases.lua`) asserts each
row's diagnostic sources, so a second owner turns it red.

---

## Language-Specific Details

### Python

- **basedpyright**: types, hover, completions, go to definition and rename. Mode `basic` (`after/lsp/basedpyright.lua`).
  basedpyright reads `basedpyright.*` settings only; `python.*` analysis settings do nothing. It also pushes its
  diagnostics: the override turns off dynamic registration of pull diagnostics, which Neovim 0.12 would otherwise
  accept and which sometimes left a buffer with none of basedpyright's diagnostics.
- **ruff** (LSP): lint diagnostics and quick fixes.
- **ruff_format** (conform): formatting, on save.
- **mypy** is installed by Mason for per-project use and is not wired in.

### JavaScript / TypeScript

- **ts_ls**: handles .js, .ts, .jsx, .tsx. Root markers and single-file support are nvim-lspconfig's defaults.
- **biome** (conform): formatting. **eslint_d** (nvim-lint): linting.

### Lua

- **lua_ls**: `after/lsp/lua_ls.lua` sets the LuaJIT runtime and the config's globals.
- **stylua** (conform): formatting, configured by `stylua.toml`. **luacheck** (nvim-lint): linting, configured by
  `.luacheckrc`.

### Shell

- **bashls**: attaches to sh, bash and zsh (`after/lsp/bashls.lua`) and runs shellcheck itself when it is on `PATH`, for
  sh and bash only. Its findings come with code actions.
- **shellcheck_zsh** (nvim-lint): shellcheck in bash mode (`--shell=bash`) for zsh, which bashls does not shellcheck. It
  is a copy of nvim-lint's shellcheck linter, so sh and bash keep the stock arguments.
- **shfmt** (conform): formatting for sh and zsh.

### SQL

- No LSP server, on purpose: vim-dadbod completes against a live connection.
- **sqlfluff** (conform): formatting on `<leader>cf` only. It is too slow for the 1000 ms format-on-save timeout, so
  saving a `.sql` file never formats it. A `.sqlfluff` file at or above the buffer's directory sets the dialect; without
  one the dialect is `postgres`, or `bigquery` for `.bq` files. sqlfluff exits 1 when it fixed some violations but not
  all, and conform treats that as success.

### JSON, YAML, TOML, Docker, Markdown

- **jsonls**, **yamlls** (formatting off), **taplo**, **dockerls** and **marksman** run with nvim-lspconfig's defaults
  apart from the yamlls override.
- Formatting comes from conform (`lua/plugins/conform.lua`), linting from nvim-lint (`lua/plugins/nvim-lint.lua`).
- YAML formats with yamlfmt only. yamlls has formatting off, so there is no LSP formatter to fall back to.
- **markdownlint** reads the nearest `.markdownlint.json` above the file, else the config's own. In markdown print mode
  (`<leader>mp`, `docs/MARKDOWN-FORMATTING.md`) it also disables MD013, the line-length rule.

---

## Installation & Management

All LSP servers, formatters and linters are installed by **Mason** (`:Mason`).

- LSP servers: the `servers` list in `lua/plugins/lsp.lua`, installed through mason-lspconfig's `ensure_installed`.
- Formatters and linters: `lua/plugins/mason.lua`, installed through mason-tool-installer on startup.
- luacheck comes from the system (`brew install luacheck`); Mason installs markdownlint.

| Component  | Location                          | Description                         |
| ---------- | --------------------------------- | ----------------------------------- |
| LSP setup  | `lua/plugins/lsp.lua`             | Capabilities, LspAttach, enable list |
| Overrides  | `after/lsp/<server>.lua`          | Per-server settings                 |
| Mason      | `lua/plugins/mason.lua`           | Tool installation                   |
| Formatters | `lua/plugins/conform.lua`         | conform.nvim setup                  |
| Linters    | `lua/plugins/nvim-lint.lua`       | nvim-lint setup                     |
| Keymaps    | `lua/mappings.lua` + plugin files | LSP/format/lint keybinds            |

---

## Keybindings

### LSP Navigation (Built-in Neovim v0.11+)

| Key          | Action                                   |
| ------------ | ---------------------------------------- |
| `gd`         | Go to definition                         |
| `gD`         | Go to declaration                        |
| `gra`        | Code actions (quick fix, refactor, etc.) |
| `grn`        | Rename symbol (workspace-wide)           |
| `grt`        | Go to type definition                    |
| `K`          | Hover documentation                      |
| `<leader>li` | Toggle inlay hints (buffers whose server supports them) |
| `<F4>`       | Restart LSP (`:LspRestart`)              |

### Telescope-based LSP Navigation

| Key              | Action                                               |
| ---------------- | ---------------------------------------------------- |
| `gr`             | Show references (Telescope picker)                   |
| `gi`             | Go to implementation (Telescope picker)              |
| `<LocalLeader>r` | Telescope: List all references                       |
| `<LocalLeader>d` | Telescope: List all definitions                      |
| `<LocalLeader>i` | Telescope: List all implementations                  |
| `<Tab>b`         | Telescope: Workspace symbols (search across project) |

### Formatting and Linting

| Key          | Action                   |
| ------------ | ------------------------ |
| `<leader>cf` | Format file or selection |
| `<leader>cl` | Run linter manually      |

Format on save runs every formatter in the Quick Reference except sqlfluff, and skips files over 200 KB. When a
filetype has no conform formatter, both `<leader>cf` and format on save fall back to the LSP server
(`default_format_opts = { lsp_format = "fallback" }`).

The full keymap reference is `docs/KEYMAPS.md`.

---

## Troubleshooting

### LSP not starting

1. Is the server in the `servers` list in `lua/plugins/lsp.lua`? Only listed servers start.
2. Is it installed? `:Mason`.
3. Is it attached? `:checkhealth vim.lsp` lists enabled configs and attached clients.
4. Restart it: `<F4>` or `:LspRestart`.
5. Read the log: `:lua vim.cmd.edit(vim.lsp.log.get_filename())`.

### A setting does not apply

Check the merged settings of the running client (see "Merge order"). A key in the wrong namespace is silently ignored,
for example `python.analysis.*` for basedpyright.

### Formatter not working

1. `:Mason` shows it installed.
2. `:lua print(vim.inspect(require('conform').list_formatters(0)))` lists the formatters for the buffer.
3. Format-on-save skips files over 200 KB. Format manually with `<leader>cf` and check `:messages`.

### Linter not running

1. `:Mason` shows it installed.
2. `linters_by_ft` in `lua/plugins/nvim-lint.lua` lists it for the filetype.
3. Run it manually with `<leader>cl`.

---

## Adding a New Language

1. **Server:** add it to the `servers` list in `lua/plugins/lsp.lua`. That installs it through Mason and enables it.
2. **Overrides (optional):** create `after/lsp/<server>.lua` returning only the fields that differ from
   nvim-lspconfig's `lsp/<server>.lua`.
3. **Formatter (optional):** add it to `formatters_by_ft` in `lua/plugins/conform.lua`, and to the Mason list in
   `lua/plugins/mason.lua`.
4. **Linter (optional):** add it to `linters_by_ft` in `lua/plugins/nvim-lint.lua`, and to the Mason list. Do not lint
   with a tool the server already runs.
5. **Test fixture:** add a sample with deliberate errors under `test/<language>/`.
6. **Smoke case:** add a row to `test/smoke/cases.lua` with the exact client set, the parser and the expected
   diagnostics, then run `./scripts/smoke --only <name>`.

---

## Philosophy

1. **Modern & Fast:** Prefer new-generation tools (ruff, biome) over legacy ones
2. **Single Responsibility:** Each tool has a clear role (no overlaps)
3. **Minimal Configuration:** Use sensible defaults, configure only when needed
4. **Auto-install:** Mason handles installation automatically
5. **Lazy Load:** Heavy plugins load only when needed (via lazy.nvim)

---

**For detailed keybindings, see `KEYMAPS.md`**  
**For performance analysis, see `PERFORMANCE.md`**
