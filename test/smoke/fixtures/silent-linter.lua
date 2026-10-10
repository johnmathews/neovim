-- A linter that runs but reports nothing, as F5 and F6 did.
return {
  description = "luacheck replaced by a command that prints nothing",
  expect = "lua:diags",
  args = { "--only", "lua" },
  append = {
    ["init.lua"] = [[
local lint = require("lint")
lint.linters.luacheck = vim.tbl_extend("force", lint.linters.luacheck, { cmd = "true" })
]],
  },
}
