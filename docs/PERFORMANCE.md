# Neovim Startup Performance

**Measured:** 2026-10-10, Neovim 0.11.6 and 0.12.6, macOS (Apple silicon), load average about 6
**Startup:** about 140 ms headless (median of 10), under the 150 ms target

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
provider is disabled. An interleaved A/B test (10 runs of each config, alternating, isolated data directories):

| Neovim | Before (median) | After (median) |
| ------ | --------------- | -------------- |
| 0.11.6 | 422 ms          | 139 ms         |
| 0.12.6 | 398 ms          | 138 ms         |

`vim.loader.enable()` also moved to the first line of `init.lua`, so it caches every module, not only those required
after `lua/plugins/lsp.lua`.

---

## Where the Time Goes Now

One `--startuptime` profile on 0.11.6 (total 143 ms; inclusive times, so nested entries overlap):

| Time (ms) | Component                                   |
| --------- | ------------------------------------------- |
| 112.6     | `require('plugins')` (lazy.nvim and every non-lazy plugin's config) |
| 17.7      | `require('plugins.mason')`                  |
| 15.6      | `require('plugins.telescope')`              |
| 10.0      | `require('mason-lspconfig')`                |
| 9.1       | `require('luasnip.loaders.from_lua')` (custom snippets) |
| 6.7       | `require('plugins.lsp')`                    |
| 5.9       | `asyncrun.vim/plugin/asyncrun.vim`          |

0.12.6 shows the same order, a little slower per entry in a single profile (128 ms for `plugins`). The profile predates
the removal of project.nvim: 10 ms of the 15.6 ms for `plugins.telescope` was its telescope extension.

**Note:** headless startup fires neither `UIEnter` nor `VeryLazy`, so noice, lualine and the other `VeryLazy` plugins
are not in these numbers. They load after the first screen is drawn.

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
