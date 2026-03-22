# Fix Markdown Dollar Sign Highlighting

## Problem

Opening a markdown file containing dollar amounts (e.g. `$1.20`, `$0.99`) caused most text to turn blue/purple. The `$` characters were being interpreted as LaTeX math delimiters, so everything between two `$` signs was highlighted as inline math.

## Root Cause

`vim-markdown` had `g:vim_markdown_math = 1` enabled in `lua/plugins/vim-markdown.lua`, which activates LaTeX math syntax regions using `$` as delimiters.

## Fix

Set `g:vim_markdown_math = 0` to disable LaTeX math support. Dollar signs are now treated as plain text.

## Trade-off

Inline LaTeX math (`$x^2$`) will no longer be syntax-highlighted in markdown files. If LaTeX math support is needed in the future, re-enable the setting and escape literal dollar signs with `\$`.
