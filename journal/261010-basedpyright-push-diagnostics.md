# basedpyright Push Diagnostics on 0.12

**Date:** 2026-10-10

## Problem

On Neovim 0.12.6 the smoke gate's python case failed about one run in four with `lsp:basedpyright=0, want 4`, while
ruff reported normally. It never failed on 0.11.6. A TRACE LSP log of a failing run showed why. 0.12 advertises
`textDocument.diagnostic.dynamicRegistration = true` (0.11 advertises `false`), so basedpyright registers pull
diagnostics, twice under the same identifier. Neovim sends several concurrent pulls for the buffer. basedpyright
answered the last two with empty full reports under `resultId = "3"`, the id earlier non-empty reports had carried,
so later pulls returned `unchanged` and the buffer kept no diagnostics until its text changed. This is finding F31,
found during Stage A rather than in the evaluation.

## Decisions

- **Keep basedpyright on push**, as on 0.11: `capabilities.textDocument.diagnostic.dynamicRegistration = false` in
  `after/lsp/basedpyright.lua`. Only basedpyright changes; other servers keep 0.12's defaults.
- Landed as its own commit between W6 and W7. It belongs to W3's LSP configuration, which was already merged into the
  branch, and it was making every later unit's 0.12 runs flaky.

## Testing

A new deterministic check, `python:pull`, fails when any basedpyright pull-diagnostic namespace exists. Every 0.12 run
created one (`nvim.lsp.basedpyright.1.basedpyright`), passing or not, so the check is red on 0.12.6 before the fix and
does not depend on hitting the race. After the fix both versions pass and basedpyright reports its 4 diagnostics.
Ten more `--only python` runs on 0.12.6 after the fix, two at a time at load averages of 70 to 115, all reported
`lsp:basedpyright=4`. At the earlier rate of about one failure in four, ten clean runs would happen by chance about 6%
of the time.
