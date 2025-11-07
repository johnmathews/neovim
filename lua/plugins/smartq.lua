local map = vim.api.nvim_set_keymap

-- Exit/Delete buffer while respecting window splits and tabs, and other types of buffer.

map("n", "qq", ":bprevious<CR> | :bdelete #<CR>", KeymapOptions("Quit buffer (vanilla)"))
map("n", "wq", "<Plug>(smartq_this_save)", KeymapOptions("Quit buffer (smartQ)"))
map("n", "QE", "<Plug>(smartq_wipe_empty)", KeymapOptions("Quit buffer (smartQ)"))

-- CONFIGURATION
-- =============

-- Excluded buffers to disable SmartQ and to preserve windows when closing splits
-- on excluded buffers. Non-modifiable buffers are preserved by default.
vim.cmd([[
  let g:smartq_exclude_filetypes = [ 'fugitive', 'NvimTree' ]
  let g:smartq_exclude_buftypes= [ 'NvimTree' ]
]])

-- Quit buffers using :q command. Non-modifiable and readonly file uses :q
vim.cmd([[
  let g:smartq_q_filetypes = [ 'diff', 'git', 'gina-status', 'gina-commit', 'snippets', 'floaterm' ]
  let g:smartq_q_buftypes = [ 'quickfix', 'nofile' ]
]])

-- Wipe buffers using :bw command. Wiped buffers are removed from jumplist
-- Default :bd
vim.cmd([[ let g:smartq_bw_filetypes = [ '' ]
  let g:smartq_bw_buftypes = [ '' ]
]])

-- Automatically wipe empty (with no changes) buffer(s)
vim.cmd([[ let g:smartq_auto_wipe_emtpy = 0 ]])

-- Best attemp to prevent exiting editor when left with an empty modifiable buffer
-- Automatically close splits when left with 1 modifiable buffer
vim.cmd([[
  let g:smartq_no_exit = 0
  let g:smartq_auto_close_splits = 0
]])

-- Plugin Integration
vim.cmd([[
  let g:smartq_goyo_integration = 1
  let g:smartq_zenmode_integration = 1
]])
