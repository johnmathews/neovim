# Go to Definition (gd) - Detailed Explanation

## Quick Answer

**Press `gd` on a function name → Telescope picker appears → Select the definition → Jumps to actual file**

## The Problem We Solved

By default, Neovim's `gd` would jump to the **import statement** rather than the **actual function definition**.

### Before (Default Behavior - BROKEN)
```python
# main.py:22
from calculator import calculate_total
                       ↑ cursor here, press gd
# Result: Jumps to the import statement (wrong!)
```

### After (Fixed with Telescope Override)
```python
# main.py:22
from calculator import calculate_total
                       ↑ cursor here, press gd

# Telescope picker appears:
# calculator.py:24  def calculate_total(...)  ← select this
# Result: Jumps to calculator.py:24 (correct!)
```

## Why Telescope?

Telescope's LSP picker (`lsp_definitions`) properly:
1. **Resolves imports** - Follows import statements to actual definitions
2. **Shows multiple results** - If multiple definitions exist, you can choose
3. **Provides context** - Shows file path and line number for each option
4. **Works cross-file** - Properly jumps between different files

## How gd Works Now

### Step-by-Step Workflow

```
1. Open: main.py
2. Place cursor: on "calculate_total" (the imported function)
3. Press: gd
4. Telescope picker opens showing:
   ┌─────────────────────────────────────────┐
   │ Locations                               │
   ├─────────────────────────────────────────┤
   │ calculator.py:24 def calculate_total... │ ← highlighted
   │                                         │
   └─────────────────────────────────────────┘
5. Press: <Enter> (or just wait, will auto-select)
6. Result: Jumps to calculator.py:24
```

### Keyboard Shortcuts in Telescope Picker

| Key | Action |
|---|---|
| `<Enter>` | Jump to selected definition |
| `<C-x>` | Open in split (horizontal) |
| `<C-v>` | Open in split (vertical) |
| `<C-t>` | Open in new tab |
| `<Esc>` or `q` | Cancel and go back |

## Comparison: gd vs Other Go-To Keybindings

| Key | Function | Behavior |
|---|---|---|
| `gd` | **Go to Definition** | Opens Telescope picker (resolves imports) |
| `gD` | **Go to Declaration** | Built-in - jumps to declaration |
| `gi` | **Go to Implementation** | Opens Telescope picker (finds implementations) |
| `gr` | **Show References** | Shows quickfix list of all usages |
| `grn` | **Rename** | Rename symbol workspace-wide |
| `gra` | **Code Actions** | Shows refactoring options |
| `K` | **Hover** | Shows documentation inline |

## Real-World Examples

### Example 1: Simple Function

```python
# utils.py
def apply_discount(price, percent):  # definition at line 34
    ...

# main.py
from utils import apply_discount     # import at line 12
result = apply_discount(100, 10)     # usage at line 35
           ↑ cursor here, press gd
```

**Result:**
- Telescope picker shows: `utils.py:34 def apply_discount(...)`
- Press Enter
- Jumps to utils.py line 34 (the actual definition)

### Example 2: Chained Imports

```python
# calculator.py
def add(a, b):  # definition at line 14

# utils.py
from calculator import add  # import at line 13

# main.py
from utils import add  # indirect import at line 11
result = add(5, 3)     # usage at line 22
         ↑ cursor here, press gd
```

**Result:**
- Telescope picker shows: `calculator.py:14 def add(...)`
- Press Enter
- Jumps to calculator.py line 14 (the real definition, not utils import!)

### Example 3: Multiple Definitions

If somehow multiple definitions exist (rare), Telescope shows all:

```
┌──────────────────────────────────┐
│ Locations                        │
├──────────────────────────────────┤
│ module_a.py:10 def calculate    │ ← option 1
│ module_b.py:42 def calculate    │ ← option 2
│                                  │
└──────────────────────────────────┘
```

Choose which one you want with arrow keys and Enter.

## Common Scenarios

### Scenario 1: Jump to Definition
```
Cursor: on function name
Press: gd
Result: Telescope picker → Select → Jump to actual definition file ✓
```

### Scenario 2: Go Back
```
After jumping with gd:
Press: <C-o> (Vim standard jump-back)
Result: Returns to where you pressed gd ✓
```

### Scenario 3: Multiple Implementations
```
Cursor: on abstract method or interface
Press: gi (go to implementation)
Result: Telescope picker shows all implementations
Select: the one you want
Result: Jumps to that implementation ✓
```

## Implementation Details

The custom configuration in `lua/plugins/lsp.lua` overrides the default `gd` and `gi` keybindings:

```lua
-- Use Telescope for definitions to properly jump to actual file
map("n", "gd", function()
    telescope_builtin.lsp_definitions()
end, { desc = "Telescope: LSP Definitions" })

-- Use Telescope for implementations
map("n", "gi", function()
    telescope_builtin.lsp_implementations()
end, { desc = "Telescope: LSP Implementations" })
```

This ensures that:
- ✅ Imports are properly resolved
- ✅ You jump to the actual definition file
- ✅ Multiple results are handled gracefully
- ✅ Full Telescope search/filter capabilities

## Why Not Use Default `gd`?

Neovim's default `gd` (vim.lsp.buf.definition) has limitations:
- ❌ Stops at import statements
- ❌ No Telescope picker for multiple results
- ❌ Less intuitive workflow

Our Telescope override provides:
- ✅ Resolves through imports automatically
- ✅ Searchable/filterable results
- ✅ Multiple open options (split, tab, etc.)
- ✅ Better file navigation

## Troubleshooting

### gd Opens Telescope but Nothing is Highlighted

**Solution:** Press `j` to move down or `<Enter>` to select the first option

### gd Doesn't Show Any Results

**Solution:** 
1. Check `:LspInfo` - LSP must be attached
2. Try `<F4>` to restart LSP
3. Wait a moment for LSP to index files

### gd Jumps to Wrong File

**Solution:** 
1. Check the import is correct
2. Ensure all Python files are in the correct directory
3. Try `:LspRestart` or `<F4>`

## Tips & Tricks

✅ **Combine with other movements:**
```
gd → Select definition → gi → View implementations → grn → Rename
```

✅ **Use split opens:**
```
In Telescope picker while on a definition:
Press <C-x> → Opens definition in horizontal split
Press <C-v> → Opens definition in vertical split
Useful for comparing code
```

✅ **Quick go-back:**
```
After gd:
Press <C-o> → Go back (standard Vim jump list)
Press <C-p> → Go forward again
```

## See Also

- `gD` - Go to declaration (built-in, no picker)
- `gr` - Show all references (quickfix list)
- `K` - Hover documentation (inline)
- `\d` - Telescope definitions (if you want a separate keybind)
