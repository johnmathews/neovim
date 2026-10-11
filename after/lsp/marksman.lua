-- Markdown: overrides merged over nvim-lspconfig's lsp/marksman.lua
return {
  -- nvim-lspconfig also lists markdown.mdx, which Neovim never sets; :checkhealth vim.lsp warns about it
  filetypes = { "markdown" },
}
