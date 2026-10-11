# Neovim Startup Performance

**Measured:** 2026-10-11, Neovim 0.12.6 after the cutover, macOS (Apple silicon), on a busy machine (load average 88
to 122)  
**Startup:** 125 ms (health-check, median of 5) to 144 ms (median of 10) headless, under the 150 ms target

---

## Target

**Goal:** under 150 ms cold boot, measured as `NVIM STARTED` in `--startuptime` for a headless start.
`scripts/health-check` takes the median of five runs after a warm-up, warns above 150 ms and fails above 500 ms.

---

## What Made Startup Slow

Until 2026-10-10 startup was about 400 ms. Most of it was two shell-outs in `init.lua` on every launch, not plugin
loading:

- `io.popen("poetry env info -p")` to pick a Python host. It cost about 240 ms (`poetry env info -p` alone takes 0.24 s)
  and fell back to a hard-coded pyenv path.
- `io.popen("command -v neovim-node-host")`, up to twice, for a Node host that no plugin uses.

The Python host is now the `pynvim` tool from `uv tool install pynvim`, found by path with no subprocess, and the Node
provider is disabled. An interleaved A/B test on 2026-10-10 (10 runs of each config, alternating, isolated data
directories, load average about 6):

| Neovim | Before (median) | After (median) |
| ------ | --------------- | -------------- |
| 0.11.6 | 422 ms          | 139 ms         |
| 0.12.6 | 398 ms          | 138 ms         |

`vim.loader.enable()` also moved to the first line of `init.lua`, so it caches every module, not only those required
after `lua/plugins/lsp.lua`.

---

## Where the Time Goes Now

One `--startuptime` profile on 0.12.6 after the cutover (2026-10-11, `init.lua` 128 ms; inclusive times, so nested
entries overlap):

| Time (ms) | Component                                                           |
| --------- | ------------------------------------------------------------------- |
| 105.4     | `require('plugins')` (lazy.nvim and every non-lazy plugin's config) |
| 20.8      | `require('plugins.mason')`                                          |
| 14.4      | `require('plugins.telescope')`                                      |
| 13.7      | `require('mason-lspconfig')`                                        |
| 12.8      | `require('plugins.lsp')`                                            |
| 10.3      | `require('luasnip.loaders.from_lua')` (custom snippets)             |
| 8.2       | `require('telescope._extensions.harpoon')`                          |

nvim-treesitter `main` loads at startup (`lazy = false`) but costs little: with every parser installed it starts no
install task, and each buffer starts treesitter in a `FileType` autocmd. The order matches the 0.11.6 profile from before
the cutover (`plugins` 112.6 ms, `plugins.mason` 17.7 ms, `plugins.telescope` 15.6 ms, of which 10 ms was project.nvim's
extension, since removed).

**Note:** headless startup fires neither `UIEnter` nor `VeryLazy`, so noice, lualine and the other `VeryLazy` plugins are
not in these numbers. They load after the first screen is drawn.

---

## Measuring

```bash
# Median of five, in the isolated smoke environment (never the real data directory)
./scripts/health-check --isolated

# One profile
nvim --startuptime startup.log --headless +qa
awk '$2 > 5' startup.log

# Interactive profiling (vim-startuptime plugin)
nvim +StartupTime
```

A busy machine inflates every number: at a load average of 50 or more, medians above 500 ms are common. Compare
configurations by alternating runs on the same machine, not by comparing against this page.
