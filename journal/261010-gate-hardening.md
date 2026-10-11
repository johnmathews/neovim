# Gate Hardening: quality-gate, health-check and Hooks

**Date:** 2026-10-10

## Problem

The gate scripts passed when their preconditions were false (F7). `quality-gate` treated `stylua: command not found`
as clean formatting, because it grepped stylua's output for "Diff" instead of reading the exit code. Its load test
printed `OK` after an init error. `health-check` always exited 0, accumulated startup readings in one fixed `/tmp`
log, and checked no version minimum. The git hooks were `.git/hooks` symlinks that `cd`'d relative to the symlink, so
a commit in a worktree ran the main checkout's `quality-gate` on the main checkout's files (F21).

## Decisions

- **Missing tools fail.** `quality-gate` and `health-check` check `command -v` before running a tool.
- **The load test is the smoke gate.** `quality-gate` runs `scripts/smoke --startup-only`, which fails on an init
  error, an unexplained message, a missing formatter or linter, and a deprecated API in the config's own files.
- **The deprecated-API scan lives in the smoke engine, not in `quality-gate`.** The plan asked for an `rg` scan with
  xfail rows. Implementing it as the engine's `scan:deprecated` check reuses `test/smoke/xfail.lua`, including its
  stale-entry rule, so W3, W4 and W5 delete scan rows the same way they delete runtime rows. `quality-gate` still runs
  it through `--startup-only`.
- **Versions live in `scripts/versions.env`.** `NVIM_MIN` fails, `NVIM_PIN` warns, `TREE_SITTER_MIN` empty means the CLI
  is not required yet. The 0.12 cutover raises them. Comparison uses `vim.version.lt` in a clean Nvim.
- **Startup is a median.** One warm-up, then five runs with a fresh `mktemp` log each. It fails above 500 ms and warns
  above 150 ms until the startup work lands.
- **`health-check --isolated`** runs startup and `:checkhealth` in `SMOKE_HOME`, so agents and CI never start the real
  config. The default still measures the real config, which is what the user starts every day.
- **`core.hooksPath = scripts`.** Git resolves a relative hooks path against the working tree being committed, so each
  worktree runs its own `scripts/pre-commit` on its own files. `install-hooks` also removes the old symlinks.
- **pre-push runs the full smoke gate** after `quality-gate`. An unbootstrapped environment exits 2 and blocks the
  push with the seeding instructions. It is never skipped.

## Testing the gates

`scripts/gate-selftest` gained gate cases that feed known-false preconditions from outside the scripts: PATH
mirrors without stylua or luacheck, a working-tree copy with an `error()` in `lua/options.lua`, an `nvim` shim reporting
0.11.6 against `NVIM_MIN=0.12.0`, and a `tree-sitter` shim reporting 0.25.0 against `TREE_SITTER_MIN=0.26.1`. Against
the old scripts, four of the five exited 0. The luacheck case exited 1 only because the bare `luacheck` call failed,
without naming the missing tool. With the new scripts all five exit 1 with the expected message.

The old scripts launch bare `nvim` against the real config. The red run therefore exported every `XDG_*` directory to a
sandbox first.

## Hook acceptance and the GIT_DIR trap

A worktree commit through `git -c core.hooksPath=scripts commit` with a formatting break staged was blocked, but the
first attempt showed why: `quality-gate` printed "Formatting correct". Git exports `GIT_DIR` and `GIT_INDEX_FILE` to
hooks, and with `GIT_DIR` set, `git -C scripts rev-parse --show-toplevel` returns `scripts/` itself, so the gate ran
stylua on a directory with no Lua in it. The scripts now resolve their root from their own path and unset
`git rev-parse --local-env-vars` before calling git. That matters most in `scripts/smoke`, whose `git init` in the
config copy would otherwise act on the committing repository. A sixth gate case, `qg-hook-env`, runs `quality-gate`
with `GIT_DIR` exported on a copy with a formatting break. With the fix, the blocked commit reports the formatting
failure, and W2 itself was committed through the worktree's own pre-commit hook.
