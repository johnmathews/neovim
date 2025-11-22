local M = {}

function M.asyncGitCommitAndPush(commitMessage)
  if commitMessage == nil or commitMessage == "" then
    commitMessage = "quick commit" -- Default commit message
  end

  vim.loop.spawn("git", {
    args = { "rev-parse", "--inside-work-tree" },
    cwd = vim.loop.cwd(),
  }, function(code)
    if code ~= 0 then
      vim.schedule(function()
        vim.api.nvim_out_write("Can't commit, not in a git repository\n")
      end)
      return
    end

    vim.schedule(function()
      vim.fn.system("git add .")
      vim.fn.system('git commit -m "' .. commitMessage .. '"')
      vim.fn.system("git push")
      vim.api.nvim_out_write('git commit --all --message "' .. commitMessage .. '"\n')
    end)
  end)
end

-- use <LocalLeade>t to see LSP, Linter and Formatting tools
M.active_tools = function()
  local bufnr = vim.api.nvim_get_current_buf()

  -- LSP clients
  local lsp = {}
  for _, c in pairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    table.insert(lsp, c.name)
  end

  -- Conform (formatters)
  local fmt = {}
  pcall(function()
    local conform = require("conform")
    for _, f in ipairs(conform.list_formatters(bufnr)) do
      table.insert(fmt, f.name or f)
    end
  end)

  -- nvim-lint (linters)
  local linters = {}
  pcall(function()
    local lint = require("lint")
    local ft = vim.bo[bufnr].filetype
    local by_ft = lint.linters_by_ft or {}
    for _, l in ipairs(by_ft[ft] or {}) do
      table.insert(linters, l)
    end
  end)

  vim.notify(
    ("%s\n%s\n%s"):format(
      "LSP: " .. (#lsp > 0 and table.concat(lsp, ", ") or "—"),
      "Formatters: " .. (#fmt > 0 and table.concat(fmt, ", ") or "—"),
      "Linters: " .. (#linters > 0 and table.concat(linters, ", ") or "—")
    ),
    vim.log.levels.INFO,
    { title = "Active_Tools" }
  )
end

-- toggle the quickfix window
vim.cmd([[
  function! ToggleQuickFix()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
      copen 15
      setlocal norelativenumber
    else
      cclose
    endif
  endfunction
]])

-- blog post
vim.cmd([[
function! s:NewPost(fn)
  execute "e " . "~/projects/blog/data/blog/" . a:fn . ".md"
endfunction
command! -nargs=1 Mp call s:NewPost(<q-args>)
]])

local diagnostic_state = 2
function M.cycle_diagnostics()
  if diagnostic_state == 1 then
    -- Mode 1: Virtual Text (at end of line)
    vim.notify("Diagnostics: Virtual Text", vim.log.levels.INFO)
    vim.diagnostic.config({
      signs = true,
      underline = true,
      virtual_text = true,
      virtual_lines = false,
    })
    diagnostic_state = 2
  elseif diagnostic_state == 2 then
    -- Mode 2: Signs and Underlines (no virtual text)
    vim.notify("Diagnostics: Signs and Underlines", vim.log.levels.INFO)
    vim.diagnostic.config({
      signs = true,
      underline = true,
      virtual_text = false,
      virtual_lines = false,
    })
    diagnostic_state = 3
  elseif diagnostic_state == 3 then
    vim.notify("Diagnostics: Disabled", vim.log.levels.INFO)
    vim.diagnostic.config({
      signs = false,
      underline = false,
      virtual_text = false,
      virtual_lines = false,
    })
    diagnostic_state = 1
  end
end

-- toggle focus between nvim-tree and buffer window
-- if cursor is in nvim-tree, jump back to the buffer
-- if cursor is in buffer, jump to current file in nvim-tree
M.toggle_tree_focus = function()
  -- Safely require nvim-tree API
  local ok, nvim_tree_api = pcall(require, "nvim-tree.api")
  if not ok then
    vim.notify("nvim-tree not available", vim.log.levels.WARN)
    return nil
  end

  -- Check if current window is nvim-tree
  local current_buf = vim.api.nvim_get_current_buf()
  local current_filetype = vim.api.nvim_buf_get_option(current_buf, "filetype")

  if current_filetype == "NvimTree" then
    -- We're in nvim-tree, jump back to the previous buffer window
    -- Find the first non-tree window and focus it
    local windows = vim.api.nvim_list_wins()
    for _, win in ipairs(windows) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.api.nvim_buf_get_option(buf, "filetype")
      if ft ~= "NvimTree" then
        vim.api.nvim_set_current_win(win)
        return "Jumped to buffer"
      end
    end
  else
    -- We're in a buffer, jump to nvim-tree and focus the current file
    local filepath = vim.fn.expand("%:p")

    -- Handle case where no file is open
    if filepath == "" or filepath == "." then
      vim.notify("No file open in current buffer", vim.log.levels.WARN)
      return nil
    end

    -- Find the file in the tree
    -- This opens the tree if closed and navigates to the file
    nvim_tree_api.tree.find_file({ open = true, focus = true, update_root = false })
    return filepath
  end

  return nil
end

return M
