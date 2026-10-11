# Testing & Quality Assurance

This document describes the testing infrastructure and quality gates for the Neovim configuration.

**Last updated:** 2026-10-10

---

## Quick Start

```bash
# Run complete health check
./scripts/health-check

# Run quality gate (before commits)
./scripts/quality-gate

# Open a real buffer per language and assert on what Neovim does
./scripts/smoke --seed-from ~/.local/share/nvim   # first run per Neovim version
./scripts/smoke

# Install the git hooks (sets core.hooksPath, so each worktree runs its own scripts)
./scripts/install-hooks
```

---

## Testing Scripts

### 1. Health Check (`./scripts/health-check`)

Comprehensive health check of the entire configuration. It exits 1 when any check fails, so it can gate a script.

**What it checks:**

- ✓ Neovim version: fails below `NVIM_MIN`, warns when it differs from `NVIM_PIN` (both in `scripts/versions.env`)
- ✓ Required CLI tools: `cc`, `curl`, `tar`, `git`, `luacheck`, `stylua`, `rg`, `fd`, `node` (at least `NODE_MIN`), and
  the `tree-sitter` CLI once `TREE_SITTER_MIN` is set
- ✓ Luacheck (0 warnings/errors in `lua/`, `after/`, `test/smoke/`)
- ✓ Neovim starts cleanly (`scripts/smoke --startup-only`)
- ✓ Startup performance: median of 5 runs after a warm-up, fails above 500ms, warns above the 150ms target
- ✓ `:checkhealth vim.deprecated vim.lsp` has no ERROR line
- ✓ Plugin directory exists
- ✓ Config file structure
- ✓ Documentation files

By default the startup and `:checkhealth` checks run against this machine's real config and data directories, which is
what you start every day. `--isolated` runs them in the smoke environment (`SMOKE_HOME`) instead, for agents and CI.
`VERSIONS_ENV=<file>` reads another versions file, and `NVIM=<path>` selects the binary.

**When to run:**

- After making significant changes
- After updating plugins
- When troubleshooting issues
- Weekly maintenance check

**Example output:**

```
🏥 Neovim Configuration Health Check
====================================

1. Checking Neovim version...
   NVIM v0.11.6
   ✓ Neovim 0.11.6 (pinned 0.11.6)

2. Checking required CLI tools...
   ✓ cc: Apple clang version 21.0.0 (clang-2100.1.1.101)
   ...
   ✓ node: v22.22.0

3. Running luacheck...
Total: 0 warnings / 0 errors in 69 files
   ✓ Luacheck passed (0 warnings)

4. Testing Neovim loads (scripts/smoke --startup-only)...
   ✓ Neovim starts cleanly

5. Measuring startup performance...
   Runs: 138.608 137.031 135.551 128.674 142.445 ms
   Median startup time: 137.031ms
   ✓ Under 150ms target
...

🎉 Health check passed!
```

That is `./scripts/health-check --isolated` on 2026-10-11 (about 5 seconds, load average about 11).

---

### 2. Quality Gate (`./scripts/quality-gate`)

Fast quality gate for pre-commit/pre-push checks. A missing tool fails the gate instead of passing it.

**What it checks:**

- ✓ Formatting (`stylua --check .`, by exit code)
- ✓ Linting (`luacheck` on `lua/`, `after/` and `test/smoke/`)
- ✓ Startup in the isolated smoke environment (`scripts/smoke --startup-only`): every module loads, no unexplained
  message, every configured formatter and linter is available, and no deprecated API in the config's own files

**When to run:**

- **Before every commit** (recommended)
- Before pushing to remote
- After making code changes
- As part of CI/CD pipeline

**Exit codes:**

- `0` - All checks passed
- `1` - One or more checks failed

**Example output:**

```
🔒 Running complete quality gate...

1️⃣  Checking formatting (stylua)...
   ✓ Formatting correct

2️⃣  Running linter (luacheck)...
   ✓ Luacheck passed

3️⃣  Testing Neovim starts cleanly (scripts/smoke --startup-only)...
   ✓ Neovim starts cleanly

🎉 Quality gate passed!
```

---

### 3. Git Hooks (Automatic Quality Assurance)

Automated quality checks that run before commits and pushes.

**Installation (one-time setup):**

```bash
./scripts/install-hooks
./scripts/smoke --seed-from ~/.local/share/nvim   # once per Neovim version, for the smoke gate
```

