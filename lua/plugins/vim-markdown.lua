-- https://github.com/preservim/vim-markdown#fenced-code-block-languages

-- :HeaderDecrease will decrease the level of all headers in the buffer (h2 ->  h1, h3 -> h2 etc)
-- :HeaderIncrease
-- :SetexToAtx
-- :TableFormat
-- :Toc - in the quickfix, there are also options for in a vertical split `tocv`, horizontal split `toch`

-- :InsertToc or :InsertNToc insert a table of contents or numbered table of contents

-- The rules for the cursor position are the same as the gx command.
-- ]]: go to next header. <Plug>Markdown_MoveToNextHeader
-- [[: go to previous header. Contrast with ]h. <Plug>Markdown_MoveToPreviousHeader
-- ][: go to next sibling header if any. <Plug>Markdown_MoveToNextSiblingHeader
-- []: go to previous sibling header if any. <Plug>Markdown_MoveToPreviousSiblingHeader
-- ]h: go to Current header. <Plug>Markdown_MoveToCurHeader
-- ]u: go to parent header (Up). <Plug>Markdown_MoveToParentHeader

-- ge: open the link under the cursor in Vim for editing.
-- Useful for relative markdown links. Falls back to gf with force editing, if not on a markdown link.

vim.cmd([[
  " https://github.com/preservim/vim-markdown#yaml-front-matter
  let g:vim_markdown_frontmatter = 1

  let g:vim_markdown_toc_autofit = 1

  " https://github.com/preservim/vim-markdown#fenced-code-block-languages
  let g:vim_markdown_fenced_languages = ['python=py']

  " dont fold anything
  let g:vim_markdown_folding_disabled = 1

  " dont conceal anything
  let g:vim_markdown_conceal_code_blocks = 0
  let g:vim_markdown_conceal = 0
  let g:tex_conceal = ""


  " https://github.com/preservim/vim-markdown#latex-math
  let g:vim_markdown_math = 1

  " https://github.com/preservim/vim-markdown#adjust-new-list-item-indent
  let g:vim_markdown_new_list_item_indent = 2

  " https://github.com/preservim/vim-markdown#strikethrough
  let g:vim_markdown_strikethrough = 1
]])
