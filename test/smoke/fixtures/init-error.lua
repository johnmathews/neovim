-- An error early in init.lua's require chain stops every later module loading.
-- Headless startup still exits 0 here, which is how the old load test missed it (F7).
return {
  description = "error() in lua/options.lua",
  expect = "startup:modules",
  args = { "--startup-only" },
  append = { ["lua/options.lua"] = 'error("SMOKE_FIXTURE_INIT_ERROR")' },
}