`install-hooks` sets `git config core.hooksPath scripts`. Git then runs `scripts/pre-commit` and `scripts/pre-push` from
the checkout being committed, so a worktree gates its own files rather than the main checkout's. Uninstall with
`git config --unset core.hooksPath`.

#### Pre-Commit Hook (`./scripts/pre-commit`)

Runs automatically before every `git commit` (about 3.5 seconds, measured 2026-10-11).

**What it checks:**

- ✓ Quality gate (stylua, luacheck, smoke startup check)
- ✓ Trailing whitespace in staged .lua files
- ⚠ Debug print statements (warning only)

**Behavior:**

- **Blocks commit** if quality gate or trailing whitespace check fails
- **Warns but allows commit** for debug statements
- **Staged files only** are checked for git-specific issues

**Bypass (not recommended):**

```bash
git commit --no-verify -m "message"
```

#### Pre-Push Hook (`./scripts/pre-push`)

Runs automatically before every `git push` (about 45 seconds on 0.11.6, measured 2026-10-11; longer on a busy machine).

**What it checks:**

- ✓ Quality gate (stylua, luacheck, smoke startup check)
- ✓ The full smoke gate (`scripts/smoke`): a real buffer per language

**Behavior:**

- **Blocks push** if the quality gate or the smoke gate fails
- An environment the smoke gate cannot run in (exit 2, not bootstrapped) blocks the push too; it is never skipped
- Ensures only quality code reaches remote repository

**Bypass (not recommended):**

```bash
git push --no-verify
```

**Testing the gates themselves:** `./scripts/gate-selftest` also runs the gate scripts against known-false preconditions:
`quality-gate` with stylua or luacheck missing from `PATH`, `quality-gate` on a copy with an `error()` in
`lua/options.lua`, `quality-gate` with `GIT_DIR` exported (as git does for hooks) on a copy with a formatting break, and
`health-check` with an `nvim` shim reporting 0.11.6 or a `tree-sitter` shim reporting 0.25.0 against a stricter
`versions.env`. Each must exit 1 with the matching message.

---

### 4. Smoke Gate (`./scripts/smoke`)

The only check that opens real buffers. It starts this config in an isolated environment, opens one sample file per daily
language from `test/`, and asserts on runtime state: which LSP clients attached and with which settings, which tool
reported which diagnostics, treesitter, keymaps, lint, and every message printed on the way. Headless startup alone hides
almost every failure this config has had, so the gate drives buffers instead.

**Isolation.** Each run uses `SMOKE_HOME` (default `~/.cache/nvim-smoke/<nvim version>/`) with its own config, data,
state and cache directories. The working tree is copied into `SMOKE_HOME/config/nvim` on every run, without `.git` (a
fresh `git init` keeps root markers working), because lazy rewrites `lazy-lock.json` and fixtures break the copy. The
gate never writes to `~/.local/share/nvim` and refuses a `SMOKE_HOME` that resolves to it.

**First run, once per Neovim version:**

```bash
./scripts/smoke --seed-from ~/.local/share/nvim   # APFS/reflink clone of this machine's lazy/, mason/ and site/
./scripts/smoke --bootstrap                       # or: install from lazy-lock.json and Mason (network, for CI)
```

An environment with neither exits 2 with these instructions instead of installing plugins at startup.

**Everyday use:**

```bash
./scripts/smoke                          # every case
./scripts/smoke --only python,lua        # selected cases (names from test/smoke/cases.lua)
./scripts/smoke --startup-only           # startup, dashboard and tool checks only
./scripts/smoke --nvim /path/to/nvim     # another Neovim binary (or NVIM=...)
./scripts/smoke --no-xfail               # show known failures as failures
./scripts/smoke --strict                 # plugin deprecations fail instead of warn
./scripts/smoke --fixture init-error     # break the copied config with test/smoke/fixtures/<name>.lua first
./scripts/smoke --fresh --seed-from ~/.local/share/nvim   # delete SMOKE_HOME and start over
./scripts/smoke --nvim /opt/homebrew/bin/nvim --expect-guard  # Neovim < 0.12: check init.lua stops at its guard
```

The config needs Neovim 0.12. On an older Neovim, `init.lua` prints one ERROR and stops before lazy.nvim loads, so it
never installs plugins or rewrites `lazy-lock.json`. Every other mode fails there; `--expect-guard` passes only when the
guard did exactly that.

