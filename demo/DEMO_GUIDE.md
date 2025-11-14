# Neovim LSP Demo Guide

Welcome to the LSP keybinding demo! This directory contains examples to test all the **built-in Neovim v0.11+ LSP keybindings** you have configured.

**Note:** These are Neovim's standard LSP keybindings, not custom ones. All keybindings use the `g` prefix or other standard vim motions.

## Quick Start

```bash
# Open the demo from nvim config root
cd ~/.config/nvim
nvim demo/python/main.py
```

## What to Try

### 1. Go to Definition (`gd`)
```
Open: demo/python/main.py
Place cursor on: calculate_total (line 22)
Press: gd
Result: Opens Telescope picker
  Select: calculator.py:24 (the actual definition)
  Result: Jumps to calculator.py where calculate_total is defined
```

**Note:** `gd` uses Telescope to properly resolve through imports to the actual definition file.

### 2. Show References (`gr`)
```
Place cursor on: calculate_total
Press: gr
Result: Opens quickfix list showing all places where calculate_total is used
```

### 3. Rename Symbol (`grn`)
```
Place cursor on: add (any occurrence)
Press: grn
Type: new_name
Result: Function is renamed across ALL files (calculator.py, utils.py, main.py)
```

### 4. Code Actions (`gra`)
```
Place cursor on: missing type hints (Python will suggest)
Press: gra
Result: Shows available refactoring options
```

### 5. Hover Documentation (`K`)
```
Place cursor on: apply_discount (line 33)
Press: K
Result: Shows the function's docstring: "Apply a discount to a price."
```

### 6. Go to Implementation (`gri`)
```
Place cursor on: calculate_product (line 23)
Press: gri
Result: Jumps to the implementation in calculator.py
```

### 7. Telescope Pickers
```
Press: \r (LocalLeader+r)
Result: Opens Telescope to search for all references (searchable!)

Press: \d
Result: Opens Telescope to find all definitions

Press: \i
Result: Opens Telescope to find all implementations
```

## File Relationships

```
calculator.py
├── add()
├── multiply()
├── calculate_total()      ← uses add()
└── calculate_product()    ← uses multiply()

utils.py
├── imports from calculator.py
├── validate_number()
├── calculate_average()
├── apply_discount()       ← uses multiply() and add()
└── chain_operations()     ← uses add() and multiply()

main.py
├── imports from calculator.py
├── imports from utils.py
└── main()                 ← calls all the functions
```

## Tips

- Use `:LspInfo` to check if LSP is attached to the current buffer
- Use `:Mason` to verify that `basedpyright` is installed
- Try `:lua vim.lsp.buf.document_symbol()` to see all symbols in the file
- The import error in main.py is normal - it's a path resolution issue, but LSP navigation still works!

## All LSP Keybindings (Neovim v0.11+ Built-in)

### Go-to Commands
| Keybinding | Action | Type |
|---|---|---|
| `gd` | Go to definition | Built-in |
| `gD` | Go to declaration | Built-in |
| `gri` | Go to implementation | Built-in |
| `grt` | Go to type definition | Built-in |

### References & Refactoring
| Keybinding | Action | Type |
|---|---|---|
| `gr` | Show references (quickfix list) | Built-in |
| `grn` | Rename symbol (workspace-wide) | Built-in |
| `gra` | Code actions (quick fixes) | Built-in |

### Information & Hints
| Keybinding | Action | Type |
|---|---|---|
| `K` | Hover documentation | Built-in |
| `<leader>li` | Toggle inlay hints | Custom |
| `<F4>` | Restart LSP | Custom |

### Telescope LSP Pickers
| Keybinding | Action | Type |
|---|---|---|
| `\r` | Telescope: Find references | Custom |
| `\d` | Telescope: Find definitions | Custom |
| `\i` | Telescope: Find implementations | Custom |
| `<Tab>b` | Telescope: Workspace symbols | Custom |

## Type System Notes

All Python files in this demo are **fully typed** using:
- Function parameter type hints (e.g., `a: Union[int, float]`)
- Return type hints (e.g., `-> Union[int, float]`)
- Variable type annotations (e.g., `result: Union[int, float] = 0`)
- `Sequence` for covariant list parameters (better LSP support)

The `pyproject.toml` file configures basedpyright to understand absolute imports like `from calculator import add`.

## Troubleshooting

**LSP not attaching?**
- Check `:LspInfo` to see attached servers
- Run `:Mason` and ensure `basedpyright` is installed
- Press `<F4>` to restart LSP
- Make sure you're in the demo/python directory

**References not showing?**
- Make sure cursor is on a symbol (function name, variable)
- Press `gr` and wait a moment for quickfix to populate
- Check `:messages` for LSP errors

**Rename not working?**
- Try on a simple function like `add` instead of imported functions
- Use `grn` (not `gR` - that was the custom binding we removed)
- Check LSP status with `:LspInfo`

**Type errors in editor?**
- The files are fully typed but import resolution requires pyproject.toml
- If you see import errors, make sure you opened files from the demo/python directory
- Try `:LspRestart` (<F4>) to reload LSP configuration

## Notes

This demo uses Python, but the same LSP keybindings work with:
- TypeScript/JavaScript (via ts_ls)
- Lua (via lua_ls)
- Bash (via bashls)
- YAML (via yamlls)
- JSON (via jsonls)
- And many more languages!
