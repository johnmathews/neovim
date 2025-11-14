# Go to Definition - Complete Guide

## What `gd` Does

`gd` is Neovim's built-in LSP keybinding (since v0.11+) that:
1. **Jumps to the definition** of the symbol under the cursor
2. **Opens the file** where the definition is (in the current window, no split)
3. **Adds to jump list** so you can press `<C-o>` to go back

## How to Use It

1. **Open any file in the demo:**
   ```bash
   nvim ~/.config/nvim/demo/python/main.py
   ```

2. **Place cursor on a function name:**
   ```python
   total = calculate_total(numbers)  # cursor on "calculate_total"
   ```

3. **Press `gd` to jump to definition:**
   - Jumps to `calculator.py` where `calculate_total` is defined
   - File opens in the current window
   - Jump is recorded in the jump list

4. **Go back with `<C-o>` (Ctrl-O):**
   - Returns to previous location
   - This is standard Vim navigation

## Demo Workflow

### Jump to Definition
```
File: main.py (line 22)
[cursor on calculate_total]
Press: gd
Result: Jumps to calculator.py line 24 where the function is defined
```

### Jump Chain Example
```
1. main.py line 22: calculate_total <- press gd
2. calculator.py line 24: calculate_total <- press gd (jumps to add)
3. calculator.py line 14: add <- press <C-o>
4. Back to calculator.py line 24 <- press <C-o>
5. Back to main.py line 22
```

## Why Go To Definition Matters

✅ **Cross-file navigation** - Jump between modules instantly  
✅ **Understand code flow** - See where functions are implemented  
✅ **Review implementation** - Read the actual function body  
✅ **Context discovery** - Find related functions and utilities  

## Common Issues & Solutions

### Issue: `gd` doesn't work
**Cause:** LSP not attached to buffer  
**Solution:** Check `:LspInfo` to see if basedpyright is attached

### Issue: `gd` opens wrong file or location
**Cause:** LSP root directory not set correctly  
**Solution:** Ensure `pyproject.toml` is in the demo root directory

### Issue: `gd` says "No definition found"
**Cause:** LSP hasn't indexed the files yet  
**Solution:** Wait a moment for LSP to scan, then try again, or press `<F4>` to restart LSP

### Issue: Can't find built-in functions
**Cause:** Built-in Python functions aren't LSP-analyzable  
**Solution:** Use `K` to hover for documentation instead, or `gr` to see where it's called

## Related Keybindings

| Key | Action | Use Case |
|---|---|---|
| `gd` | Go to definition | Jump to function/variable definition |
| `gD` | Go to declaration | Jump to where symbol was declared |
| `gri` | Go to implementation | Find all implementations of a method |
| `gr` | Show references | List all places where symbol is used |
| `<C-o>` | Jump back | Return to previous location (jump list) |
| `<C-p>` | Jump forward | Move forward in jump list |
| `K` | Hover | See documentation without jumping |

## Understanding the Demo Structure

```
demo/
├── pyproject.toml          ← LSP root (contains project config)
└── python/
    ├── __init__.py
    ├── calculator.py       ← Functions: add, multiply, calculate_total, calculate_product
    ├── utils.py            ← Functions: validate_number, calculate_average, apply_discount, chain_operations
    └── main.py             ← Imports and uses functions from calculator and utils
```

When you open `main.py` and press `gd` on a function:
1. LSP locates the definition in `calculator.py` or `utils.py`
2. File opens in current window
3. Cursor jumps to the function definition
4. Jump is recorded for `<C-o>` navigation

## Tips for Effective Navigation

1. **Chain jumps:** Press `gd` multiple times to follow the call stack
2. **Use `gr` to find usages:** Before jumping, see WHERE something is used
3. **Combine with `K`:** Use `K` to read docs, `gd` to see implementation
4. **Go back with `<C-o>`:** Don't need to bookmark - jump list remembers
5. **Use Telescope for search:** `\d` opens searchable definition list

## Why This Demo Works Well with `gd`

✅ Functions are **cross-file** - demonstrates jumping between files  
✅ Functions have **clear names** - easy to place cursor and press `gd`  
✅ Functions are **properly typed** - LSP can reliably find definitions  
✅ Project **uses pyproject.toml** - LSP knows the root directory  
✅ All imports are **absolute** - LSP can resolve them correctly  
