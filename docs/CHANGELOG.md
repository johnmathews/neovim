# Changelog

All notable changes to this Neovim configuration will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html) principles.

## [Unreleased]

Cleanup after the first `:checkhealth` on 0.12.6.

### Changed

- **`<leader>F`** reveals the current file in Finder (`open -R`); on Linux it opens the file's folder with `vim.ui.open`.
- **`<leader>X`** (Typora) is buffer-local to Markdown buffers (`ftplugin/markdown.vim`), no longer global.
- **`<leader>x`** is now only Trouble's prefix (`<leader>xx`, `xX`, `xL`, `xQ`); the "open in default app" mapping is
  gone.

### Fixed

- `:checkhealth` warnings:
  - noice: the `regex` parser is in the treesitter list (19 parsers);
  - lazy: luarocks support is off (`rocks = { enabled = false }`), since no plugin needs it;
  - vim.lsp: yamlls and marksman list only the filetypes Neovim sets (`after/lsp/yamlls.lua`, new
    `after/lsp/marksman.lua`);
  - vim.lsp: every client asks for utf-16 positions, so ruff and basedpyright no longer mix encodings on Python buffers.
- `scripts/sync-plugins` killed mid-run (a timeout, Ctrl-C, a closed terminal) left `lazy-lock.json` modified. Bash ran
  its EXIT trap with `$?` = 0, so the restore was skipped and every retry refused the uncommitted lockfile. It now puts
  the lockfile back and exits 129, 130 or 143; gate-selftest's `sync-killed` case covers it.

## [2.0.0] - 2026-10-11

The Neovim 0.12 release: Stage B of the upgrade (the cutover) and Stage A (everything that worked on both versions).
Moving a machine: `docs/UPGRADE-0.12.md`.

### Breaking

