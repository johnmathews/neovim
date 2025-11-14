# LSP Demo - Lua Files

This directory contains fully-documented Lua files designed to demonstrate Neovim's LSP capabilities.

## Files

- **math.lua** - Core mathematical functions (fully annotated with LDoc/EmmyLua comments)
- **utils.lua** - Utility functions that import from math.lua (fully annotated)
- **main.lua** - Main entry point that uses both math and utils (fully annotated)

## Type Hints & Annotations

All files use **LDoc/EmmyLua annotations** for comprehensive LSP support:

- **Full type annotations** - Every function parameter and return type is documented
- **LDoc comments** - `---` for function documentation
- **@param annotations** - Document parameter types and descriptions
- **@return annotations** - Document return types
- **Module exports** - Clear `return` statements at end of files

### Modern Lua Features Used

**LDoc/EmmyLua type annotations:**
```lua
---Add two numbers together
---@param a number
---@param b number
---@return number
local function add(a, b)
	return a + b
end
```

**Module imports and exports:**
```lua
local math_module = require("demo.lua.math")

local function calculate_average(values)
	local total = math_module.calculate_total(values)
	return total / #values
end

return {
	calculate_average = calculate_average,
	apply_discount = apply_discount,
}
```

### Why These Choices?

- **LDoc comments** - Standard Lua documentation format, supported by lua_ls
- **Type annotations** - Enables better LSP diagnostics and code completion
- **Module pattern** - Uses Lua's standard module system for clean imports/exports
- **Local functions** - Encapsulation and namespace management

## LSP Keybindings to Try

### Navigation
| Keybinding | Action | Try on |
|---|---|---|
| `gd` | Go to definition | Any function call (e.g., `calculate_total`) |
| `gD` | Go to declaration | Function names |
| `gr` | Show references | Function name to see all usages |
| `gi` | Go to implementation | Function calls |
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

1. Open `main.lua`: `nvim demo/lua/main.lua`
2. Place cursor on `calculate_total` on line 20
3. Press `gd` to jump to the definition in `math.lua`
4. Press `gr` to see all references to `calculate_total`
5. Press `grn` to rename `calculate_total` everywhere
6. Press `gra` to see available code actions
7. Press `K` to hover and see the documentation
8. Use `\r` to find references via Telescope

## Features Demonstrated

✅ **Cross-file navigation** - Jump between imported modules  
✅ **Workspace-wide rename** - Change function names across all files  
✅ **Code completion** - Type hints and documentation  
✅ **Find references** - See where functions are used  
✅ **Code actions** - Quick fixes and refactoring suggestions  
✅ **Type information** - Hover over symbols to see types  

## Notes

- All LSP features require a Lua LSP server (lua_ls)
- Try `:LspInfo` to check if LSP is attached
- Use `:Mason` to verify Lua LSP is installed
- `.luarc.json` or `.luacheckrc` may be needed for advanced configuration
