-- A server nobody asked for attaches to a daily language (F13's class of bug).
return {
  description = "sqls enabled for python buffers",
  expect = "python:clients",
  args = { "--only", "python" },
  append = {
    ["init.lua"] = [[
vim.lsp.config("sqls", { filetypes = { "python" } })
vim.lsp.enable("sqls")
]],
  },
}
