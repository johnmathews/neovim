# Linux Bootstrap and Plugin Sync

**Date:** 2026-10-11

## Problem

Nothing set up a Linux machine for this config (F9, F10), and nothing brought a machine's plugins in line with
`lazy-lock.json` without a blanket update (F8). The 0.12 cutover needs both: Neovim 0.12.6 and the tree-sitter CLI on
Ubuntu 24.04+, Debian 13+ and Codespaces, and this Mac's November plugin snapshot moved to the lockfile's commits.

## Decisions

- **`scripts/bootstrap-linux`**, idempotent and without prompts. It installs Neovim, the tree-sitter CLI, stylua and
  uv from official release assets into `$PREFIX` (default `~/.local`), each checked against a sha256 pinned in
  `scripts/versions.env`, plus the apt toolchain and uv's pynvim. It refuses glibc below 2.39 and ends by checking the
  `nvim` and `tree-sitter` that PATH resolves, naming any older binary that shadows them.
- **Node from nodejs.org, not apt (F32).** Ubuntu 24.04's apt node is 18.19, and Mason's markdownlint-cli needs node 20
  (it crashed on the regex `v` flag, so markdown had no lint). apt's `npm` also installs Debian's eslint 6.4 into
  `/usr/share/nodejs`, which eslint_d then loaded instead of its own ESLint. `NODE_MIN` is now 20, and the bootstrap
  installs the pinned Node.js 24 tarball when node is missing or older.
- **`scripts/sync-plugins`** restores, installs Mason packages and parsers, cleans, and checks the lockfile is
  unchanged. Rehearsing it on a copy of this Mac's real data dir shaped it more than the plan did:
  - A start that installs any missing plugin makes lazy rewrite every lockfile entry from the installed commits (on
    this Mac, 45 entries), so restore then "restores" each plugin to itself. The script refuses an uncommitted
    lockfile, and after the first restore it puts the committed file back and restores again.
  - lazy cannot move some old checkouts: winresizer's newer commit adds a submodule, and `git checkout
    --recurse-submodules` fails ("could not reset submodule index"). lazy logs it and carries on. The restore now
    compares each plugin with the pins read before it ran (restore itself rewrites the lockfile afterwards), and
    removes and reinstalls any plugin that is not at its pin.
  - The plan's runbook deleted `lazy/nvim-treesitter/parser*` before syncing. On `master` those directories hold
    tracked files, so lazy then saw local changes and left nvim-treesitter on `master`. With the owner's agreement,
    the script deletes them itself, after the restore has moved the plugin to `main`, and puts the tracked files back
    first if someone already deleted them.
  - It only syncs the config Neovim would load, and refuses when that is not its own checkout, so a run from a
    worktree or a CI checkout cannot sync `~/.config/nvim` by mistake.
- It reuses the smoke bootstrap's two phases (`test/smoke/bootstrap.lua`), so CI's sync and the gate's bootstrap run
  the same code. CI now caches the runner's data dir, runs `scripts/sync-plugins`, and seeds the gate from it, which is
  the Linux VM flow. `scripts/smoke --seed-from` also clones `site/`, where `main` keeps its parsers.
- Landed as two commits: `bootstrap-linux` before W14, so the first CI run could use it, and `sync-plugins` after W12,
  because it installs the parser list W12 exports.

## Testing

`bootstrap-linux`, in docker containers with the worktree mounted read-only: ubuntu:24.04 (aarch64, and x86_64 under
emulation) and debian:13 install everything and end `bootstrap: OK: NVIM v0.12.6 …`. A second run prints only "already"
lines. Red: ubuntu:22.04 is refused for glibc 2.35, a zeroed digest stops at "sha256 mismatch", and an older `nvim`
first on PATH is named. CI's runners ship node 20, so only the container runs take the Node tarball path.

`sync-plugins`, in a sandbox whose every XDG and uv directory is in the scratchpad, on a copy of this Mac's
`~/.local/share/nvim`: with the parser directories deleted first (the old runbook order), it puts master's tracked
files back, restores twice, reinstalls winresizer, removes the stale parsers, installs parsers and Mason packages, and
ends with an unchanged lockfile. A second run changes nothing. It refuses (exit 2) an uncommitted lockfile and a
config that is not its checkout. After `:MasonInstall bash-language-server` (W17's new step), the gate seeded from
that data dir passes with 0 failures. Before that it fails `zsh:diags` "lsp:bashls=0, want 3": this Mac's
bash-language-server 5.6.0 does not lint zsh (F36).
