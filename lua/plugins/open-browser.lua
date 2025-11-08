-- Open Browser: Open URLs and search terms in default browser
vim.cmd([[
  " gx is default mapped to netrw opening urls in browsers
  " leader-x is mapped to open a file in the systems default app
  let g:netrw_nogx = 1 " disable netrw's gx mapping because it doesn't work on MacOS.
  nmap gx <Plug>(openbrowser-smart-search)
  vmap gx <Plug>(openbrowser-smart-search)
]])
