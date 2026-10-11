# sync-plugins: Put the Lockfile Back When Killed

**Date:** 2026-10-11

## How It Surfaced

Reviewing the codespaces-setup branch that hands Neovim setup to `bootstrap-linux` and `sync-plugins`. That branch runs
`sync-plugins` under `timeout --kill-after=10` with three attempts. The question was whether a timed-out attempt leaves
anything that stops the next one.

It does. `sync-plugins` refuses an uncommitted `lazy-lock.json` (exit 2), and relies on its EXIT trap to put the
committed file back after a failure. The trap checks `$?`, and when bash exits on a signal it runs the EXIT trap with
`$?` = 0. So a killed run skipped the restore and left the lockfile lazy had rewritten. (The process still reported 143:
bash re-raises the signal after the trap, so the exit code looked right while the clean-up had not happened.) Every retry
then refused. The same happened on Ctrl-C or a closed terminal on any machine.

Reproduced in an Ubuntu 24.04 container with the trap copied verbatim: a process-group kill through `timeout`, and a
SIGTERM to the script alone, both left the lockfile modified.

## Fix

`trap 'exit 129' HUP`, `trap 'exit 130' INT` and `trap 'exit 143' TERM` beside the EXIT trap. The signal trap's `exit`
sets the status the EXIT trap then sees, so the restore runs and the exit is a failure. Bash runs a signal trap only
after the foreground child exits, so this relies on the signal reaching the child too. A timeout, a terminal's Ctrl-C and
a hangup all signal the whole process group, so they do.

## Test

gate-selftest gained `sync-killed`. A Neovim stand-in reports a version and the config and data directories, then its
plugin phase appends to `lazy-lock.json` and sleeps. The case starts `sync-plugins` in its own process group (job
control), kills the group once the lockfile is dirty, and requires a non-zero exit with the lockfile clean. It failed on
the old script (`exit 143, lazy-lock.json left modified`) and passes on the new one.
