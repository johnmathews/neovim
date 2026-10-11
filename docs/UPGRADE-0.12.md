# Upgrade to Neovim 0.12.6

> Purpose
>
> The one-time runbook for moving each machine from Neovim 0.11.6 to 0.12.6, after the Stage B pull request merges. It
> holds the per-machine steps (plan unit W17), the rollback, and the rules for `lazy-lock.json` during the switch.
> Archive it to `docs/archive/` once every machine has migrated.

## 1. What changes

This is a hard cutover. From the Stage B merge on, the config needs Neovim 0.12 and the tree-sitter CLI:

- `init.lua` checks the version first. On Neovim below 0.12 it prints one ERROR,
  `config requires Neovim 0.12.6, see docs/UPGRADE-0.12.md`, and stops before lazy.nvim loads, so an old Neovim never
  installs plugins or rewrites the lockfile. A dual config is not possible: one lockfile cannot hold both nvim-treesitter
  branches.
- nvim-treesitter moves to its `main` branch, which builds parsers with the tree-sitter CLI (0.26.1 or later) and a C
  compiler, and keeps them in `~/.local/share/nvim/site/parser/`. The parser binaries `master` built in
  `lazy/nvim-treesitter/parser*` are stale and would load first; `scripts/sync-plugins` deletes them.
- aerial moves to a commit that needs 0.12, telescope-ui-select replaces dressing.nvim, and nvim-ts-context-commentstring
  is gone (`docs/CHANGELOG.md`, 2.0.0).
- Linux machines need glibc 2.39 or later: Ubuntu 24.04+ or Debian 13+. `scripts/bootstrap-linux` refuses older releases
  with a clear message.

## 2. Before you start

- Tag the last commit before the merge and push the tag: it is the rollback point.

  ```bash
  git tag pre-nvim-0.12 <last pre-merge commit> && git push origin pre-nvim-0.12
  ```

- `lazy-lock.json` must have no local changes on the machine (`git -C ~/.config/nvim status`). If lazy rewrote it, run
  `git checkout -- lazy-lock.json`. `scripts/sync-plugins` refuses to run otherwise.
- Stage B rehearsed the Mac steps in a sandbox: a copy of this Mac's data dir, the 0.12.6 tarball instead of brew, every
  XDG and uv directory in a scratch directory. The record is in the Stage B pull request.

## 3. Mac

1. Beforehand: `brew install tree-sitter-cli`. Keep the official v0.11.6 `nvim-macos-arm64.tar.gz` in `~/.local/opt/` as
   a fallback, because `brew upgrade` removes the old keg.
2. Rehearse in a sandbox clone of the data dir.
3. Close every nvim. Back up with `cp -Rc ~/.local/share/nvim ~/.local/share/nvim.pre-0.12`.
4. `brew upgrade neovim && brew pin neovim`.
5. `cd ~/.config/nvim && git pull` (the merged Stage B; added in Stage B: the steps had no update).
6. `uv tool install --upgrade pynvim`.
7. `scripts/sync-plugins`. It also deletes `lazy/nvim-treesitter/parser*` once nvim-treesitter is on `main` (F17). Stage
   B moved that out of a separate `rm -rf` step, by the owner's decision: run before the restore, the `rm -rf` deleted
   files master tracks, and lazy then refused to move nvim-treesitter off master.
8. In Neovim, `:MasonInstall bash-language-server` (5.8 or later lints zsh; added in Stage B for F36).
9. `scripts/smoke --seed-from ~/.local/share/nvim` (the first run per Neovim version needs a seeded home; added in Stage
   B), then check by hand `<leader>o`, `vaf` and `:checkhealth`.

Done when `nvim --version` shows v0.12.6, `git diff --exit-code lazy-lock.json` is clean, `scripts/smoke` passes, and no
`~/.local/share/nvim/lazy/nvim-treesitter/parser*` directory remains.

## 4. Each Linux VM

`git pull`, `scripts/bootstrap-linux`, `scripts/sync-plugins`, `:MasonInstall bash-language-server` where Mason already
held it, `scripts/smoke --seed-from ~/.local/share/nvim`.

Run them from `~/.config/nvim`. `scripts/bootstrap-linux` installs Neovim 0.12.6 into `~/.local/opt/nvim-v0.12.6` with a
`~/.local/bin/nvim` link, the tree-sitter CLI, stylua, uv and uv's pynvim, node when the machine's is missing or older
than 20, and the apt packages, all at the versions and digests in `scripts/versions.env`. It uses `sudo apt-get`;
`SKIP_APT=1` skips apt. `~/.local/bin` must come first on `PATH`: the script ends by naming any older `nvim` or
`tree-sitter` that shadows the new one.

## 5. Codespaces

Add this to the dotfiles repository's `install.sh`, then create a fresh Codespace. The Codespace image must be Ubuntu
24.04 or later (glibc 2.39).

```sh
#!/bin/sh
# Neovim config: clone it, install Neovim 0.12.6 and its tools, sync plugins
set -e
[ -d "$HOME/.config/nvim" ] || git clone https://github.com/johnmathews/neovim "$HOME/.config/nvim"
"$HOME/.config/nvim/scripts/bootstrap-linux"
export PATH="$HOME/.local/bin:$PATH"
cd "$HOME/.config/nvim" && scripts/sync-plugins
```

## 6. Rollback

- **Mac:** check out the tag, swap the data dir back from `nvim.pre-0.12`, and put the 0.11.6 tarball first on `PATH`.
- **Linux:** remove the `~/.local/bin/nvim` symlink, check out the tag, `Lazy! restore`, and move
  `~/.local/share/nvim/site` aside.
- **Everywhere:** `git revert -m 1 <merge>`.

## 7. Lockfile rules during the switch

This Mac's installed plugins are a November 2025 snapshot, and `lazy-lock.json` is newer. Any lazy operation on an
unconverged Mac (install, clean, sync) rewrites its stale entries in the working tree. A start that installs even one
missing plugin makes lazy rewrite every entry from the commits it finds installed.

1. Until the Mac has converged, never commit a `lazy-lock.json` that lazy wrote on it. After pulling, run
   `git checkout -- lazy-lock.json` before `scripts/sync-plugins`.
2. Linux machines only ever restore (`scripts/sync-plugins`); they never run `:Lazy update` or `:Lazy sync`.
3. After the switch, any machine may write the lockfile, and `git diff --exit-code lazy-lock.json` after
   `scripts/sync-plugins` must stay clean. The script checks that itself.

## 8. Where each command lives

Every command above that can be scripted runs inside `scripts/bootstrap-linux`, `scripts/sync-plugins`, `scripts/smoke`
or `.github/workflows/ci.yml`, and CI runs the Linux steps on every pull request. The rest change this machine or need
you: `brew install`, `brew upgrade` and `brew pin`, the `cp -Rc` backup, `git tag`, `git pull`,
`uv tool install --upgrade pynvim` (the Linux bootstrap runs `uv tool install pynvim`), `:MasonInstall` inside Neovim,
the hand checks, and the rollback.
