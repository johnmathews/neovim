# LSP Keybindings Reference - Complete

This document shows all LSP-related keybindings available in Neovim v0.11+.

## Quick Help

**In Neovim, press `<Space>` and hold to see all Leader key bindings in which-key**

Press `\` (LocalLeader) to see LocalLeader bindings.

## Built-in Neovim v0.11+ LSP Keybindings

These are **standard Neovim keybindings** that come with Neovim 0.11+ when LSP is configured.

### Go-to Navigation (`g` prefix)

| Key | Action | Behavior |
|---|---|---|
| `gd` | **Go to Definition** | Open Telescope picker, jumps through imports to actual definition |
| `gD` | **Go to Declaration** | Jump to where symbol was declared (built-in) |
| `gi` | **Go to Implementation** | Open Telescope picker to find implementations |
| `grt` | **Go to Type Definition** | Jump to type definition (built-in) |

**Example:**
```
main.py:22  calculate_total(numbers)
            ↑ cursor here, press gd
# Opens Telescope picker showing:
#   calculator.py:24  def calculate_total(...)  ← select this
calculator.py:24  def calculate_total(...)
                  ↑ jumps here (actual definition, not import)
```

**Why Telescope for gd/gi?** 
- The built-in `gd` would jump to import statement
- Telescope picker resolves through imports to actual definitions
- If multiple definitions found, you can choose which one
- Press `<Esc>` to cancel the picker

### References & Refactoring (`gr` prefix)

| Key | Action | Behavior |
|---|---|---|
| `gr` | **Show References** | Open quickfix list with all usages |
| `grn` | **Rename Symbol** | Rename variable/function workspace-wide |
| `gra` | **Code Actions** | Show available refactoring/fixes |

**Example:**
```
calculator.py:14  def add(a, b):
                  ↑ cursor here, press grn
Type: add_numbers
Result: Updates function name in:
  - calculator.py (definition)
  - utils.py (import and calls)
  - main.py (calls)
```

### Documentation & Information

| Key | Action | Behavior |
|---|---|---|
| `K` | **Hover Documentation** | Show docstring/type info inline |

**Example:**
```python
result = add(100, 50)
         ↑ cursor here, press K
# Shows: add(a: int | float, b: int | float) -> int | float
#        Add two numbers together.
```

## Custom LSP Keybindings

These are custom bindings added for convenience.

### Inlay Hints

| Key | Mode | Action |
|---|---|---|
| `<leader>li` | Normal | Toggle inlay hints |

Shows type annotations inline (when enabled):
```python
def add(a: int | float, b: int | float) -> int | float:
            ^^^^^^^^^^^^^^^^^              ^^^^^^^^^^
            inlay hint showing types
```

### LSP Server Management

| Key | Mode | Action |
|---|---|---|
| `<F4>` | Normal | Restart LSP server |

Useful when LSP gets stuck or needs to re-index files.

## Telescope LSP Pickers (Enhanced Search)

These use Telescope for searchable/filterable results.

### LocalLeader (`\` key) Bindings

| Key | Action | Benefits |
|---|---|---|
| `\r` | Find References (Telescope) | Searchable list of all usages |
| `\d` | Find Definitions (Telescope) | Searchable list of all definitions |
| `\i` | Find Implementations (Telescope) | Searchable list of implementations |
| `\t` | Show Active Tools | Lists active LSP/formatters/linters |

**Example:**
```
main.py:22  calculate_total(numbers)
            ↑ cursor here, press \r
# Opens Telescope picker showing:
#   - main.py:22  (this line)
#   - main.py:29  (another usage)
#   - utils.py:8  (imported)
# Type to filter, <Enter> to jump
```

## Text Objects (Treesitter)

### Selection Objects

| Key | Action | Example |
|---|---|---|
| `af` | Select outer function | `vaf` = select entire function |
| `if` | Select inner function | `vif` = select function body only |
| `ac` | Select outer class | `vac` = select entire class |
| `ic` | Select inner class | `vic` = select class body only |

### Navigation Objects

| Key | Action |
|---|---|
| `]m` | Jump to next function start |
| `[m` | Jump to previous function start |
| `]]` | Jump to next class start |
| `[[` | Jump to previous class start |
| `]M` | Jump to next function end |
| `[M` | Jump to previous function end |

## Treesitter Operations

### Parameter Swapping

| Key | Action | Example |
|---|---|---|
| `<leader>tsa` | Swap next parameter | `func(a, b, c)` → `func(a, c, b)` |
| `<leader>tsA` | Swap previous parameter | `func(a, b, c)` → `func(b, a, c)` |

### Peek Definition

| Key | Action |
|---|---|
| `<leader>df` | Peek function definition (without jumping) |
| `<leader>dF` | Peek class definition |

## Diagnostics

| Key | Action |
|---|---|
| `<Tab>dd` | Cycle diagnostic display modes |
| `<leader>ta` | Show active LSP/formatters/linters for buffer |

## Quick Reference Table (All LSP Keys)

| Category | Keys | Type |
|---|---|---|
| **Go-to** | `gd`, `gD`, `gri`, `grt` | Built-in |
| **References** | `gr`, `grn`, `gra` | Built-in |
| **Info** | `K` | Built-in |
| **Hints** | `<leader>li` | Custom |
| **LSP Mgmt** | `<F4>`, `<Tab>dd`, `<leader>ta` | Custom |
| **Telescope** | `\r`, `\d`, `\i`, `\t` | Custom |
| **Treesitter** | `af`, `if`, `ac`, `ic`, `]m`, `[m`, `]]`, `[[` | Treesitter |
| **Swap** | `<leader>tsa`, `<leader>tsA` | Treesitter |
| **Peek** | `<leader>df`, `<leader>dF` | Treesitter |

## How to Discover Keybindings

### 1. In Neovim
```vim
# Show Leader key bindings
:help which-key
# Or just press <Space> and wait

# Show all keymaps
:Telescope keymaps
# Or: <Tab>tk
```

### 2. Using which-key Popup
- Press `<Space>` → shows all `<leader>` bindings
- Press `\` → shows all `<LocalLeader>` bindings
- Press `g` → shows all `g` prefix bindings
- Press `]` → shows navigation bindings

## Tips & Best Practices

✅ **Combine keybindings:**
```
gd             # Jump to definition
<C-o>          # Go back (standard Vim jump list)
gr             # See where it's called from
grn            # Rename it everywhere
gd             # Jump to updated definition
```

✅ **Use Telescope for complex searches:**
```
\r             # Find all references (then filter with /)
\d             # Find all definitions (then jump to right one)
<Tab>b         # Search all symbols in workspace
```

✅ **Understand the difference:**
- `gd` = Jump to first definition
- `gr` = List all references
- `grn` = Rename everywhere
- `\d` = Searchable definition list (Telescope)

## Troubleshooting

**Keybinding doesn't work:**
1. Check `:LspInfo` - LSP must be attached
2. Try `<F4>` to restart LSP
3. Make sure you're not in insert mode (use `<Esc>` first)

**which-key doesn't show descriptions:**
1. Press `<Space>` and wait (not <Space> and release immediately)
2. Check which-key is loaded: `:lua require('which-key')`
3. Press `<F1>` inside which-key popup for more help

**References show wrong locations:**
1. LSP may still be indexing (wait a moment)
2. Try `<F4>` to restart LSP
3. Check `:LspInfo` for any errors

