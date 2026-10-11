-- A key the docs describe that the config does not map (F20: the docs had drifted).
return {
  description = "docs/KEYMAPS.md documents <leader>zq, which nothing maps",
  expect = "keymaps:documented",
  args = { "--only", "python" },
  append = {
    ["docs/KEYMAPS.md"] = [[
| Key          | Mode   | Description                          |
| ------------ | ------ | ------------------------------------ |
| `<leader>zq` | Normal | Fixture: documented but never mapped |
]],
  },
}
