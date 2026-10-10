-- lua/plugins/nvim-lint.lua

local uv = vim.uv
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

-- Configure shellcheck for zsh files to use bash mode
-- (shellcheck doesn't natively support zsh, so we treat it as bash)
-- A copy, so the shared shellcheck linter keeps its own args. nvim-lint parses json1.
lint.linters.shellcheck_zsh = vim.tbl_extend("force", {}, lint.linters.shellcheck, {
  args = {
    "--format=json1",
    "--shell=bash", -- Force bash mode for zsh files
    "-",
  },
})

-- Configure markdownlint to use project-specific config with global fallback
-- Suppresses MD013 (line length) when markdown print mode is active
-- nvim-lint wants `args` as a list, so the whole linter is a function that builds a copy
local markdownlint = lint.linters.markdownlint
lint.linters.markdownlint = function()
  local file_dir = vim.fn.expand("%:p:h")
  local local_config = vim.fn.findfile(".markdownlint.json", file_dir .. ";")

  local args = { "--stdin" }
  if local_config ~= "" and vim.fn.filereadable(local_config) == 1 then
    vim.list_extend(args, { "--config", local_config })
  else
    vim.list_extend(args, { "--config", vim.fn.stdpath("config") .. "/.markdownlint.json" })
  end

  if vim.b.markdown_print_mode then
    vim.list_extend(args, { "--disable", "MD013" })
  end

  return vim.tbl_extend("force", {}, markdownlint, { args = args })
end

-- Python (ruff) and sh/bash (shellcheck) are linted by their LSP servers, not here
local lint_timers = {}
lint.linters_by_ft = {
  javascript = { "eslint_d" },
  json = { "jsonlint" },
  lua = { "luacheck" },
  markdown = { "markdownlint" },
  typescript = { "eslint_d" },
  zsh = { "shellcheck_zsh" },
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
