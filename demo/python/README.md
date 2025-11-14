# LSP Demo - Python Files

This directory contains fully-typed Python files designed to demonstrate Neovim's LSP capabilities.

## Files

- **calculator.py** - Core mathematical functions (fully typed with `Union[int, float]`)
- **utils.py** - Utility functions that import from calculator.py (fully typed)
- **main.py** - Main entry point that uses both calculator and utils (fully typed)
- **__init__.py** - Package marker file
- **py.typed** - Marker file for PEP 561 type information

## Type Hints & Imports

All files use **modern Python 3.10+ typing** (no deprecated `typing` module imports):

- **Full type annotations** - Every function parameter and return type is annotated
- **Union operator `|`** - `int | float` instead of `Union[int, float]` (PEP 604)
- **Built-in generic types** - `list[int]`, `dict[str, int | float]` instead of `List`, `Dict` (PEP 585)
- **`Sequence` from `collections.abc`** - Covariant type for better LSP support
- **`Any` from `typing`** - Only import when actually needed for type flexibility
- **Absolute imports** - `from calculator import ...` (set up via pyproject.toml)

### Modern Python Typing Features Used

**Union operator `|` (PEP 604):**
```python
# ✅ Modern (Python 3.10+)
def add(a: int | float, b: int | float) -> int | float:

# ❌ Deprecated
from typing import Union
def add(a: Union[int, float], b: Union[int, float]) -> Union[int, float]:
```

**Built-in generic types (PEP 585):**
```python
# ✅ Modern (Python 3.10+)
def main() -> dict[str, int | float]:
numbers: list[int] = [1, 2, 3, 4, 5]

# ❌ Deprecated (Python 3.9 and earlier)
from typing import Dict, List
def main() -> Dict[str, Union[int, float]]:
numbers: List[int] = [1, 2, 3, 4, 5]
```

**`Sequence` from `collections.abc` (covariant):**
```python
from collections.abc import Sequence
def calculate_total(values: Sequence[int | float]) -> int | float:
```

This allows `list[int]` to match `Sequence[int | float]` which wouldn't work with invariant `List[int | float]`.

### Why These Choices?

- **No deprecated `typing` imports** - Uses modern Python 3.10+ syntax throughout
- **Covariant `Sequence`** - Better type compatibility for LSP and type checkers
- **Absolute imports** - The pyproject.toml configures basedpyright to recognize this directory as root

## LSP Keybindings to Try

### Navigation
| Keybinding | Action | Try on |
|---|---|---|
| `gd` | Go to definition | Any function call (e.g., `calculate_total`) |
| `gD` | Go to declaration | Function names |
| `gr` | Show references | Function name to see all usages |
| `gri` | Go to implementation | Function calls |
| `grt` | Go to type definition | Variable names |

### Refactoring
| Keybinding | Action | Try on |
|---|---|---|
| `grn` | Rename symbol (workspace-wide) | Try renaming `add` or `multiply` |
| `gra` | Code actions | Missing type hints, unused imports |

### Information
| Keybinding | Action | Try on |
|---|---|---|
| `K` | Hover documentation | Any function to see its docstring |
| `<leader>li` | Toggle inlay hints | See type annotations inline |

### Telescope LSP Pickers
| Keybinding | Action |
|---|---|
| `\r` | Find all references (searchable) |
| `\d` | Find all definitions (searchable) |
| `\i` | Find all implementations (searchable) |
| `<Tab>b` | Search workspace symbols |

## Demo Workflow

1. Open `main.py`: `nvim demo/python/main.py`
2. Place cursor on `calculate_total` on line 19
3. Press `gd` to jump to the definition in `calculator.py`
4. Press `gr` to see all references to `calculate_total`
5. Press `grn` to rename `calculate_total` everywhere
6. Press `gra` to see available code actions
7. Press `K` to hover and see the docstring
8. Use `\r` to find references via Telescope

## Features Demonstrated

✅ **Cross-file navigation** - Jump between imported modules  
✅ **Workspace-wide rename** - Change variable names across all files  
✅ **Code completion** - Type hints and docstrings  
✅ **Find references** - See where functions are used  
✅ **Code actions** - Quick fixes and refactoring suggestions  
✅ **Type information** - Hover over symbols to see types  

## Notes

- The import error in main.py is expected until you set up Python path properly
- All LSP features require a Python LSP server (basedpyright)
- Try `:LspInfo` to check if LSP is attached
- Use `:Mason` to verify Python LSP is installed
