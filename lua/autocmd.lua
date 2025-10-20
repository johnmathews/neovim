-- sets formatoptions to jqlt
-- if syntax isnt set, detect the filetype
-- vim.api.nvim_exec([[
--   augroup foo
--     au!
--     autocmd BufEnter * set formatoptions=jqlt
--     autocmd BufEnter * if &syntax == '' | :filetype detect | endif
--   augroup END
-- ]], false)

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

vim.cmd([[
  augroup RedrawOnFocusGained
    autocmd!
    autocmd FocusGained * :redraw!
  augroup end
]])

-- bigquery files should be sql filetype .bq → sql
vim.cmd([[
  autocmd BufEnter,BufNew *.bq setl filetype=sql
]])

-- exclude quickfix window from buffer list
-- https://stackoverflow.com/questions/28613190/exclude-quickfix-buffer-from-bnext-bprevious
-- vim.cmd([[
--   augroup qf
--       autocmd!
--       autocmd FileType qf set nobuflisted
--   augroup END
-- ]])

vim.cmd([[
  autocmd BufEnter,BufNew *.bq setl filetype=sql
]])

-- tmux
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
