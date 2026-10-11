# Neovim 0.12 Cutover (Stage B)

**Date:** 2026-10-11

## Summary

Stage B of the 0.11.6 → 0.12.6 upgrade is the cutover: one pull request (#10) that makes the config require Neovim 0.12
and the tree-sitter CLI, adds Linux setup and CI, and fixes the keymap docs. It merges only when the Mac is ready to
switch; the per-machine steps are in `docs/UPGRADE-0.12.md`. Each unit has its own entry from today: W11
(`linux-bootstrap-sync`), W12 (`treesitter-main`), W13 (`plugin-pins`), W14 (`linux-ci`), W15 (`keymap-docs`), W19
(`vim-nil`). This one records what holds them together.

## Why a hard cutover

nvim-treesitter's `master` breaks on 0.12 and its `main` needs 0.12, and one lockfile cannot pin both branches. So the
config does not try to run on both: `init.lua` refuses Neovim below 0.12 with one ERROR, before lazy.nvim loads. That
order matters, because an old Neovim that reached lazy would install plugins and rewrite `lazy-lock.json` (F8). aerial
forces the same choice from the other side: the commit with its 0.12 fix (`28fe6e8`) requires 0.12.

## The drift this Mac carries

This Mac's plugins are a November 2025 snapshot, and `lazy-lock.json` is a June 2026 one. Planning compared 46 entries:
44 are plain fast-forwards (up to 383 commits), and two diverged, because the lockfile is on a different branch:
nvim-treesitter's installed `master` commit is 434 commits behind the lockfile's `main` and 1 ahead of it, and
textobjects is 92 behind and 40 ahead. leap.nvim (Codeberg) and `snacks.nvim` (no spec; now removed) could not be
compared. Two things followed from that drift and only showed up when `scripts/sync-plugins` was rehearsed on a copy of
the real data dir:

- Any start that installs a missing plugin makes lazy rewrite every lockfile entry from the installed commits. On this
  Mac that rewrote 45 entries, after which a restore "restored" every plugin to itself. `scripts/sync-plugins` puts the
  committed lockfile back and restores again.
- The plan's runbook deleted `lazy/nvim-treesitter/parser*` before syncing. On `master` those directories hold tracked
  files, so lazy saw local changes and kept nvim-treesitter on `master`. The script now deletes them after the restore,
  by the owner's decision, and winresizer, whose checkout fails on a submodule its new commit adds, is reinstalled.

## Linux and glibc 2.39

The official Neovim and tree-sitter binaries need a recent glibc, so Linux support starts at Ubuntu 24.04 and Debian 13
(glibc 2.39 and 2.41); `scripts/bootstrap-linux` refuses older releases by name. Ubuntu 24.04's apt node 18 turned out to
be too old for Mason's markdownlint-cli, and apt's npm installs a Debian eslint that eslint_d then loads, so the
bootstrap installs Node.js from nodejs.org instead (F32).

## What CI found that the Mac could not

Replaying CI in containers before the first push, and the first CI runs, produced five new findings: Linux node (F32),
lazy.nvim's own lockfile entry rewritten on every fresh install (F33), three gate checks that depended on this machine
(F34), Telescope's history database at a hard-coded `~/.local/share` path, which also let the gate's sandbox reach the
real database (F35), and bash-language-server 5.8 linting zsh next to nvim-lint (F36, so bashls now owns zsh). Before
W12, CI was red on both legs without any `--no-xfail` help; after W12, W13 and the F35 fix it was green, and it stayed
green through W15.

## Owner decisions in Stage B

- Issue #7 (gitsigns hunk keys) joined W15.
- bashls owns zsh lint (F36); W17 gains `:MasonInstall bash-language-server`.
- nvim-ts-context-commentstring removed: `main`'s jsx query keeps the commentstring metadata native `gc` reads.
- `scripts/sync-plugins` deletes the stale parser directories itself; W17 drops its separate `rm -rf` step.

## Wrap-up review (/done)

Two independent passes ran before the final push: a docs-versus-code audit and a code review. Both found real problems.

- **The tools phase hid failed installs** (confirmed). A parser that failed to build, or a Mason install that hung, still
  left the phase at exit 0, so `scripts/sync-plugins` would have printed OK. The red run reproduced it: a missing
  `fish.so` with `CC=false` exited 0. The fix needed a second look. `nvim-treesitter.get_installed()` also counts query
  directories, so a language whose parser is gone but whose queries remain counts as installed and `install()` skips it.
  That is also how a half-installed machine stays broken. The bootstrap and `lua/plugins/treesitter.lua` now compute
  missing parsers from `get_installed("parsers")` and force their rebuild. The bootstrap then fails on any parser or
  Mason package (servers plus the list `lua/plugins/mason.lua` now exports) that is still not installed. After the fix
  the same run fails with "parser not installed: fish", and with a working compiler it rebuilds `fish.so`.
- **The reinstall deleted before it knew it could clone** (confirmed by reading). A plugin lazy could not move is now
  moved aside and put back if the reinstall fails; lazy.nvim itself is never touched, since the running process uses it.
  A full sync of the Mac snapshot reinstalled winresizer this way and left no leftovers.
- **A failed sync left the lockfile rewritten** (confirmed with a fake `nvim` that rewrites it and fails): the script now
  puts the committed `lazy-lock.json` back on failure, so a retry needs no manual `git checkout`.
- **Docs drift the unit work missed** (confirmed): the demo guides still described a Telescope `gd` and the unmapped
  `gr`/`gi`, so two of them were archived and four corrected. Also fixed: plugin and file counts in TESTING.md and
  README, the xfail wording now that the list is empty, Harpoon's load time, the AGENTS OS line, and a missing
  `bootstrap-linux` section in TESTING.md. One CI defect came out of it: the failure upload globbed the self-test logs
  inside `SMOKE_HOME`, but gate-selftest writes them beside it.

## What is deliberately not done

- W17 and the tag are the owner's.
- Mason package versions stay unpinned (above).
- The Mason branch of the new install check was not driven red: making one Mason install fail on demand needs a broken
  registry or network. Its success branch ran on every bootstrap since.

## Left for later

- W17 itself: the owner's per-machine cutover, the `pre-nvim-0.12` tag, and archiving `docs/UPGRADE-0.12.md` once every
  machine has moved.
- nvim-tree's global bookmark keys `zc`, `zn`, `zl` and `zs` replace Vim's fold and scroll commands (documented, not
  changed).
- Mason packages float to their latest version on a fresh install (ruff, bash-language-server and eslint_d all differed
  from this Mac's). Pinning them would make machines identical; no unit asked for it.