`--fresh` only deletes a directory the script made: empty, marked with `.nvim-smoke-home`, or holding only its own layout
(`config/`, `data/`, `state/`, `cache/`, reports). Pointing `--home` at anything else (`~`, a repo) exits 2.

**What it checks:**

| Scope | Check |
| --- | --- |
| Startup | Every module `init.lua` requires is loaded. The enabled LSP configs are exactly `cases.enabled_servers` (`startup:enabled`). Every message is explained (below). No WARN or ERROR notify. No deprecated API called from the config. `lazy-lock.json` unchanged by the run |
| Dashboard | Rendering the alpha dashboard prints nothing unexplained |
| Tools | Every conform formatter is known and available, every nvim-lint linter is defined and executable |
| Each case | The exact LSP client set, pinned server settings, diagnostic counts per owner (`lsp:<client>` or the linter name), no finding reported by two owners, cmp-nvim-lsp capabilities on every client, a buffer-local `<leader>li` where a client supports inlay hints, navic where a client supports document symbols, the treesitter parser in use, `af`/`if` textobjects, folds, and real LSP requests (definition, hover, prepareRename, codeAction) for Python and Lua |
| Case checks | Per-case `check` functions in `cases.lua`. Python: textobjects (`vaf`, buffer-local `]m`), the native treesitter foldexpr, `<leader>tc`/`tp` and the removed master-era keys (`treesitter:keymaps`), `:LspRestart` keeping settings, basedpyright on push diagnostics (`python:pull`), `grr` jumping through Telescope, aerial finding symbols, `gra` opening a Telescope picker (`python:ui-select`), Telescope's history database inside the data dir (`python:telescope`), project root cwd and the `<Tab>p`/`<localleader>fs` session pickers, the Python host (uv's `pynvim` or none) and the disabled Node host, and the keymap docs (below). Lua: `gr`/`gi` unmapped, `grr`/`gri`/`<leader>cl`/`<leader>cL` (`keymaps:defaults`), no buffer with filetype `on`, no `nil` in the statusline, noice owning LSP progress (`config:*`). TypeScript and TSX: native `gcc`/`gco`/`gcO`, the comment style per node, and no nvim-ts-context-commentstring. Markdown: `<leader>x` calling `vim.ui.open`, glow gone, no folds, and its keymap docs. SQL: the ftplugin's `]]`, formatting on `<leader>cf` but not on save |
| Keymap docs | `docs/KEYMAPS.md` against the running config, both ways: every key in a `Key \| Mode` table is mapped in its modes (`keymaps:documented`; the Markdown section in the Markdown buffer, the rest in the Python buffer), every mapping with a desc under `<Leader>`, `<LocalLeader>`, `<Tab>`, `g` or an F-key is documented (`keymaps:undocumented`), every label in `lua/plugins/whichkey.lua` names a mapping (`keymaps:whichkey`), and gitsigns' `<Leader>shs`/`shr` call gitsigns (`keymaps:gitsigns`). Vim built-ins the doc mentions (`gd`, `gD`, `<C-o>`) are exempt |
| Mundo | Only where uv's `pynvim` is installed (`$UV_TOOL_DIR`, else `$XDG_DATA_HOME/uv/tools`): `:MundoToggle` opens its window. `scripts/smoke` passes this machine's tool directory into the sandbox as `UV_TOOL_DIR` |

Headless Neovim never fires `UIEnter`, so lazy never fires `VeryLazy`. The gate fires `UIEnter` itself, so noice,
nvim-notify, lualine, navic and the other `VeryLazy` plugins load as they do in a terminal.

**Messages fail closed.** Messages land in `:messages`, in stderr, or only in noice's history, depending on the Neovim
version and on whether noice has attached. The gate reads all three. Each line must be a notify the gate recorded (judged
by level), an Nvim deprecation notice it recorded (judged by caller), or an entry in `test/smoke/allow.lua`. Anything
else fails, attributed to the case that was running.

`test/smoke/preinit.lua` records notifies and deprecations. It loads with `--cmd`, before `init.lua`, and serves
`vim.notify` through the `vim` metatable, so the replacements nvim-notify and noice install are recorded too. A
deprecated API called from the config fails. One called from a plugin warns, and fails with `--strict`. Where Neovim
finds no clipboard tool (a headless Linux runner), it also sets an in-memory `g:clipboard`, so a yank into the
`unnamedplus` register does not print "clipboard: No provider".

