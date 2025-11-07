# Testing & Changelog Guide

This document answers common questions about testing and change management for this Neovim configuration.

---

## Question 1: Can you test the LSP stack using the test/ directory?

**Answer: Yes! ✅**

### Automated LSP Testing

An automated test script has been created: `test/test_lsp.sh`

**Run it:**
```bash
./test/test_lsp.sh
```

**Results:**
```
🧪 Testing LSP Stack
====================

1. Lua Language Server
  Expected LSP: lua_ls... ✓ ATTACHED

2. Python Language Server
  Expected LSP: pyright|pylsp... ✓ ATTACHED

3. JavaScript Language Server
  Expected LSP: ts_ls|tsserver... ✓ ATTACHED

4. YAML Language Server
  Expected LSP: yamlls... ✓ ATTACHED

✅ LSP stack testing complete!
```

### What the test validates:

- ✅ LSP servers attach within 3 seconds
- ✅ Correct server names for each filetype
- ✅ Configuration is properly loaded
- ✅ Mason-installed servers are available

### Manual testing workflow:

1. **Open a test file:**
   ```bash
   nvim test/python/test_sample.py
   ```

2. **Check LSP status:**
   ```vim
   :LspInfo
   ```

3. **Verify diagnostics appear:**
   - You should see warnings/errors from the intentional bugs
   - Example: `undefined_var` in Python should trigger an error

4. **Test LSP features:**
   - Hover: `K` on any symbol
   - Go to definition: `gd`
   - Code actions: `<leader>ca`
   - Rename: `<leader>rn`

### Test file purpose:

Each file in `test/` contains **intentional errors** to verify that:
- LSP servers detect issues
- Linters report warnings
- Diagnostics display correctly
- Code actions are available

**Do not fix the errors in test files** - they're there to test the tooling!

---

## Question 2: Is it good practice to implement a changelog?

**Answer: Yes, absolutely! ✅**

### Why use a CHANGELOG.md?

**Benefits:**
1. **Track history** - See what changed and when
2. **Communication** - Share updates with users/collaborators
3. **Versioning** - Understand breaking vs. non-breaking changes
4. **Debugging** - Trace when issues were introduced
5. **Onboarding** - Help new users understand evolution
6. **Best practice** - Industry standard for projects

### Format: Keep a Changelog

This configuration now uses [Keep a Changelog](https://keepachangelog.com/) format:

**File:** `CHANGELOG.md`

**Structure:**
```markdown
## [Unreleased]
- Changes not yet released

## [1.1.0] - 2025-01-13
### Added
- New features

### Changed
- Modifications to existing features

### Fixed
- Bug fixes

### Removed
- Deleted features
```

### When to update CHANGELOG.md:

**Every time you make changes:**
1. Add entry under `[Unreleased]` section
2. Use appropriate category (Added/Changed/Fixed/etc.)
3. Write clear, user-focused descriptions
4. Include file paths where relevant

**Example:**
```markdown
## [Unreleased]

### Added
- **Telescope lazy-loading**: Load on `<Tab>` keypress instead of startup
  - File: `lua/plugins.lua:84-98`
  - Performance: Saves ~16ms in real-world usage

### Fixed
- **Health check script**: Fixed floating-point comparison bug
  - File: `scripts/health-check:68-73`
```

### Alternative: Git commits only

Some projects skip CHANGELOG.md and rely on:
- Git commit messages
- GitHub Releases
- Git tags

**Pros:**
- Less maintenance
- Single source of truth

**Cons:**
- Harder to read full history
- Less user-friendly
- No categorization

### Recommendation for this project:

**Use CHANGELOG.md** because:
1. **Personal configuration** - You'll thank yourself later when asking "when did I change X?"
2. **Reference for AI agents** - Clear changelog helps assistants understand project evolution
3. **Low overhead** - Only update when making significant changes
4. **Best practice** - Aligns with professional software development

### Semantic Versioning (Optional)

This project uses semantic versioning: `MAJOR.MINOR.PATCH`

- **MAJOR (2.0.0)** - Breaking changes (keymaps changed, plugins removed)
- **MINOR (1.1.0)** - New features (new plugins, enhancements)
- **PATCH (1.0.1)** - Bug fixes (no new features)

**Benefits:**
- Clear communication of impact
- Easy to understand change severity
- Standard across software industry

---

## Summary

### ✅ Question 1: LSP Testing
- **Yes, automated testing is available**
- Run `./test/test_lsp.sh` to verify all LSP servers
- All 4 language servers (Lua, Python, JS, YAML) attach successfully
- Manual testing workflow documented above

### ✅ Question 2: Changelog
- **Yes, CHANGELOG.md is good practice and highly recommended**
- Created using "Keep a Changelog" format
- Versioned with semantic versioning (1.1.0)
- Update under `[Unreleased]` section as you make changes
- Helps track evolution and debug issues

---

## Quick Reference

### Testing Commands
```bash
# Test LSP stack
./test/test_lsp.sh

# Run health check
./scripts/health-check

# Run quality gate
./scripts/quality-gate

# Manual LSP test
nvim test/lua/test_sample.lua
:LspInfo
```

### Changelog Workflow
```bash
# 1. Make changes to config
# 2. Update CHANGELOG.md under [Unreleased]
# 3. Test changes
./scripts/quality-gate

# 4. Commit
git add .
git commit -m "feat: add lazy-loading for Telescope"

# 5. When releasing a version, move [Unreleased] to [1.2.0]
```

---

**Files created:**
- `CHANGELOG.md` - Main changelog file
- `test/test_lsp.sh` - Automated LSP testing script
- `TESTING_CHANGELOG_GUIDE.md` - This guide

**References:**
- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)
- `test/README.md` - Testing documentation
