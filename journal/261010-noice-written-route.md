# Verifying the noice "written" Route

**Date:** 2026-10-10

## Question

`lua/plugins/noice.lua` has a route that skips `msg_show` messages of `kind = ""` containing "written". The evaluation
suspected the kind never matches (F28): if so, every `:w` would raise a popup, and if not, changing the filter would be
churn. A headless `:w` could not tell, because headless Neovim does not route messages the way a terminal does.

## Method

A real terminal session in a pty (`script -q /dev/null nvim …`), with sandboxed data directories, on 0.11.6 and 0.12.6.
A probe wrote a file, waited a second, listed the floating windows, and dumped noice's message history and
`require("notify").history()`.

## Result

- The route never matches. The write message has `kind = "bufwrite"` on 0.11.6 and `kind = "progress"` on 0.12.6.
- There is no popup either way. noice's own "Messages" route only shows the kinds `""`, `echo`, `echomsg`,
  `lua_print` and `list_cmd`, so the write message reaches no view. No float held it and the notify history was empty
  on both versions.

So the route is dead config, and harmless. No change was made: making it match would change nothing, and widening
noice's routing would start showing write messages. It can be deleted.

The 0.12.6 session also showed the rainbow-delimiters error from F4 when any file opens, stopping at a `-- More --`
prompt. That is expected until the plugin-pin unit (W13) lands.
