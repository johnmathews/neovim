-- A described mapping under <leader> that docs/KEYMAPS.md does not list (F20, the other direction).
return {
  description = "<leader>zq mapped with a desc, missing from docs/KEYMAPS.md",
  expect = "keymaps:undocumented",
  args = { "--only", "python" },
  append = {
    ["init.lua"] = [[
vim.keymap.set("n", "<leader>zq", "<Nop>", { desc = "Fixture: mapped but not documented" })
]],
  },
}
