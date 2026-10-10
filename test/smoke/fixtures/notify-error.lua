-- An ERROR notify sent after nvim-notify and noice have replaced vim.notify.
return {
  description = "vim.notify at ERROR after VeryLazy",
  expect = "startup:notify",
  args = { "--startup-only" },
  append = {
    ["init.lua"] = [[
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    vim.schedule(function()
      vim.notify("SMOKE_FIXTURE_NOTIFY_ERROR", vim.log.levels.ERROR)
    end)
  end,
})
]],
  },
}
