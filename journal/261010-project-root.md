# Project Root Without project.nvim

**Date:** 2026-10-10

## Problem

project.nvim (last commit 2023-04-04) set cwd to the project root and fed `<Tab>p` and the dashboard's "Find project".
When its pattern match finds no root it falls back to LSP detection, which calls `vim.lsp.buf_get_clients()`. 0.12
removed that function apart from a shim (F14), and 0.11 already prints the deprecation. session-lens, the other
dependency, is merged into auto-session (F18), and the config's `load_extension("session-lens")` sat in a `pcall`.

## Decisions

- **A `BufEnter` autocmd with `vim.fs.root`** keeps the behaviour: the same root markers, the same excluded path, an
  INFO notify when cwd changes. It skips buffers with a `buftype` and unnamed buffers. project.nvim's LSP fallback is
  gone; every daily project has one of the markers.
- **Sessions replace projects in the pickers.** `<Tab>p`, the dashboard `p` button and `<localleader>fs` run
  `:AutoSession search`. A session is per directory, so it covers what the project list did.
- The lockfile entries were removed by hand (plan section 1.3). On the Mac, `:Lazy clean` then
  `git checkout -- lazy-lock.json`. `~/.local/share/nvim/project_nvim` can be deleted.

## Testing

New `project_checks` in the python case: cd away, re-enter the buffer, and cwd must be the config root;
`<Tab>p` and `<localleader>fs` must run `AutoSession search`; project.nvim must not be loaded. On the old config the
checks failed on the pickers and the plugin, and the scratch buffer the check opens made project.nvim log
"`vim.lsp.buf_get_clients()` called from plugin project.nvim/lua/project_nvim/project.lua:16" on both versions. The cwd
check passed there, because project.nvim did change cwd. With project.nvim removed and no autocmd yet, it failed
("left cwd at …/cache/nvim"). With the autocmd, both versions pass.
