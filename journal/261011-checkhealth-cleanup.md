# Checkhealth Cleanup and the File-Opening Keys

**Date:** 2026-10-11

## Context

The first `:checkhealth` after the 0.12.6 cutover showed eight warnings that config could fix. At the same time
`<leader>x` did two jobs: on its own it opened the file in the default app (`vim.ui.open`), and it was also Trouble's
prefix, so which-key waited on every press. `<leader>X` (Typora) was global, though it only makes sense for Markdown.

## Decisions

- **`<leader>x` is Trouble's only.** The "open in default app" mapping is gone. Nothing replaces it: Finder and Typora
  cover what it was used for.
- **`<leader>F` reveals the file in Finder** (`open -R`, which selects it). On Linux there is no Finder, so it opens the
  file's folder with `vim.ui.open`. That keeps the key working on the Codespaces and VM machines without a second code
  path to maintain.
- **`<leader>X` is buffer-local in `ftplugin/markdown.vim`**, next to `<leader>mp`, so it appears only where it applies.

## Warnings Fixed

| Warning                                                               | Fix                                                                      |
| --------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| lazy: Lua 5.1 / luarocks not found (2)                                | `rocks = { enabled = false }`: no plugin installs from luarocks          |
| noice: `regex` parser not installed                                   | `regex` added to the treesitter list (19 parsers)                        |
| vim.lsp: unknown filetypes `yaml.docker-compose`, `yaml.gitlab`, etc. | `after/lsp/yamlls.lua` sets `filetypes = { "yaml" }`                     |
| vim.lsp: unknown filetype `markdown.mdx`                              | new `after/lsp/marksman.lua` with `filetypes = { "markdown" }`           |
| vim.lsp: buffers with mixed position encodings                        | `capabilities.general.positionEncodings = { "utf-16" }` for every client |

The encoding warning came from Python buffers: basedpyright negotiated utf-16 and ruff utf-8. A probe on the sample file
recorded that before the change and `utf-16` for both after it.

## Not Fixed, by Design

- which-key's overlap notices come from plugin defaults (marks.nvim `m`/`dm`, nvim-surround `ys`, Vim's `a`/`i`
  textobjects) and the Space→`<Nop>` leader mapping. which-key labels them informational.
- Mason's missing-language warnings (PHP, Composer, Java, Julia) are about toolchains this machine doesn't have and no
  configured package needs.

## Verification

- Smoke case `markdown`, red first on the old code (3 failures: `<leader>F` unmapped, `<leader>x` still mapped,
  `<leader>X` global), then green.
- `scripts/smoke` on 0.12.6: `SMOKE PASS: 0 failed, 0 xfailed, 0 warnings`. `gate-selftest`: every case caught.
- A sandboxed `:checkhealth` probe went from 10 warning or error lines to 1 (which-key's standing disclaimer). The ERROR
  line in the baseline came from the probe forcing which-key's buffer state headless; that step was dropped.

Machines pick up the regex parser on the next start, or with `scripts/sync-plugins`.
