# GitHub Actions CI on Linux

**Date:** 2026-10-11

## Problem

Nothing checked the config on Linux (F12). Stage A's gate ran only on this Mac, against plugins and Mason packages
that had drifted from what a fresh machine installs, so a Linux VM could break without any signal.

## Decisions

- **`.github/workflows/ci.yml`**: pull requests, pushes to `main`, `workflow_dispatch`, and a Monday run that adds
  `scripts/smoke --strict`. Two legs, `ubuntu-latest` and `ubuntu-24.04-arm`, `permissions: contents: read`, one
  concurrency group per ref, 30-minute timeout.
- Each leg does what a Linux VM does: `scripts/bootstrap-linux`, the checkout linked as `~/.config/nvim`, the data dir
  restored from a cache keyed on the lockfile, `versions.env` and the Mason, LSP and treesitter plugin files,
  `scripts/sync-plugins`, lint, the gate seeded from the data dir, and `scripts/gate-selftest`. A failing step uploads
  the gate's report, logs and LSP log. The first version bootstrapped the gate home with `smoke --bootstrap` instead;
  W11b replaced that once `sync-plugins` existed.
- `SMOKE_HOME` is `${{ github.workspace }}-smoke-home`: outside the checkout, which stylua and the gate's tree copy
  walk, and without `..`, which upload-artifact rejects (the first failing run's upload failed on exactly that).

## Findings CI surfaced

Before the first push, the workflow's steps were replayed in fresh `ubuntu:24.04` containers. That replay, and the
first CI runs, found five problems no Mac run could have shown:

- **F32**: Ubuntu 24.04's apt node 18 breaks Mason's markdownlint-cli, and apt's npm drags in Debian's eslint 6.4,
  which eslint_d then loads. Fixed in `bootstrap-linux` (W11a).
- **F33**: every fresh install rewrote lazy.nvim's lockfile entry, because `plugins.lua` clones lazy.nvim's stable
  branch and lazy records whatever commit it finds. Fixed in W13.
- **F34**: three gate checks depended on the machine. `python:diags` pinned ruff's count, which ruff 0.17 changed;
  the `extra-client` fixture used sqls, which only this Mac's Mason has, so it passed for the wrong reason; and a
  headless runner has no clipboard tool. Fixed in this unit.
- **F35**: Telescope's history database had a hard-coded `~/.local/share/nvim/…` path, so the first picker on a fresh
  machine failed, and the Mac's gate runs reached the real database. Fixed in a follow-up.
- **F36**: bash-language-server 5.8 lints zsh, so a fresh Mason reported every zsh finding twice. The owner gave zsh to
  bashls.

## Testing

The plan wanted CI red on the commit before W12 and W13 without help from `--no-xfail`, and it was: the lockfile
already pinned nvim-treesitter `main`, so the `master`-style config did nothing, and run 38124787384 failed both legs
with `SMOKE FAIL: 40 failed, 10 xfailed` (no highlighter anywhere, unmapped text objects, stale xfail rows). After W12,
W13 and the F35 fix, run 38127983483 passed both legs: `SMOKE PASS: 0 failed, 0 xfailed, 0 warnings`, and gate-selftest
caught all 16 cases. `actionlint` passes the workflow.
