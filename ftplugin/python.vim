setlocal list lcs=tab:\|\ 
setlocal tabstop=4
setlocal softtabstop=4
setlocal expandtab
setlocal shiftwidth=4
setlocal smarttab

setlocal textwidth=125
setlocal autoindent
setlocal nowrap

if exists('+colorcolumn')
    setlocal colorcolumn=125
else
    au! BufEnter <buffer> match ColorColumn /\%121v.*/
endif

" ========== print variable and its value ===============
vnoremap <buffer> <localleader>p y<esc>oprint(f"--- {<esc>gpa = }")<ESC>
vnoremap <buffer> <localleader>o y<esc>oprint(f'''--- {<esc>gpa =<CR><BS><BS><BS>}''')<ESC>
nnoremap <buffer> <Localleader>p <esc>oprint(f"--- {<esc>gpa = }")<ESC>
nnoremap <buffer> <Localleader>o <esc>oprint(f'''--- {<esc>gpa =<CR><BS><BS><BS>}''')<ESC>

" ========== log variable and its value ================
vnoremap <buffer> <localleader>l y<esc>ologger.info(f"--- {<esc>gpa = }")<ESC>
nnoremap <buffer> <Localleader>l <esc>ologger.info(f"--- {<esc>gpa = }")<ESC>
