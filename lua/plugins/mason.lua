local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  return
end

local mason_ok, mason = pcall(require, "mason")
if not mason_ok then
  return
end

local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_ok then
  return
end

mason.setup()


mason_lspconfig.setup {
    ensure_installed = { "sumneko_lua", "rust_analyzer" },
    automatic_installation = true,
}

mason_lspconfig.setup_handlers({
   -- The first entry (without a key) will be the default handler
   -- and will be called for each installed server that doesn't have
   -- a dedicated handler.
   function (server_name) -- default handler (optional)
       require("lspconfig")[server_name].setup {}
   end,
   -- Next, you can provide targeted overrides for specific servers.
   ["sumneko_lua"] = function ()
       lspconfig.sumneko_lua.setup {
           settings = {
               Lua = {
                   diagnostics = {
                       globals = { "vim" }
                   }
               }
           }
       }
   end,
})

-- this has got to be below the mason_lspconfig.setup.. calls
local lsp_installer_status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not lsp_installer_status_ok then
  return
end
lsp_installer.setup {}

for _, server in ipairs { "clangd", "eslint", "ltex", "stylua", "lua-language-server" } do
  lspconfig[server].setup { on_attach = on_attach }
end
  
lspconfig.luacheck.setup {
  on_attach = on_attach,
}

lspconfig.sumneko_lua.setup {
  on_attach = on_attach,
  settings = {
    Lua = {
      format = {
        enable = false
      },
      diagnostics = {
        globals = {
          "P",
          "vim",
          "require",
        },
        disable = {
          "trailing-space",
        }
      },
      workspace = {
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.stdpath("config") .. "/lua"] = true,
        },
      },
    }
  }
}

lspconfig.pyright.setup {
  on_attach = on_attach,
}
lspconfig.jsonls.setup {
  on_attach = on_attach,
}
