-- FZF: Fuzzy finder configuration (deprecated in favor of Telescope)
-- i think this isnt used anywhere
vim.cmd([[
  set rtp+=/usr/local/opt/fzf

  let g:fzf_layout = { 'up': '~90%', 'window': { 'width': 0.8, 'height': 0.8, 'yoffset':0.5, 'xoffset': 0.5 } }
  let $FZF_DEFAULT_OPTS = '--layout=reverse --info=inline'

  " Customise the Files command to use rg which respects .gitignore files
  command! -bang -nargs=? -complete=dir Files
      \ call fzf#run(fzf#wrap('files', fzf#vim#with_preview({ 'dir': <q-args>, 'sink': 'e', 'source': 'rg --files --hidden' }), <bang>0))

  " Add an AllFiles variation that ignores .gitignore files
  command! -bang -nargs=? -complete=dir AllFiles
      \ call fzf#run(fzf#wrap('allfiles', fzf#vim#with_preview({
      \ 'dir': <q-args>, 'sink': 'e', 'source': 'rg --files --hidden --no-ignore' }), <bang>0))

  " nnoremap <silent> <Leader>r :Buffers<CR>
  " nnoremap <silent> <Leader>f :Rg<CR>
  " nnoremap <silent> <Leader>e :Files<CR>
  " nnoremap <leader>E :AllFiles<cr>

  let g:fzf_buffers_jump = 1

  let g:fzf_action = {
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-x': 'split',
    \ 'ctrl-v': 'vsplit',
  \ }
]])
