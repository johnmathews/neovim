-- lua/plugins/nvim-lint.lua

local uv = vim.uv or vim.loop
local lint = require("lint")

local function has_linter(bufnr)
  local ft = vim.bo[bufnr].filetype
  return ft ~= "" and lint.linters_by_ft[ft] ~= nil
end

local function run_lint(bufnr)
  if has_linter(bufnr) then
    lint.try_lint()
  end
end

local function stop_timer(timer, bufnr, timers)
  if not timer or (uv.is_closing and uv.is_closing(timer)) then
    return
  end
  timer:stop()
  timer:close()
  timers[bufnr] = nil
end

local lint_timers = {}
lint.linters_by_ft = {
  bash = { "shellcheck" },
  javascript = { "eslint_d" },
  json = { "jsonlint" },
  lua = { "luacheck" },
  markdown = { "markdownlint" },
  python = { "ruff" },
  sh = { "shellcheck" },
  typescript = { "eslint_d" },
  zsh = { "shellcheck" },
}

-- Run linters on keystroke (real-time feedback) and on save
local group = vim.api.nvim_create_augroup("Linting", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  group = group,
  callback = function(args)
    if not has_linter(args.buf) then
      return
    end

    if lint_timers[args.buf] then
      return
    end

    local timer = uv.new_timer()
    timer:start(
      0,
      1000,
      vim.schedule_wrap(function()
        if not vim.api.nvim_buf_is_valid(args.buf) or vim.api.nvim_get_current_buf() ~= args.buf then
          stop_timer(timer, args.buf, lint_timers)
          return
        end
        run_lint(args.buf)
      end)
    )

    lint_timers[args.buf] = timer
  end,
})

vim.api.nvim_create_autocmd({ "BufLeave", "BufUnload", "BufWipeout" }, {
  group = group,
  callback = function(args)
    stop_timer(lint_timers[args.buf], args.buf, lint_timers)
  end,
})

vim.api.nvim_create_autocmd({ "BufWritePost", "TextChanged", "TextChangedI", "InsertLeave" }, {
  group = group,
  callback = function(args)
    run_lint(args.buf)
  end,
})

-- Manual
vim.keymap.set("n", "<leader>cl", function()
  require("lint").try_lint()
end, { desc = "Run lint" })
