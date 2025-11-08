-- Vim Test: Test runner with AsyncRun integration
vim.cmd([[
  let test#strategy = "asyncrun_background"
  let test#python#runner = 'pytest'
  let test#python#pytest#options = '-x'
  let test#vim#term_position = "belowright"

  nnoremap <silent> t<LEADER>n :TestNearest<CR>
  nnoremap <silent> t<LEADER>f :TestFile<CR>
  nnoremap <silent> t<LEADER>s :TestSuite<CR>
  nnoremap <silent> t<LEADER>l :TestLast<CR>
  nnoremap <silent> t<LEADER>g :TestVisit<CR>
]])
