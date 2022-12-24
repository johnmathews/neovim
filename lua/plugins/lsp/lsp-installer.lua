local lsp_installer_status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not lsp_installer_status_ok then
  return
end

lsp_installer.setup {}

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  return
end

for _, server in ipairs { "clangd", "eslint", "ltex", "stylua" } do
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

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
-- lsp_installer.on_server_ready(function(server)
--   local opts = {
--     on_attach = require("plugins.lsp.handlers").on_attach,
--     capabilities = require("plugins.lsp.handlers").capabilities,
--   }

--   if server.name == "jsonls" then
--     local jsonls_opts = require("plugins.lsp.settings.jsonls")
--     opts = vim.tbl_deep_extend("force", jsonls_opts, opts)
--   end

--   if server.name == "sumneko_lua" then
--     local sumneko_opts = require("plugins.lsp.settings.sumneko_lua")
--     opts = vim.tbl_deep_extend("force", sumneko_opts, opts)
--   end

--   if server.name == "pyright" then
--     local pyright_opts = require("plugins.lsp.settings.pyright")
--     opts = vim.tbl_deep_extend("force", pyright_opts, opts)
--   end

--   -- This setup() function is exactly the same as lspconfig's setup function.
--   -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
--   server:setup(opts)
-- end)
