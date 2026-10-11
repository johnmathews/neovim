-- YAML (disable formatting so conform.nvim owns it)
return {
  -- nvim-lspconfig also lists yaml.docker-compose, yaml.gitlab and yaml.helm-values, which Neovim
  -- never sets; :checkhealth vim.lsp warns about each
  filetypes = { "yaml" },
  settings = {
    yaml = {
      validate = true,
      format = { enable = false },
      keyOrdering = false,
    },
  },
}
