setlocal autoindent " Copy indent from current line when starting a new line (typing <CR> in Insert mode or when using the "o" or "O" command)
" setlocal cindent " Get the amount of indent for line {lnum} according the C indenting rules, as with 'cindent'. The indent is counted in spaces, the value of 'tabstop' is relevant.
setlocal tabstop=2 " number of spaces that a tab is equal to
setlocal softtabstop=2 " number of spaces that a tab is equal to while performing editing operations "
setlocal shiftwidth=2
setlocal expandtab " In Insert mode: Use the appropriate number of spaces to insert a <Tab>.  Spaces are used in indents with the '>' and '<' commands and when 'autoindent' is on.
setlocal smarttab " When on, a <Tab> in front of a line inserts blanks according to 'shiftwidth'.

" " word wrap without line breaks
" " https://vim.fandom.com/wiki/Word_wrap_without_line_breaks
" setlocal nolist  " list disables linebreak
" setlocal wrap " wrap visually (don't change text in the buffer
" setlocal linebreak " only wrap at a char in the `breakat` list (not mid-word)
" setlocal textwidth=200 " don't insert linebreaks in newly entered text


" " setlocal omnifunc=htmlcomplete#CompleteTags

" " jump to matching tag when cursor is within angle brackets
" runtime macros/matchit.vim

" " ===== jsBeautify =====
" nnoremap <buffer>  <c-f> :call HtmlBeautify()<cr>

" let g:indentLine_char_list = ['|', '¦', '┆', '┊', '⦙']
