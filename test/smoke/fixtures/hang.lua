-- Nvim stops responding: the bash watchdog must end the run with exit code 3.
return {
  description = "busy loop after startup",
  expect_exit = 3,
  args = { "--startup-only", "--timeout", "20" },
  append = { ["init.lua"] = "vim.defer_fn(function() while true do end end, 200)" },
}
