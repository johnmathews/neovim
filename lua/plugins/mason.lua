-- mason.vim names for language servers are not the same as the names used by lspconfig and mason-lspconfig.
-- e.g. lspconfig: sumneko_lua, mason.vim: lua-language-server

-- multiple spawn issues - caused by Packer lazyloading things, but not all things.
-- be careful about using `event = "VimEnter"` in plugins.lua, and other lazyloading techniques.
-- https://github.com/LunarVim/LunarVim/issues/2012

local mason_ok, mason = pcall(require, "mason")
if not mason_ok then
  return
end

mason.setup()

local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_ok then
  return
end

mason_lspconfig.setup {
  ensure_installed = { "tailwindcss", "lua_ls", "jsonls", "pyright", "yamlls" },
  automatic_installation = true,
}

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  return
end

local util = require 'lspconfig.util'

function KeymapBufferOptions(args)
  local description = args.description or "no description"
  local bufnr = args.bufnr
  return {
    noremap = true,
    silent = true,
    desc = description,
    buffer = bufnr,
  }
end

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- run ascii conversion function before async lsp.buf.format
  -- vim.keymap.set('n', '<leader>f', function() Convert_smart_and_fancy_ascii_chars_to_normal_chars() vim.lsp.buf.format { async = true } end, KeymapBufferOptions({ description = "LSP format buffer", bufnr = bufnr }))

  vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end,
    KeymapBufferOptions({ description = "LSP format buffer", bufnr = bufnr }))

  -- Enable completion triggered by <c-x><c-o>
  -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, KeymapOptions("Diagnostic - Open Location List")) -- view a list of errors and warnings

  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, KeymapOptions("LSP Type Definition"))
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration,
    KeymapBufferOptions({ description = "LSP goto Declaration", bufnr = bufnr }))
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition,
    KeymapBufferOptions({ description = "LSP goto Definition", bufnr = bufnr }))
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation,
    KeymapBufferOptions({ description = "LSP goto Implementation", bufnr = bufnr }))
  vim.keymap.set('n', 'gr', vim.lsp.buf.references,
    KeymapBufferOptions({ description = "LSP goto references", bufnr = bufnr }))
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help,
    KeymapBufferOptions({ description = "LSP signature help", bufnr = bufnr }))

  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder,
    KeymapBufferOptions({ description = "LSP add workspace folder", bufnr = bufnr }))
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder,
    KeymapBufferOptions({ description = "LSP remove workspace folder", bufnr = bufnr }))
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, KeymapBufferOptions({ description = "LSP list workspace folders", bufnr = bufnr }))

  -- UNUSED AND PROBABLY HANDLED BETTER BY LSPSAGA.
  --   vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts) -- LSPSaga has a better float
  --   vim.keymap.set('n', '[e', vim.diagnostic.goto_prev, opts)
  --   vim.keymap.set('n', ']e', vim.diagnostic.goto_next, opts)

  --   See `:help vim.lsp.*` for documentation on any of the below functions
  --   vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  --   vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  --   vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
end



local lsp_flags = {
  debounce_text_changes = 500,
}

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local pyright_settings = {
  python = {
    analysis = {
      typeCheckingMode = "basic", -- Options: "off", "basic", "strict"
      autoSearchPaths = true,
      autoImportCompletions = true,
      diagnosticMode = "workspace",
      useLibraryCodeForTypes = true,
    },
  },
}

mason_lspconfig.setup_handlers({
  -- AVAILABLE SERVERS: https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers

  -- The first entry (without a key) will be the default handler and will be called for
  -- each installed server that doesn't have a dedicated handler.
  function(server_name) -- default handler (optional)
    require("lspconfig")[server_name].setup {
      on_attach = on_attach,
      flags = lsp_flags,
      capabilities = capabilities,
    }
  end,
  -- settings: https://github.com/sumneko/lua-language-server/wiki/Settings
  -- TO SEE ACTIVE CONFIG:
  -- :lua print(vim.inspect(vim.lsp.get_active_clients()))
  ["pyright"] = function()
    lspconfig.pyright.setup {
      on_attach = on_attach,
      flags = lsp_flags,
      capabilities = capabilities,
      settings = pyright_settings,
    }
  end,
  ["sqlls"] = function()
    require("lspconfig").sqlls.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      command = { "sql-language-server", "up", "--method", "stdio" },
      filetypes = { 'sql', 'mysql' },
      root_dir = util.root_pattern '.sqllsrc.json',
      settings = {},
    }
  end,
  -- ["sqls"] = function()
  --   require("lspconfig").sqls.setup {
  --     on_attach = on_attach,
  --     capabilities = capabilities,

  --     settings = {
  --       sqls = {
  --         connections = {
  --           {
  --             driver = "postgresql",
  --             dataSourceName = "john@tcp(localhost:5432)/postgres",
  --           },
  --         },
  --       },
  --     },
  --   }
  -- end,
  ["lua_ls"] = function()
    -- documentation about annotations and ignoring a row: https://luals.github.io/wiki/annotations/#diagnostic
    -- just search this repo for ---@diagnostic
    lspconfig.lua_ls.setup {
      on_attach = on_attach,
      flags = lsp_flags,
      capabilities = capabilities,
      settings = {
        Lua = {
          telemetry = { enable = false },
          runtime = {
            version = 'LuaJIT',
            path = vim.fn.expand("$VIMRUNTIME/lua"),
          },
          workspace = {
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
          format = {
            enable = true,
            default_config = {
              indent_type = "Spaces",
              indent_width = 2,
              line_length = 180, -- doesnt work
            },
          },
          completion = {
            callSnippet = "Both",
          },
          diagnostics = {
            globals = {
              "P",
              "pcall",
              "string",
              "vim",
              "require",
              "KeymapOptions",
              "KeymapBufferOptions",
              -- "Convert_smart_and_fancy_ascii_chars_to_normal_chars"
            },
            disable = {
              "trailing-space",
            }
          },
        }
      }
    }
  end,
})
