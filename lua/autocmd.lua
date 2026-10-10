vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "yaml", "lua" },
  callback = function()
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
    vim.opt_local.foldlevel = 99
  end,
})

-- highlight on yank
vim.cmd([[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.hl.on_yank()
  augroup end
]])

-- bigquery files should be sql filetype .bq → sql
vim.cmd([[
  autocmd BufEnter,BufNew *.bq setl filetype=sql
]])

-- files named tmux*.local use the tmux filetype
vim.cmd([[
  autocmd BufNewFile,BufRead {.,}tmux*.local nested setf tmux
]])

vim.cmd([[
  autocmd Filetype tex set updatetime=1000
]])

-- quiickfix window → force it to be full width
vim.cmd([[
  autocmd FileType qf wincmd J
]])

-- set linenumber in telescope previews
vim.cmd("autocmd User TelescopePreviewerLoaded setlocal number")

-- project root: entering a file buffer moves cwd to its nearest root marker
-- (this replaced project.nvim; `:AutoSession search` replaced its picker)
local root_markers = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "poetry.lock" }
-- roots that must not become cwd
local root_excluded = { vim.fs.normalize("~/projects/lettergun/web-app/lettergun") }
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("ProjectRoot", { clear = true }),
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" or vim.api.nvim_buf_get_name(args.buf) == "" then
      return
    end
    local root = vim.fs.root(args.buf, root_markers)
    if not root then
      return
    end
    for _, dir in ipairs(root_excluded) do
      if root == dir or vim.startswith(root, dir .. "/") then
        return
      end
    end
    if vim.fs.normalize(vim.fn.getcwd()) ~= root then
      vim.fn.chdir(root)
      vim.notify("cwd: " .. root, vim.log.levels.INFO)
    end
  end,
})