- **Neovim 0.12 is required.** `init.lua` stops on anything older with one ERROR ("config requires Neovim 0.12.6, see
  docs/UPGRADE-0.12.md"), before lazy.nvim loads, so an old Neovim never installs plugins or rewrites `lazy-lock.json`.
  `scripts/versions.env`: `NVIM_MIN=0.12.0`, `NVIM_PIN=0.12.6`.
- **nvim-treesitter `main`** (F2, F3): the tree-sitter CLI (0.26.1+) and a C compiler are required to build parsers,
  which now live in `site/parser/`. `lua/plugins/treesitter.lua` installs the missing ones from its exported list (adds
  bash, sql, vim, vimdoc), starts highlighting, native folds (python, yaml, lua), indent and buffer-local textobjects in
  one `FileType` autocmd, and maps zsh to the bash parser (F30). The parsers `master` built in
  `lazy/nvim-treesitter/parser*` are stale; `scripts/sync-plugins` deletes them.
- **Node 20** is the minimum (`NODE_MIN`): Mason's markdownlint-cli needs it (F32).
- **Keys removed** (approved): `<leader>df`/`<leader>dF` (peek definition; `gd` covers it) and the textobjects moves
  `]o ]s ]z ]d [d`, which restores Vim's spell and fold jumps, 0.12's diagnostic jumps and vim-unimpaired's `]o`.

### Added

- **`scripts/bootstrap-linux`**: Ubuntu 24.04+ and Debian 13+ setup. Neovim 0.12.6, the tree-sitter CLI, stylua, uv and
  Node.js from official release assets, each checked against a sha256 in `scripts/versions.env`; the apt toolchain and
  uv's pynvim. It refuses glibc below 2.39 and names any `nvim` or `tree-sitter` that shadows the install.
- **`scripts/sync-plugins`**: plugins to `lazy-lock.json`, Mason packages and parsers installed, `Lazy clean`, and a
  clean lockfile at the end, on macOS, Linux and CI. It restores the committed lockfile after lazy rewrites it,
  reinstalls any plugin lazy cannot move, and refuses to sync a config that is not its own checkout.
- **Linux CI** (`.github/workflows/ci.yml`, F12): `ubuntu-latest` and `ubuntu-24.04-arm` on every pull request, push to
  `main`, on demand and weekly (with `--strict`): bootstrap, sync, lint, the smoke gate and its self-test.
- **Keymap docs check** (`keymaps:*`, F20): `docs/KEYMAPS.md` against the running config, both ways, plus which-key's
  labels. Two new self-test fixtures prove each direction fails (18 cases now).
- `scripts/smoke --expect-guard` checks the version guard on an old Neovim; `--seed-from` also clones `site/`.
- `docs/UPGRADE-0.12.md`, the one-time cutover runbook.
- `<leader>tc` and `<leader>tp` run the built-in `:Inspect` and `:InspectTree`.

### Changed

- **telescope-ui-select replaces dressing.nvim** (F18): `vim.ui.select`, code actions included, opens a Telescope
  dropdown; `vim.ui.input` is native, rendered by noice.
- **aerial** moves to `28fe6e8`, which needs 0.12 (F4); it outlined nothing and threw in every buffer on the old commit.
- **bashls owns zsh lint** (F36): bash-language-server 5.8 shellchecks zsh, so nvim-lint's `shellcheck_zsh` is gone.
  Older bash-language-server needs `:MasonInstall bash-language-server`.
- Harpoon's lazy-load key is `gm` (add), not the unmapped `ga`.

### Fixed

- **gitsigns `<Leader>shs`/`<Leader>shr`** (#7): they typed `Gitsigns: stage_hunk` into the buffer. They stage and reset
  the hunk now (Visual: the selected lines).
- **lazy.nvim's lockfile entry** (F33): the bootstrap clone checks out the locked commit, so a fresh install no longer
  rewrites it.
- **Telescope history database** (F35): `stdpath("data")` instead of a hard-coded `~/.local/share/nvim` path, with its
  directory created; the first picker on a fresh machine failed.
- **Keymap docs** (#8): `docs/KEYMAPS.md`, the README tour tables and `docs/LSP.md` corrected against the running config.
- Gate checks that depended on the machine (F34): ruff's diagnostic count, the `extra-client` fixture, a headless
  runner's missing clipboard.

### Removed

- dressing.nvim, nvim-ts-context-commentstring (native `gc` reads the jsx query's commentstring), the `snacks.nvim`
  lockfile entry with no spec, and `test/smoke/xfail.lua`'s last rows: the gate has no known failures.

### Added (Stage A)

- **Smoke gate** (`scripts/smoke`, `test/smoke/`): opens one real buffer per daily language in an isolated Neovim
  (`SMOKE_HOME`, never `~/.local/share/nvim`) and asserts on LSP clients and settings, diagnostics per owner, treesitter,
  textobjects, folds, keymaps, lint, LSP requests and every message. Known failures live in `test/smoke/xfail.lua` with
  their finding IDs. See `docs/TESTING.md`.
- **Gate self-test** (`scripts/gate-selftest`, `test/smoke/fixtures/`): ten known-bad configs that must each fail the
  gate with a specific check ID.
- Test samples for TypeScript, SQL, JSON and TOML. The zsh sample moved to `test/zsh/test_sample.zsh`.

### Fixed (Stage A)

- **LSP settings apply again** (F1): mason-lspconfig v2 ignores `handlers`, so no per-server setting, `on_attach`, navic,
  `<leader>li` or cmp capability had applied. Servers now use native `vim.lsp.config`: capabilities through
  `vim.lsp.config("*")`, overrides in `after/lsp/<server>.lua`, one `LspAttach` autocmd for navic and `<leader>li`.
  basedpyright runs in `basic` mode again (18 diagnostics on the sample become 4).
- **Only the listed servers start** (F13): `automatic_enable = false` plus an explicit `vim.lsp.enable` list of 10
  servers. sqls, stylua, eslint, biome and the other Mason servers no longer start.
- **basedpyright diagnostics on 0.12** (F31): on 0.12 basedpyright switched to pull diagnostics, and about one buffer in
  four opened without them. `after/lsp/basedpyright.lua` keeps it on push, as on 0.11.
- **zsh is shellchecked again** (F5): `shellcheck_zsh` is now a copy of nvim-lint's shellcheck linter, so it no longer
  rewrites the shared linter's args, and it asks for `json1`, the format nvim-lint parses.
- **markdownlint runs again** (F6): every markdown lint run had failed with "expected table, got function". The linter is
  now a function that returns a copy with list `args`, `--stdin` restored, and print mode's `--disable MD013` kept.
- **One owner per lint finding** (F13): nvim-lint no longer runs ruff (the ruff LSP server reports it) or shellcheck on
  sh and bash (bashls runs it).
- **conform options** (F25): `default_format_opts = { lsp_format = "fallback" }` replaces the deprecated `lsp_fallback`,
  and YAML no longer lists the unknown formatter `lsp`.
- **Statusline `nil`** (F27): lualine's symbols component returned `nil`, which rendered as the text "nil".
- **`filetype = "on"`** in `lua/options.lua` set the option, not the `:filetype on` command, so the empty startup buffer
  had the filetype `on`. Neovim enables filetype detection by default; the line is gone.

- **Gate scripts, from the Stage A review:** `scripts/smoke` no longer leaves its watchdog's `sleep` holding the caller's
  output open for the whole timeout (`smoke | tail` waited 300 s); `--fresh` refuses to delete a directory the script did
  not make; the smoke gate passes this machine's uv tool directory in, so the Python-host and Mundo checks run where
  `pynvim` is installed; `gate-selftest` works under macOS's bash 3.2; pre-commit checks the staged content for trailing
  whitespace instead of the working tree.
- **`gco`/`gcO` in a buffer with no commentstring** open a plain line instead of leaving a stray `x`.

### Changed (Stage A)

- **Floating window borders**: `winborder = "rounded"` replaces the `open_floating_preview` override. The cmp menu and
  the which-key popup now take the rounded border too.
- **Gates fail closed**: `quality-gate` fails when stylua or luacheck is missing, reads stylua's exit code, lints `lua/`,
  `after/` and `test/smoke/`, and replaces its load test with `scripts/smoke --startup-only`, which also scans the config
  for deprecated APIs. `health-check` exits 1 on any failure, enforces `scripts/versions.env`, takes the median of five
  startups, runs `:checkhealth vim.deprecated vim.lsp`, and has an `--isolated` mode.
- **Hooks per worktree**: `install-hooks` sets `core.hooksPath` to `scripts/`, so a worktree commit runs that worktree's
  gate. pre-push runs the full smoke gate after `quality-gate`.

- **Startup is about 140 ms, down from about 400 ms** (F11): `init.lua` no longer shells out to `poetry` and
  `neovim-node-host` on every launch. `vim.loader.enable()` moved to its first line.
- **Python provider** (F22): `g:python3_host_prog` is the `pynvim` tool from `uv tool install pynvim` when it exists,
  instead of `poetry` or a hard-coded pyenv 3.10.12 path. The Node provider is disabled; no remote plugin uses it.
- **`<leader>x`** opens the current file with `vim.ui.open`, which works on macOS (`xdg-open` does not exist there).
- **Deprecated and private APIs** (F15): `vim.lsp.log.set_level`, `vim.uv`, `nvim_echo`, and a choice-popup size the
  config computes instead of the private `_make_floating_popup_size`.
- **`grr` and `gri`** (F16) open the Telescope references and implementations pickers. They replace the global `gr` and
  `gi`, which made Neovim wait for the other `gr*` defaults (`gra`, `grn`, `grt`) and hid Vim's `gi`. The Trouble LSP
  panel moves from `<leader>cl`, which it shared with "Run lint", to `<leader>cL`.
- **SQL formats with sqlfluff** on `<leader>cf` only, never on save. Without a `.sqlfluff` file the dialect is postgres
  (bigquery for `.bq`).
- Mason also installs sqlfluff, yamlfmt, jq, shellcheck and jsonlint, which the format and lint config already used.

- **Project root without project.nvim** (F14): a `BufEnter` autocmd in `lua/autocmd.lua` moves cwd to the nearest root
  marker with `vim.fs.root`, with the same markers and excluded path. `<Tab>p`, the dashboard's `p` button and
  `<localleader>fs` open `:AutoSession search` (the dashboard button now reads "Find session").

- **Docs** (F26, F20): `TEST_RESULTS.md`, `TESTING_CHANGELOG_GUIDE.md` and `IMPROVEMENTS.md` moved to `docs/archive/`
  with a Status header naming the doc that replaced each. README drops the 2025-11-08 test results, and its startup,
  plugin-count and lazy-loading claims match the code again. AGENTS.md lists the optional CLIs and lints the same paths
  as `quality-gate`. `.engineering-team/` is git-ignored.

### Removed (Stage A)

- **project.nvim** (F14, F18): unmaintained since 2023, and it calls `vim.lsp.buf_get_clients()`, which 0.12 removed
  apart from a shim. **session-lens** (F18): merged into auto-session.
- **Comment.nvim** (F18): Neovim's native `gc` replaces it, with the same keys. `gci` moved to `lua/mappings.lua`, `gco`
  and `gcO` are re-implemented on top of `gcc`, and `gcA` is gone. nvim-ts-context-commentstring stays, loaded on the
  first commentstring lookup. The Dockerfile override went too: the runtime ftplugin sets `# %s`.
- **glow.nvim** (F18, archived): `<leader>mg`, `:Glow` and the non-buffer-local `<Leader>p` from `ftplugin/markdown.vim`.
  The `glow` CLI is no longer a requirement.
- **vim-numbers** (F18, F16): its visual and operator-pending `an`/`in` hid 0.12's built-in treesitter node selection.
- **lualine-lsp-progress** (F18): archived, and only referenced by a commented-out component.
- **fidget.nvim** (F25): noice already shows LSP progress, and the installed fidget called the deprecated
  `vim.lsp.get_active_clients`. **lsp_signature.nvim** (F25): installed but never set up.
- **Config files nothing loaded** (F25): `lua/colorscheme.lua` and
  `lua/plugins/{lsp-colors,fzf,filetype,monokai,vimtex, javascript,asyncrun}.lua`. Neovim already maps `uv.lock` to toml,
  so `filetype.lua` added nothing.
- `test/test_lsp.sh`: it ran bare `nvim` against the real data directory and passed when a server name appeared anywhere
  in the output. The smoke gate covers everything it checked.

## [1.2.0] - 2025-11-08

### Added

- **Markdown Preview (Glow)**: Enabled [glow.nvim](https://github.com/ellisonleao/glow.nvim) with lazy-loading,
  `<leader>mg` keymap, and detection of the `glow` CLI (`lua/plugins.lua`, `lua/plugins/glow.lua`,
  `lua/plugins/whichkey.lua`).
- **Documentation**: Updated `README.md` and `docs/KEYMAPS.md` with Glow usage instructions, installation requirements,
  and keymap references.

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

- **Test Infrastructure**: Created `test/` directory with sample files for 6 languages (Python, Lua, JavaScript, YAML,
  Markdown, Bash)
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
