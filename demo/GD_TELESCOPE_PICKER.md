# Understanding `gd` with Telescope Picker

## The Behavior

When you press `gd` in Neovim, you now get:

1. **Telescope picker opens** showing all definition locations
2. **Multiple results listed** - both import lines and actual definitions
3. **You need to select** the one you want

## Why Both Import and Definition Show Up

When the LSP queries for "go to definition", it returns:

- ✅ The actual function definition (what you want)
- ✅ The import statement (where the symbol is first used/declared)

Both are valid "definition" locations from the LSP's perspective, so Telescope shows both.

## How to Use It Properly

### Example: Jump to Actual Definition (Not Import)

```
File: main.py line 12
Code: from utils import apply_discount

Cursor on: apply_discount
Press: gd

Telescope picker appears:
  1 main.py:12 col 35-52            | from utils import apply_discount
  2 utils.py:34 col 5-18            | def apply_discount(...) -> ...

Select option 2 (the actual definition)
Press: <Enter>
Result: Jumps to utils.py line 34 ✓
```

## Selecting the Right Result

| What You See                            | What It Means     | Action                      |
| --------------------------------------- | ----------------- | --------------------------- |
| `main.py:12` - `from utils import...`   | Import statement  | Skip this (press `j`)       |
| `uti s.py:34` - `def apply_discount...` | Actual definition | Select this (press `Enter`) |

## Keyboard Navigation in Telescope Picker

| Key       | Action                      |
| --------- | --------------------------- |
| `j`       | Move down to next result    |
| `k`       | Move up to previous result  |
| `<Enter>` | Jump to selected definition |
| `<Esc>`   | Cancel and go back          |
| `/`       | Search within results       |

## Why It Works This Way

The LSP (basedpyright) correctly identifies both locations:

1. Where the symbol is **imported**
2. Where the symbol is **defined**

The Telescope picker shows you **both** so you can choose. You need to select the actual definition, not the import.

## Pro Tips

✅ **Always select the function definition line** (has `def` keyword)  
✅ **Skip the import lines** (have `import` keyword)  
✅ **Use `j` to move down** if the import is listed first

## Related Keybindings

| Key   | Behavior                                                          |
| ----- | ----------------------------------------------------------------- |
| `gd`  | Go to Definition (Telescope picker - shows imports + definitions) |
| `gD`  | Go to Declaration (built-in - jumps directly)                     |
| `grr` | Show References (quickfix - shows all usages)                     |
| `gr`  | Show References (built-in - jumps to first usage)                 |

## Why Not Auto-Select the Definition?

The Telescope picker shows both import and definition because:

1. **Both are valid results** from LSP's perspective
2. **You might want to edit the import** sometimes
3. **It's more transparent** - you see all possibilities
4. **You have control** - choose which one to jump to

## Troubleshooting

### Telescope doesn't open

- Make sure LSP is attached (`:LspInfo`)
- Try restarting Neovim completely
- Check that basedpyright is working (`:Mason`)

### Telescope opens but no results

- LSP might still be indexing files
- Wait a moment, then try again
- Try `:LspRestart` or press `<F4>`

### I keep selecting the import instead of definition

- Look for the line with `def` keyword
- Use arrow keys to navigate carefully
- The definition is usually the second result

## Solution: Use `gD` Instead

If you want a simpler behavior that jumps directly without a picker, use:

```
gD    Go to Declaration (built-in, no picker)

This will jump directly without showing a picker, though it may not follow imports as well.
```

## See Also

- `vim.lsp.buf.definition()` - The underlying LSP function used
- `Telescope lsp_definitions()` - The Telescope picker we use
- `:LspInfo` - Check LSP status
- `K` - Hover documentation (often enough to see where function is)
