-- The config's own code calls a deprecated Nvim API (F15's class of bug).
return {
  description = "init.lua calls vim.lsp.get_active_clients()",
  expect = "startup:deprecated",
  args = { "--startup-only" },
  append = { ["init.lua"] = "vim.lsp.get_active_clients()" },
}
