-- An error after every module loaded: only the message scan can see it.
return {
  description = "error() at the end of init.lua",
  expect = "startup:messages",
  args = { "--startup-only" },
  append = { ["init.lua"] = 'error("SMOKE_FIXTURE_LATE_INIT_ERROR")' },
}
