-- Comment: context-aware commentstring for Neovim's native gc commenting
-- (lua/plugins.lua points vim.filetype.get_option at this plugin)

require("ts_context_commentstring").setup({
  enable_autocmd = false,
  languages = {
    -- You can specify the commentstring for various types of text objects.
    -- For example, for JavaScript inside TSX:
    typescript = "// %s",
    tsx = {
      __default = "// %s",
      jsx_element = "{/* %s */}",
      jsx_fragment = "{/* %s */}",
      jsx_attribute = "{/* %s */}",
      comment = "// %s",
    },
    html = "<!-- %s -->",
  },
})
