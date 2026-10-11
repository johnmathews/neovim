-- Lua: overrides merged over nvim-lspconfig's lsp/lua_ls.lua
return {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = { checkThirdParty = false },
      diagnostics = {
        unusedLocalExclude = { "^_" }, -- allow _client, _foo
        globals = { "vim", "KeymapOptions", "Functions", "Functions_ok" },
      },
      hint = { enable = true },
      telemetry = { enable = false },
    },
  },
}
