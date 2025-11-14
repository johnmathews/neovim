# LSP Demo - TypeScript Files

This directory contains fully-typed TypeScript files designed to demonstrate Neovim's LSP capabilities.

## Files

- **math.ts** - Core mathematical functions with full type annotations
- **utils.ts** - Utility functions that import from math.ts (fully typed)
- **main.ts** - Main entry point that uses both math and utils (fully typed)
- **tsconfig.json** - TypeScript configuration with strict type checking

## Type Hints & Imports

All files use **strict TypeScript typing** for comprehensive LSP support:

- **Full type annotations** - Every function parameter and return type is explicitly typed
- **JSDoc comments** - `/**` documentation for all functions
- **@param annotations** - Document parameter types and descriptions
- **@returns annotations** - Document return types
- **ES6 imports/exports** - Modern module system

### Modern TypeScript Features Used

**Strict type annotations:**
```typescript
function add(a: number, b: number): number {
	return a + b;
}
```

**Function signature documentation:**
```typescript
/**
 * Add two numbers together
 * @param a First number
 * @param b Second number
 * @returns The sum of a and b
 */
export function add(a: number, b: number): number {
	return a + b;
}
```

**Typed arrays and return types:**
```typescript
export function calculateTotal(values: number[]): number {
	let result = 0;
	for (const value of values) {
		result = add(result, value);
	}
	return result;
}
```

**Object typing:**
```typescript
function main(): Record<string, number> {
	return {
		total,
		product,
		average,
	};
}
```

### Why These Choices?

- **Strict mode** - Enables all type checking rules for maximum LSP diagnostics
- **Explicit typing** - Every variable and function has clear types
- **JSDoc comments** - Enables hover documentation and parameter hints
- **ES6 modules** - Standard modern JavaScript module system
- **TypeScript config** - Ensures consistent type checking across project

## LSP Keybindings to Try

### Navigation
| Keybinding | Action | Try on |
|---|---|---|
| `gd` | Go to definition | Any function call (e.g., `calculateTotal`) |
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

1. Open `main.ts`: `nvim demo/typescript/main.ts`
2. Place cursor on `calculateTotal` on line 20
3. Press `gd` to jump to the definition in `math.ts`
4. Press `gr` to see all references to `calculateTotal`
5. Press `grn` to rename `calculateTotal` everywhere
6. Press `gra` to see available code actions
7. Press `K` to hover and see the documentation
8. Use `\r` to find references via Telescope

## Features Demonstrated

✅ **Cross-file navigation** - Jump between imported modules  
✅ **Workspace-wide rename** - Change function names across all files  
✅ **Type information** - Hover over symbols to see detailed types  
✅ **Code completion** - JSDoc comments and type hints  
✅ **Find references** - See where functions are used  
✅ **Code actions** - Quick fixes and refactoring suggestions  
✅ **Type checking** - Real-time type error detection  

## Notes

- All LSP features require the TypeScript LSP server (ts_ls)
- Try `:LspInfo` to check if LSP is attached
- Use `:Mason` to verify TypeScript LSP is installed
- `tsconfig.json` enables strict type checking for comprehensive diagnostics
