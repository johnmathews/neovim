-- The filetype maps to a parser that does not exist, as after a failed install (F2).
return {
  description = "python resolves to a missing treesitter parser",
  expect = "python:treesitter",
  args = { "--only", "python" },
  append = { ["init.lua"] = 'vim.treesitter.language.register("smoke_missing_parser", "python")' },
}
