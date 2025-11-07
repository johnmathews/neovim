# Testing & Quality Assurance

This document describes the testing infrastructure and quality gates for the Neovim configuration.

**Last updated:** 2025-01-13

---

## Quick Start

```bash
# Run complete health check
./scripts/health-check

# Run quality gate (before commits)
./scripts/quality-gate

# Install pre-commit hook (optional)
ln -s ../../scripts/pre-commit .git/hooks/pre-commit
```

---

## Testing Scripts

### 1. Health Check (`./scripts/health-check`)

Comprehensive health check of the entire configuration.

**What it checks:**
- ✓ Neovim version
- ✓ Required CLI tools (luacheck, stylua, rg, fd, node)
- ✓ Luacheck (0 warnings/errors)
- ✓ Neovim loads successfully
- ✓ Startup performance (<150ms target)
- ✓ Plugin directory exists
- ✓ Config file structure
- ✓ Documentation files

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
   NVIM v0.11.4
   ✓ Neovim is installed

2. Checking required CLI tools...
   ✓ luacheck: Luacheck 1.2.0
   ✓ stylua: stylua 0.20.0
   ✓ rg: ripgrep 14.1.0
   ...

🎉 Health check complete!
```

---

### 2. Quality Gate (`./scripts/quality-gate`)

Fast quality gate for pre-commit/pre-push checks.

**What it checks:**
- ✓ Formatting (stylua --check)
- ✓ Linting (luacheck)
- ✓ Neovim loads

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

3️⃣  Testing Neovim loads...
   ✓ Neovim loads successfully

🎉 Quality gate passed!
```

---

### 3. Git Hooks (Automatic Quality Assurance)

Automated quality checks that run before commits and pushes.

**Installation (one-time setup):**
```bash
./scripts/install-hooks
```

This installs two hooks:

#### Pre-Commit Hook (`./scripts/pre-commit`)
Runs automatically before every `git commit` (fast, <10 seconds).

**What it checks:**
- ✓ Luacheck (0 warnings/errors)
- ✓ Formatting (stylua --check)
- ⚠ Trailing whitespace (warning)
- ⚠ Debug print statements (warning)
- ✓ Neovim loads

**Behavior:**
- **Blocks commit** if critical checks fail (luacheck, formatting, load test)
- **Warns but allows commit** for minor issues (debug statements)
- **Automatically staged files only** are checked

**Bypass (not recommended):**
```bash
git commit --no-verify -m "message"
```

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
# Lint all Lua files
luacheck lua/

# Lint with verbose output
luacheck lua/ --formatter plain

# Lint single file
luacheck lua/plugins/telescope.lua
```

### Neovim Load Testing

```bash
# Quick load test (headless)
nvim --headless "+lua print('Load test OK')" +qa

# Load test with timeout
timeout 10 nvim --headless +qa

# Full health check (interactive)
nvim +checkhealth
```

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

### GitHub Actions Example

```yaml
name: Neovim Config CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Neovim
        run: |
          sudo add-apt-repository ppa:neovim-ppa/unstable
          sudo apt-get update
          sudo apt-get install -y neovim
      
      - name: Install Lua tools
        run: |
          sudo apt-get install -y luarocks
          sudo luarocks install luacheck
          cargo install stylua
      
      - name: Run quality gate
        run: ./scripts/quality-gate
```

---

## Quality Standards

### Zero Tolerance

The following must **always pass**:
- ✅ `luacheck lua/` → 0 warnings, 0 errors
- ✅ `stylua --check .` → no formatting needed
- ✅ Neovim loads without errors

### Performance Targets

- **Startup time:** <150ms (target), <500ms (acceptable)
- **Plugin count:** <50 (current: ~39)
- **Config size:** <10MB

---

## Troubleshooting

### "Luacheck failed"

1. **View errors:**
   ```bash
   luacheck lua/
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
   luacheck lua/
   ```

2. **View error details:**
   ```bash
   nvim --headless +qa 2>&1
   ```

3. **Check logs:**
   ```bash
   nvim --headless "+lua print(vim.lsp.get_log_path())" +qa
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

| Frequency | Task | Command |
|-----------|------|---------|
| Before commit | Quality gate | `./scripts/quality-gate` |
| Daily | Quick health check | `./scripts/health-check` |
| Weekly | Full health check + plugin updates | `nvim +Lazy update` |
| Monthly | Performance audit | Check `PERFORMANCE.md` |
| Bi-annually | Full review | Review all config files |

---

**See also:**
- `AGENTS.md` - Development conventions
- `PERFORMANCE.md` - Startup performance analysis
- `KEYMAPS.md` - Keymap reference
- `LSP.md` - Language tooling documentation
