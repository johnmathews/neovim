-- lua/plugins/lsp.lua
local ok_lsp, lspconfig = pcall(require, "lspconfig")
if not ok_lsp then
  return
end

local util = require("lspconfig.util")

local navic_ok, navic = pcall(require, "nvim-navic")

-- Faster Lua module loading (Nvim ≥ 0.9)
pcall(vim.loader.enable)

-- Diagnostic style (you can toggle virtual_text at runtime elsewhere)
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = true,
  severity_sort = true,
  float = { border = "rounded" },
})

-- Rounded borders for all LSP floats
local _open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or "rounded"
  return _open_floating_preview(contents, syntax, opts, ...)
end

-- Capabilities (nvim-cmp)
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_cap = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  capabilities = cmp_cap.default_capabilities(capabilities)
end

-- on_attach with inlay-hint toggle and improved go-to keybindings
local on_attach = function(client, bufnr)
  local map = function(mode, lhs, rhs, opts)
    opts = opts or { buffer = bufnr, silent = true }
    opts.buffer = bufnr
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  -- LSP keybindings are now set globally in mappings.lua to avoid load-order issues
  -- They are set as global keymaps instead of buffer-local to ensure they persist
  -- and don't get shadowed by other plugins during LSP attachment

  if navic_ok and client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end

  if vim.lsp.inlay_hint then
    map("n", "<leader>li", function()
      local enabled = vim.lsp.inlay_hint.is_enabled and vim.lsp.inlay_hint.is_enabled(bufnr)
      if enabled == nil then
        enabled = vim.lsp.inlay_hint.is_enabled and vim.lsp.inlay_hint.is_enabled() or false
      end
      if vim.lsp.inlay_hint.enable then
        vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
      else
        vim.lsp.inlay_hint(bufnr, not enabled) -- very old API fallback
      end
    end)
  end
end

-- mason-lspconfig v2
local ok_mlc, mason_lspconfig = pcall(require, "mason-lspconfig")
if not ok_mlc then
  return
end

mason_lspconfig.setup({
  ensure_installed = {
    "lua_ls",
    "basedpyright",
    "ts_ls",
    "bashls",
    "yamlls",
    "jsonls",
    "dockerls",
  },

  handlers = {
    -- default handler for anything not overridden below
    function(server)
      lspconfig[server].setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })
    end,

    -- Lua
    ["lua_ls"] = function()
      lspconfig.lua_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = function(fname)
          return util.find_git_ancestor(fname)
            or util.root_pattern(".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml")(fname)
            or vim.fn.stdpath("config")
        end,
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
      })
    end,

    -- BasedPyright
    ["basedpyright"] = function()
      lspconfig.basedpyright.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = function(fname)
          return util.root_pattern("pyproject.toml", "setup.cfg", "requirements.txt", ".git")(fname)
            or util.find_git_ancestor(fname)
        end,
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "basic", -- try "standard"/"strict" later if you like
              autoImportCompletions = true,
            },
          },
          python = {
            analysis = {
              diagnosticMode = "workspace",
            },
          },
        },
      })
    end,

    -- YAML (disable formatting so conform.nvim owns it)
    ["yamlls"] = function()
      lspconfig.yamlls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          yaml = {
            validate = true,
            format = { enable = false },
            keyOrdering = false,
          },
        },
      })
    end,

    -- TypeScript/JavaScript
    ["ts_ls"] = function()
      lspconfig.ts_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
        single_file_support = true,
      })
    end,

    -- Bash (suppress diagnostics; let nvim-lint/shellcheck handle them)
    ["bashls"] = function()
      local has_shellcheck = (vim.fn.executable("shellcheck") == 1)

      require("lspconfig").bashls.setup({
        on_attach = on_attach, -- DO NOT override publishDiagnostics here
        capabilities = capabilities,
        settings = {
          bashIde = {
            globPattern = "*@(.sh|.inc|.bash|.command|.zsh)",
            shellcheckPath = has_shellcheck and "shellcheck" or "", -- enable if present
            shellcheckArguments = { "-x" }, -- follow sourced files (optional)
          },
        },
      })

      if not has_shellcheck then
        vim.schedule(function()
          vim.notify("[bashls] shellcheck not found on PATH; diagnostics will be limited", vim.log.levels.WARN)
        end)
      end
    end,
  },
})
