-- Vim MatchTag: Highlight matching HTML/XML tags
vim.cmd([[
  highlight matchTag guibg=green

  let g:vim_matchtag_enable_by_default = 0
  let g:vim_matchtag_files = '*.html,*.xml,*.js,*.jsx,*.ts,*.tsx,*.vue,*.svelte,*.jsp'
]])
