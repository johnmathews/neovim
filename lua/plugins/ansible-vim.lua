-- Ansible Vim: Syntax highlighting for Ansible YAML files
vim.cmd([[
  "let g:ansible_yamlKeyName = 'yamlKey'
  let g:ansible_attribute_highlight = "ab"
  let g:ansible_name_highlight = 'ab'
  let g:ansible_extra_keywords_highlight = 1
  " options are 'Commment', 'Constant' or 'Identifier'
  let g:ansible_extra_keywords_highlight_group = 'Statement'
  let g:ansible_normal_keywords_highlight = 'Constant'
  let g:ansible_loop_keywords_highlight = 'green'
]])
