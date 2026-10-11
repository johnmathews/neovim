-- A server nobody asked for attaches to a daily language (F13's class of bug).
-- lua_ls, because every machine has it: a server missing from Mason (sqls on a fresh
-- machine) never attaches, and the fixture would pass for the wrong reason.
return {
  description = "lua_ls attached to python buffers",
  expect = "python:clients",
  args = { "--only", "python" },
  append = {
    ["init.lua"] = [[
vim.lsp.config("lua_ls", { filetypes = { "lua", "python" } })
]],
  },
}
