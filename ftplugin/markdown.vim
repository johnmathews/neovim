" Make Row Title Case <leader>mt
nnoremap <buffer> <leader>mt :s/\<./\u&/g<bar>:nohlsearch<bar><esc>
vnoremap <buffer> <leader>mt :s/\<./\u&/g<bar>:nohlsearch<bar><esc>

" make text bold <leader>mb
nnoremap <buffer> <leader>mb ebi**<ESC>ea**<space><ESC>
vmap <buffer> <leader>mb c**<ESC>gcP

" make text italic <leader>mi
nnoremap <buffer> <leader>mi ebi*<ESC>ea*<ESC>
vmap <buffer> <leader>mi c__<ESC>gcP

" make code block <leader>mc
nnoremap <buffer> <leader>mc ebi`<ESC>ea`<ESC>
vmap <buffer> <leader>mc c``<ESC>gcP

" == local settings
setlocal smarttab
setlocal softtabstop=2
setlocal noautoindent " if previous line is indented, don't make new line also indented

setlocal tabstop=2
setlocal shiftwidth=2 " this is how many spaces a tab is.
setlocal expandtab
setlocal linebreak " Wrap lines at convenient points, avoid wrapping a line in the middle of a word.

setlocal nowrap
setlocal scrolloff=3 " The number of screen lines to keep above and below the cursor

setlocal whichwrap=hl  " let h and l wrap to previous or next line

setlocal textwidth=120 " you need to format (leader-f) to update the line wraps.
setlocal colorcolumn=121
highlight ColorColumn ctermbg=red ctermfg=red guifg=red guibg=darkcyan

" add text width to autoformat options
" setlocal formatoptions+=t

setlocal spell
setlocal spelllang=en_us,en_gb

" toggle visibility of tab chars, EOL chars, CR chars
setlocal nolist

" don't insert 2 spaces after a '.','?' or '!'
setlocal nojoinspaces

" show text normally. no folding
setlocal conceallevel=0
let g:indentLine_conceallevel = 0

" Stop telling me underscores are errors:
syn match markdownError "\w\@<=\w\@="

" Rainbow parenthesis turned off
let g:rainbow_active = 0

" format paragraph
" command! FormatParagraph normal! vipgw`^
" command! FormatParagraph normal! gwip
" nnoremap <leader>fp :FormatParagraph<CR>
" vnoremap <leader>fp gw

" this breaks syntax highlighting, so put it at the end
" Glow preview - disabled because it crashes vim.
lua << EOF
  vim.api.nvim_set_keymap("n", "<Leader>p", ":Glow<CR>", KeymapOptions("Preview markdown"))
EOF
