-- BasedPyright: overrides merged over nvim-lspconfig's lsp/basedpyright.lua
return {
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "basic", -- try "standard"/"strict" later if you like
        autoImportCompletions = true,
      },
    },
  },
}