**Known failures.** `test/smoke/xfail.lua` lists today's failures, each with its finding ID and an optional Neovim
version. A matching failure prints as `XFAIL` and does not fail the run. The list is strict: an entry that no longer
fails, or that only matches failures another entry also matches, fails the run. So the change that fixes a finding must
delete its entries, and deleting any entry while its failure remains turns the run red. An entry is judged stale only
when its scope ran: a check that runs on some machines only (Mundo) reports under its own scope and calls `t.scope(name)`
when it runs.

**Exit codes and report.** `0` pass, `1` assertion failed, `2` environment error, `3` timeout (a bash watchdog enforces
`--timeout`, default 300 s). Results go to `SMOKE_HOME/summary.txt` (printed) and `SMOKE_HOME/report.json`.

**Proving the gate can fail.** `./scripts/gate-selftest` runs the gate once per fixture in `test/smoke/fixtures/` and
checks each produces its expected failure. It passes `--home` and `--nvim` through to every run.

| Fixture               | Breaks the copied config by                                     | Expected failure       |
| --------------------- | --------------------------------------------------------------- | ---------------------- |
| `init-error`          | `error()` in `lua/options.lua`                                  | `startup:modules`      |
| `late-init-error`     | `error()` at the end of `init.lua`                              | `startup:messages`     |
| `broken-lsp-setting`  | `after/lsp/basedpyright.lua` with `strict`                      | `python:settings`      |
| `removed-parser`      | mapping python to a parser that does not exist                  | `python:treesitter`    |
| `notify-error`        | an ERROR notify after noice replaced `vim.notify`               | `startup:notify`       |
| `config-deprecated`   | calling `vim.lsp.get_active_clients()`                          | `startup:deprecated`   |
| `extra-client`        | attaching lua_ls to python buffers                              | `python:clients`       |
| `silent-linter`       | a luacheck that prints nothing                                  | `lua:diags`            |
| `double-linter`       | nvim-lint running shellcheck on bash, which bashls already runs | `bash:diags`           |
| `documented-unmapped` | a `docs/KEYMAPS.md` row for a key nothing maps                  | `keymaps:documented`   |
| `undocumented-map`    | a `<leader>` mapping with a desc that `docs/KEYMAPS.md` lacks   | `keymaps:undocumented` |
| `hang`                | a busy loop                                                     | exit code `3`          |

**Adding a language:** put a sample with deliberate errors under `test/<language>/`, add a row to `test/smoke/cases.lua`
with the expected clients, parser and diagnostics, and run `./scripts/smoke --only <name>`.

---

## Manual Testing Commands

### Formatting

```bash
# Check formatting (don't modify)
stylua --check .

# Fix formatting
stylua .
```

### Linting

```bash
# Lint every Lua file the gates lint
luacheck lua/ after/ test/smoke

# Lint with verbose output
luacheck lua/ after/ test/smoke --formatter plain

# Lint single file
luacheck lua/plugins/telescope.lua
```

### Neovim Load Testing

```bash
# Startup in the isolated smoke environment: init errors, messages, tools
./scripts/smoke --startup-only

# Full health check (interactive)
nvim +checkhealth
```

A bare `nvim --headless +qa` exits 0 even when `init.lua` raises an error, so it is not a load test.

### Startup Performance

```bash
# Measure startup time
nvim --startuptime startup.log --headless +qa
grep "NVIM STARTED" startup.log

# Interactive profiling
nvim +StartupTime

# View slowest operations
cat startup.log | awk '{if ($2 > 1) print $0}' | head -20
```

---

## Continuous Integration

[`.github/workflows/ci.yml`](../.github/workflows/ci.yml) is the Linux parity gate. It runs on every pull request, on
every push to `main`, on demand (`workflow_dispatch`), and weekly. Each run uses a fresh runner, on two legs:
`ubuntu-latest` (x86_64) and `ubuntu-24.04-arm` (aarch64).

1. `scripts/bootstrap-linux` installs what a Linux VM gets: Neovim, the tree-sitter CLI, stylua, uv, node when the
   runner's is too old, and the apt toolchain, at the versions in `scripts/versions.env`.
