-- nvim-lint runs a tool the LSP server already runs (F13's class of bug).
return {
  description = "nvim-lint runs shellcheck on sh and bash, which bashls already does",
  expect = "bash:diags",
  args = { "--only", "bash" },
  append = {
    -- test/bash/test_sample.sh has filetype sh
    ["lua/plugins/nvim-lint.lua"] = [[
lint.linters_by_ft.sh = { "shellcheck" }
lint.linters_by_ft.bash = { "shellcheck" }
]],
  },
}
