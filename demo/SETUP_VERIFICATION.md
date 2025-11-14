# LSP Demo Setup Verification

## Complete Setup Checklist

### Project Structure ✅
```
~/.config/nvim/demo/
├── pyproject.toml                    ← LSP root configuration
├── GO_TO_DEFINITION_GUIDE.md         ← Guide for `gd` keybinding
├── DEMO_GUIDE.md                     ← Quick start guide
└── python/
    ├── __init__.py                   ← Package marker
    ├── py.typed                      ← PEP 561 type marker
    ├── calculator.py                 ← Core functions
    ├── utils.py                      ← Import from calculator
    ├── main.py                       ← Entry point
    └── README.md                     ← Detailed reference
```

### Neovim LSP Configuration ✅
Your Neovim config (`lua/plugins/lsp.lua`) is set up to:
- Detect pyproject.toml as the LSP root directory marker
- Use basedpyright for Python analysis
- Resolve absolute imports correctly
- Support all LSP keybindings

### Python Files ✅
All files are:
- **Fully typed** using modern Python 3.10+ syntax (no deprecated imports)
- **Properly imported** using absolute imports (from calculator import ...)
- **Executable** (verified: all run without errors)
- **LSP-ready** with proper annotations on every function

### Critical Files for LSP

**pyproject.toml** - Tells LSP where the project root is:
```toml
[tool.basedpyright]
pythonPath = "python"
pythonVersion = "3.10"
```

**__init__.py** - Makes python/ a package (required for imports):
```python
"""LSP demo package for Neovim."""
```

**py.typed** - PEP 561 marker file (empty but required for type checking)

## How `gd` (Go to Definition) Works

### Prerequisites
1. ✅ LSP server (basedpyright) is installed via `:Mason`
2. ✅ LSP is attached to the Python buffer (check with `:LspInfo`)
3. ✅ pyproject.toml is in the parent directory of your Python files

### Workflow
```
1. Open: nvim ~/.config/nvim/demo/python/main.py
2. LSP scans and finds pyproject.toml in parent dir
3. LSP indexes all Python files (calculator.py, utils.py, main.py)
4. Place cursor on "calculate_total" (line 22)
5. Press: gd
6. Result: Opens calculator.py, jumps to line 24 (function definition)
7. Go back: <C-o> (returns to main.py)
```

### Why This Setup Works

| Component | Purpose | Status |
|-----------|---------|--------|
| pyproject.toml | LSP root marker | ✅ Present in demo/ |
| __init__.py | Package marker | ✅ Present in python/ |
| py.typed | Type hint marker | ✅ Present in python/ |
| Absolute imports | File resolution | ✅ Configured in pyproject.toml |
| Modern typing | LSP compatibility | ✅ All files use Python 3.10+ syntax |

## Testing Go to Definition

### Quick Test
```bash
cd ~/.config/nvim/demo
nvim python/main.py

# Inside Neovim:
:LspInfo                          # Verify basedpyright is attached
# Place cursor on "calculate_total" (line 22)
gd                               # Should jump to calculator.py:24
<C-o>                            # Should return to main.py:22
```

### Additional Tests
Try `gd` on these symbols:
- `calculate_total` → calculator.py:24
- `add` (in utils.py) → calculator.py:14
- `apply_discount` → utils.py:34
- `chain_operations` → utils.py:41

## Troubleshooting

### LSP Not Attaching
```vim
:LspInfo                    " Check if basedpyright is listed
:Mason                      " Verify basedpyright is installed
<F4>                        " Restart LSP
```

### `gd` Says "No Definition Found"
1. Wait a moment for LSP to index files
2. Try `:LspRestart` or `<F4>`
3. Check `:messages` for LSP errors
4. Verify cursor is on a function/symbol name

### Wrong File Opens
This shouldn't happen, but if it does:
1. Check that pyproject.toml is in demo/ (not demo/python/)
2. Verify __init__.py exists in demo/python/
3. Restart Neovim
4. Press `<F4>` to restart LSP

### Imports Show as Unresolved
The editor may show red squiggles on imports, but they work. This is because:
1. The type checker needs files to be opened in the correct root
2. Once LSP attaches, it should resolve
3. Try `:LspRestart`

## Keybindings That Work

| Keybinding | Action | Demo Example |
|---|---|---|
| `gd` | Go to definition | Jump from main.py to calculator.py |
| `gr` | Show references | See all uses of `add` |
| `grn` | Rename symbol | Rename `add` → `add_numbers` everywhere |
| `gra` | Code actions | Add type hints (if missing) |
| `gri` | Go to implementation | Find implementations of functions |
| `K` | Hover docs | See function docstring |
| `\r` | Telescope refs | Search references interactively |
| `\d` | Telescope defs | Search definitions interactively |
| `\i` | Telescope impl | Search implementations |

## What's Different About This Demo

✅ **Cross-file imports** - Functions spread across calculator.py, utils.py, main.py  
✅ **Modern typing** - Uses Python 3.10+ syntax, no deprecated typing imports  
✅ **Proper package structure** - __init__.py and py.typed markers  
✅ **LSP-ready** - pyproject.toml configures basedpyright  
✅ **Absolute imports** - Easier for LSP to resolve  
✅ **Full type annotations** - Every function has complete type hints  

## Next Steps

1. **Try the demo:** `nvim ~/.config/nvim/demo/python/main.py`
2. **Test `gd`:** Place cursor on function name, press `gd`
3. **Explore other keybindings:** Try `gr`, `grn`, `K`, `gra`, etc.
4. **Use Telescope:** Try `\r` to search references with Telescope
5. **Rename functions:** Try `grn` on `add` to see cross-file renaming

All features are ready to use immediately!
