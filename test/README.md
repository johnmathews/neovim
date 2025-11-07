# Neovim Configuration Test Suite

This directory contains test files for validating the Neovim configuration, LSP setup, linters, and formatters.

## Purpose

Each test file contains **intentional errors and edge cases** to verify that:

1. **LSP servers** attach correctly and provide diagnostics
2. **Linters** detect issues appropriately
3. **Formatters** work as expected
4. **Syntax highlighting** renders correctly
5. **Code actions** are available

## Test Files

### Python (`test/python/`)
- **File:** `test_sample.py`
- **Tests:**
  - Type errors (LSP)
  - Unused variables and functions (linter)
  - Missing type annotations
  - Undefined variables

### Lua (`test/lua/`)
- **File:** `test_sample.lua`
- **Tests:**
  - Luacheck warnings
  - Undefined globals
  - Unused variables and functions
  - Line length warnings

### JavaScript (`test/javascript/`)
- **File:** `test_sample.js`
- **Tests:**
  - ESLint warnings
  - Type mismatches
  - Undefined variables
  - Missing semicolons

### YAML (`test/yaml/`)
- **File:** `test_sample.yaml`
- **Tests:**
  - Indentation errors
  - Duplicate keys
  - Type mismatches
  - Syntax errors

### Markdown (`test/markdown/`)
- **File:** `test_sample.md`
- **Tests:**
  - Syntax highlighting
  - Link validation
  - YAML frontmatter
  - Table formatting
  - Unclosed formatting

### Bash (`test/bash/`)
- **File:** `test_sample.sh`
- **Tests:**
  - ShellCheck warnings
  - Missing quotes
  - Undefined variables
  - Deprecated syntax

## How to Use

### Manual Testing

1. **Open a test file:**
   ```bash
   nvim test/python/test_sample.py
   ```

2. **Verify LSP attached:**
   - Check for diagnostics/warnings in the file
   - Try `:LspInfo` to see attached servers

3. **Test LSP features:**
   - **Go to definition:** `gd` on a function/variable
   - **Hover documentation:** `K` on a symbol
   - **Code actions:** `<leader>ca` on an error
   - **Rename:** `<leader>rn` on a symbol
   - **Format:** `<leader>cf` to format the file

4. **Test linting:**
   - Open file and check for diagnostic messages
   - Run `:lua require('lint').try_lint()` if needed

5. **Test formatting:**
   - Run `:lua require('conform').format()` or `<leader>cf`
   - Verify changes are applied

### Automated Testing

### LSP Attachment Test

Run the automated LSP test suite:

```bash
./test/test_lsp.sh
```

This script verifies that LSP servers attach correctly for:
- ✅ Lua (lua_ls)
- ✅ Python (pyright/pylsp)
- ✅ JavaScript (ts_ls/tsserver)
- ✅ YAML (yamlls)

**Results:** All LSP servers attach successfully within 3 seconds.

### Future Enhancements

- Diagnostic count assertions
- Format diff verification
- CI/CD integration
- Automated linter output validation

## Expected Behavior

Each test file should:

- ✅ Have LSP server attach automatically (`:LspInfo`)
- ✅ Show diagnostic warnings/errors inline
- ✅ Provide code actions where applicable
- ✅ Support go-to-definition and hover documentation
- ✅ Format correctly when `:lua require('conform').format()` is run

## Adding New Test Files

When adding new test files:

1. Create directory for the language: `mkdir test/<language>`
2. Add sample file with intentional errors
3. Document the errors in comments
4. Update this README with test details
5. Verify LSP/linter behavior manually

## Notes

- These files are **intentionally broken** - do not fix the errors!
- They serve as test data, not examples of good code
- Use them to verify configuration changes work correctly
- Run tests after updating LSP servers, linters, or formatters
