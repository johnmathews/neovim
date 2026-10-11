-- A per-server override that changes a setting the gate pins (F1's class of bug).
return {
  description = "after/lsp/basedpyright.lua sets typeCheckingMode = strict",
  expect = "python:settings",
  args = { "--only", "python" },
  write = {
    ["after/lsp/basedpyright.lua"] = [[
return { settings = { basedpyright = { analysis = { typeCheckingMode = "strict" } } } }
]],
  },
}
