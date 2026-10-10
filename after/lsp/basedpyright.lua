-- BasedPyright: overrides merged over nvim-lspconfig's lsp/basedpyright.lua
return {
  -- Keep basedpyright on push diagnostics, as on 0.11. Neovim 0.12 accepts dynamic
  -- registration of pull diagnostics; basedpyright then registers twice and can answer a
  -- pull with an empty report, so a buffer opens with none of its diagnostics.
  capabilities = {
    textDocument = { diagnostic = { dynamicRegistration = false } },
  },
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "basic", -- try "standard"/"strict" later if you like
        autoImportCompletions = true,
      },
    },
  },
}
