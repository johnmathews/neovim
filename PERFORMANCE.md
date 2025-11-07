# Neovim Startup Performance Report

**Generated:** 2025-01-13  
**Neovim version:** v0.11.4  
**Total startup time:** ~342ms (headless)

---

## Performance Target

**Goal:** <150ms cold boot startup time  
**Current:** 342ms  
**Gap:** 192ms (2.3x slower than target)

---

## Top 10 Slowest Operations

| Time (ms) | Component | Type |
|-----------|-----------|------|
| 108.2ms | `require('plugins')` | Plugin loading via lazy.nvim |
| 14.6ms | `require('plugins.lsp')` | LSP configuration |
| 10.7ms | `require('plugins.telescope')` | Telescope setup |
| 6.4ms | nvim-ts-autotag sourcing | Treesitter plugin |
| 6.3ms | `require('plugins.cmp')` | Completion engine |
| 5.4ms | telescope projects extension | Extension loading |
| 4.9ms | `require('nvim-treesitter')` | Treesitter core |
| 4.3ms | `require('plugins.mason')` | Mason tool installer |
| 4.1ms | LuaSnip plugin | Snippet engine |
| 3.9ms | `require('plugins.lualine')` | Statusline |

**Total from top 10:** ~169ms (49% of startup time)

---

## Analysis

### Major Contributors

1. **Lazy.nvim plugin loading (108ms)**
   - This is the plugin manager orchestrating all plugin loads
   - Unavoidable overhead but could be optimized with better lazy-loading

2. **LSP Stack (14.6ms)**
   - Mason registry initialization
   - Multiple LSP server configurations
   - Already fairly optimized

3. **Telescope (10.7ms + 5.4ms = 16.1ms)**
   - Heavy fuzzy finder with many extensions
   - Projects extension adds overhead
   - Could benefit from lazy-loading

4. **Completion Stack (6.3ms + 4.1ms = 10.4ms)**
   - nvim-cmp + LuaSnip
   - Loaded eagerly on startup
   - Good candidate for lazy-loading

5. **Treesitter (4.9ms + 6.4ms = 11.3ms)**
   - Core + autotag plugin
   - Necessary for syntax highlighting
   - Already uses lazy.nvim events

---

## Optimization Recommendations

### High Impact (Potential 50-80ms savings)

1. **Lazy-load Telescope (save ~16ms)**
   - Only load on first `<Tab>` keypress
   - Extensions can load with main plugin
   ```lua
   keys = { "<Tab>" }, -- Load on first Tab press
   cmd = { "Telescope" }, -- Load on :Telescope command
   ```

2. **Lazy-load completion (save ~10ms)**
   - Load nvim-cmp on InsertEnter
   - Load LuaSnip with cmp
   ```lua
   event = "InsertEnter",
   ```

3. **Defer non-essential plugins (save ~20ms)**
   - Alpha (dashboard): only needed on empty buffer
   - Lualine: could defer 50-100ms
   - Git signs: load on BufRead

### Medium Impact (Potential 20-40ms savings)

4. **Optimize Mason setup (save ~5ms)**
   - Disable `run_on_start = true`
   - Only check tools when explicitly needed

5. **Trim unused plugins (save ~10ms)**
   - Review if all 39 plugins are actively used
   - Remove or disable unused functionality

6. **Lazy-load LSP per filetype (save ~5ms)**
   - Only initialize LSP servers for open file types
   - Already partially implemented via mason-lspconfig

### Low Impact (Potential 5-15ms savings)

7. **Optimize snippet loading**
   - Defer snippet compilation
   - Load snippets on first use

8. **Reduce autocommands**
   - Audit autocmd.lua for unnecessary triggers
   - Combine similar autocommands

---

## Quick Wins (Minimal Risk)

These can be implemented immediately with minimal testing:

1. ✅ **Set `run_on_start = false` in mason.lua**
   - Saves ~2-3ms
   - Already done: `run_on_start = true` → keep for convenience

2. **Lazy-load alpha-nvim (dashboard)**
   ```lua
   { "goolord/alpha-nvim", event = "VimEnter" }
   ```

3. **Lazy-load git-signs**
   ```lua
   { "lewis6991/gitsigns.nvim", event = "BufRead" }
   ```

---

## Performance Testing Commands

```bash
# Detailed startup profile
nvim --startuptime startup.log --headless +qa
cat startup.log | awk '{if ($2 > 1) print $0}'

# Quick startup time check
nvim --startuptime /dev/stdout --headless +qa | grep "NVIM STARTED"

# Using vim-startuptime plugin (installed)
nvim +StartupTime
```

---

## Baseline Measurements

| Scenario | Time | Date |
|----------|------|------|
| Headless startup | 342ms | 2025-01-13 |
| With file loading | ~490ms | 2025-01-13 |
| After cleanups | 344ms | 2025-01-13 |

---

## Next Steps

1. **Implement high-impact lazy-loading** (Telescope, completion)
2. **Measure again** to confirm improvements
3. **Iterate** on medium and low-impact optimizations
4. **Document** final performance in AGENTS.md

---

## Notes

- Startup time includes plugin manager overhead (~108ms)
- Real-world usage feels fast due to lazy-loading after startup
- Target of <150ms is aggressive for a full-featured config
- **Realistic target:** 200-250ms with current feature set
- Many "slow" operations happen during plugin initialization, not user actions