2. The checkout is linked as `~/.config/nvim`, and the data dir `~/.local/share/nvim` (plugins, Mason packages, parsers)
   is restored from the cache. The key covers `lazy-lock.json`, `scripts/versions.env` and the Mason, LSP and treesitter
   plugin files, so any change to them starts clean.
3. `scripts/sync-plugins`, as on a VM (below).
4. `stylua --check .` and `luacheck lua/ after/ test/smoke`.
5. `scripts/smoke --seed-from ~/.local/share/nvim`. The weekly run adds `scripts/smoke --strict`, so plugin deprecations
   stay visible.
6. `scripts/gate-selftest`.

When a step fails, the run uploads the smoke home's report, summary, logs and LSP log as an artifact named
`smoke-<runner>`.

## Plugin Sync (`./scripts/sync-plugins`)

Brings a machine's plugins, Mason packages and parsers in line with the config, on macOS, Linux and CI. It works on the
config Neovim loads (`~/.config/nvim`), which must be this checkout, and refuses to run from anywhere else, and it
refuses an uncommitted `lazy-lock.json`. It restores every plugin to its locked commit, twice if needed: a start that
installs a missing plugin makes lazy rewrite every lockfile entry from the commits it found installed, so the script puts
the committed lockfile back and restores again. A plugin lazy cannot move (local changes, a checkout that fails on a new
submodule) is removed and installed again at its pin. It then deletes the parser binaries nvim-treesitter `master` left
in `lazy/nvim-treesitter/parser*`, installs the Mason packages and parsers, runs `Lazy clean`, and fails if
`lazy-lock.json` changed. Exit codes: `0` in sync, `1` a step failed, `2` refused.

---

## Quality Standards

### Zero Tolerance

The following must **always pass**:

- ✅ `luacheck lua/ after/ test/smoke` → 0 warnings, 0 errors
- ✅ `stylua --check .` → no formatting needed
- ✅ Neovim loads without errors
- ✅ `./scripts/smoke` → `SMOKE PASS` (known failures only in `test/smoke/xfail.lua`)

### Performance Targets

- **Startup time:** <150ms (target), <500ms (acceptable)
- **Plugin count:** <50 (target); 85 today (`lazy-lock.json`)
- **Config size:** <10MB

---

## Troubleshooting

### "Luacheck failed"

1. **View errors:**

   ```bash
   luacheck lua/ after/ test/smoke
   ```

2. **Common issues:**
   - Undefined global variables → Add to `.luacheckrc`
   - Unused variables → Prefix with `_` or remove
   - Line too long → Break into multiple lines (max 150 chars)

### "Formatting check failed"

1. **Auto-fix:**

   ```bash
   stylua .
   ```

2. **Check specific file:**
   ```bash
   stylua --check lua/plugins/telescope.lua
   ```

### "Neovim failed to load"

1. **Check syntax errors:**

   ```bash
   luacheck lua/ after/ test/smoke
   ```

2. **View error details:**

   ```bash
   nvim --headless +qa 2>&1
   ```

3. **Check logs:**
   ```bash
   nvim --headless "+lua print(vim.lsp.log.get_filename())" +qa
   ```

---

## Best Practices

### Before Committing

```bash
# 1. Format code
stylua .

# 2. Run quality gate
./scripts/quality-gate

# 3. Commit if passed
git add .
git commit -m "Your message"
```

### Weekly Maintenance

```bash
# Full health check
./scripts/health-check

# Update plugins
nvim +Lazy update

# Check for issues
nvim +checkhealth
```

### After Major Changes

```bash
# 1. Health check
./scripts/health-check

# 2. Manual testing
nvim  # Open and test functionality

# 3. Performance check
nvim --startuptime startup.log --headless +qa
cat startup.log | grep "NVIM STARTED"
```

---

## Maintenance Schedule

| Frequency     | Task                               | Command                  |
| ------------- | ---------------------------------- | ------------------------ |
| Before commit | Quality gate                       | `./scripts/quality-gate` |
| Daily         | Quick health check                 | `./scripts/health-check` |
| Weekly        | Full health check + plugin updates | `nvim +Lazy update`      |
| Monthly       | Performance audit                  | Check `PERFORMANCE.md`   |
| Bi-annually   | Full review                        | Review all config files  |

---

**See also:**

- `AGENTS.md` - Development conventions
- `PERFORMANCE.md` - Startup performance analysis
- `KEYMAPS.md` - Keymap reference
- `LSP.md` - Language tooling documentation
