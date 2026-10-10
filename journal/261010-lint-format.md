# Lint and Format Ownership

**Date:** 2026-10-10

## Problem

Three lint paths were broken and one ran twice:

- The zsh override took nvim-lint's shared `shellcheck` table and rewrote its `args`, so sh and bash ran with zsh's
  arguments, and it asked for `--format=json`, which nvim-lint's json1 parser cannot read. zsh got no diagnostics (F5).
- `markdownlint.args` was a function. nvim-lint only accepts a list, so every markdown lint run failed with "expected
  table, got function" (F6).
- nvim-lint ran ruff on Python and shellcheck on sh and bash, while the ruff LSP server and bashls report the same
  findings (F13).
- conform used the deprecated `lsp_fallback` and listed an unknown formatter `lsp` for YAML (F25). SQL had no formatter.

## Decisions

- **Copies, not aliases.** `shellcheck_zsh` is `vim.tbl_extend("force", {}, shellcheck, { args = ... })`, and
  markdownlint is a function that returns a copy of the stock linter with list `args`. Neither touches the shared table.
- **The LSP server owns lint where it has one.** ruff (LSP) for Python, bashls for sh and bash. nvim-lint keeps zsh,
  because bashls does not shellcheck zsh.
- **sqlfluff on `<leader>cf` only.** It is too slow for the 1000 ms save timeout, so `format_on_save` returns nil for
  SQL. Without a `.sqlfluff` the dialect defaults to postgres (bigquery for `.bq`), and exit code 1 counts as success
  because sqlfluff returns it when some violations remain after fixing.
- **`default_format_opts`** carries `lsp_format = "fallback"` for both format on save and `<leader>cf`.
- Mason now lists every tool the format and lint config calls: sqlfluff, yamlfmt, jq, shellcheck and jsonlint were
  missing and only present on machines that had installed them by hand.

## Testing

Deleting this unit's xfail rows and adding the `sql:format` check turned the gate red on both versions: 15 failures
each. They were the YAML `lsp` formatter, five deprecated-API scan hits, ruff reported by both owners (`ruff=4` and four
duplicates), `shellcheck_zsh=0`, `markdownlint=0` with its "expected table, got function" notify, and "conform.format()
ran no formatter on the SQL buffer". After the change 0.11.6 passes. On 0.12.6 zsh still gets no lint diagnostics. The installed
rainbow-delimiters throws in zsh's FileType autocmd (`zsh:open`), and with `vim.g.rainbow_delimiters = { blacklist = { "zsh" } }`
the same buffer gets `shellcheck_zsh = 3` on 0.12.6. That row stays in `xfail.lua` for 0.12 only, owned by the plugin-pin unit (W13).

The bash case could not go red before the fix, because the F5 alias had broken nvim-lint's bash shellcheck too. A new
self-test fixture, `double-linter`, re-adds it for sh and bash and must fail `bash:diags`. Its first version set only
`bash` and passed: the sample's filetype is `sh`. The probe also showed the duplicates check cannot pair these, because
bashls reports `SC2034` where nvim-lint reports `2034`. The per-owner count is what catches it.
