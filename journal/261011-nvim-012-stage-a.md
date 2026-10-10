# Neovim 0.12 Upgrade: Stage A Wrap-up

**Date:** 2026-10-11

Stage A of the 0.11.6 → 0.12.6 upgrade is complete on branch `eng-nvim-012-upgrade`: W1 to W10, W18, and a fix for a
new finding (F31). Each unit has its own journal entry dated 2026-10-10; this entry covers the stage as a whole and the
wrap-up review.

## What was observed

- The smoke gate passes on both versions: `0 failed, 5 xfailed` on 0.11.6 and `0 failed, 35 xfailed` on 0.12.6. Every
  remaining xfail row names a Stage B unit (W12 treesitter, W13 plugin pins). `gate-selftest` catches all 16 of its
  cases on both versions. (confirmed)
- Headless startup is about 140 ms, down from about 400 ms, measured as an interleaved A/B at a load average around 6.
  (confirmed)
- On 0.12.6 a real terminal still shows the rainbow-delimiters error (F4) whenever a file opens, so the Mac must not
  switch to 0.12 before Stage B lands. (confirmed)
- F31, found during the stage: on 0.12 basedpyright used pull diagnostics and about one Python buffer in four opened
  without them. Keeping it on push fixed it; 10 consecutive runs passed afterwards. The mechanism (empty full reports
  under a reused `resultId` when several pulls race) comes from one TRACE log. (strongly supported)

## The wrap-up review

An independent code review and a docs-versus-code audit ran before the PR. Fixed, each seen failing first:

- `scripts/smoke` left its watchdog's `sleep` running, so `smoke | tail` waited the full timeout (40 s observed with
  `--timeout 40`, 3 s after the fix).
- `scripts/smoke --fresh` deleted whatever `--home` pointed at; a test directory with a sentinel file was wiped. It now
  refuses a directory it did not make.
- The Python-host and Mundo checks never ran inside the gate, because the sandbox's `XDG_DATA_HOME` hid uv's tool
  directory. The gate now passes the real one in; with pynvim present, Mundo opens on 0.11.6 and hits the known F4 row
  on 0.12.6.
- `gate-selftest` failed under macOS's `/bin/bash` 3.2 with no pass-through options (`PASS_ARGS[@]: unbound variable`).
- pre-commit checked the working tree, not the staged content, for trailing whitespace.
- `gco`/`gcO` left a stray `x` line in buffers with no commentstring.

One review finding was refuted: a file opened through a symlinked root does not trigger repeated `chdir`, because
Neovim stores the buffer under its resolved path.

The docs audit found about 30 stale claims. Those this branch introduced or touched were fixed: counts, luacheck
paths, the CI example, the TESTING.md check tables, the README scripts tree, `:MasonToolsUpdate`, test/README keys, an
overstated LSP.md sentence, and the dashboard label (now "Find session").

## What is deliberately not done

- **Keymap doc drift that predates this branch** (Harpoon, Leap, gitsigns, NvimTree and others in README.md and
  docs/KEYMAPS.md). W15, the keymap audit with a drift check, owns it.
- **`<Leader>shs` and `<Leader>shr` in `lua/plugins/git-signs.lua`** map to the literal text `Gitsigns: stage_hunk`
  rather than a command, so they type text. Pre-existing and outside every Stage A unit; reported for a decision.
- **noice's write-message route** (W18) never matches but is harmless; left in place rather than deleted unasked.
- **nvim-ts-context-commentstring** looks redundant (native `gc` reads nvim-treesitter's jsx query metadata) but stays
  until W12 confirms the `main` branch queries carry the same metadata.
- Stage B (W11 to W17, W19) is a separate PR.
