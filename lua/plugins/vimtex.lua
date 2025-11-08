-- VimTeX: LaTeX editing with live preview support
vim.cmd([[
  let g:tex_flavor = 'latex'
  let g:livepreview_previewer = 'open -a Preview'
  let g:tex_IgnoredWarnings =
      \'Underfull'."\n".
      \'Overfull'."\n".
      \'specifier changed to'."\n".
      \'You have requested'."\n".
      \'Missing number, treated as zero.'."\n".
      \'There were undefined references'."\n".
      \'Citation %.%# undefined'."\n".
      \'Double space found.'."\n"
  let g:Tex_IgnoreLevel = 8
]])
