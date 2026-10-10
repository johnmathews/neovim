-- lua/plugins/lsp.lua
-- Servers start through Neovim's native vim.lsp.config / vim.lsp.enable. nvim-lspconfig
-- only supplies the default lsp/<server>.lua configs. Per-server overrides live in
-- after/lsp/<server>.lua, merged in this order: vim.lsp.config("*"), then lspconfig's
-- lsp/<server>.lua, then after/lsp/<server>.lua. See docs/LSP.md.

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

-- Capabilities (nvim-cmp) for every server
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  vim.lsp.config("*", { capabilities = cmp_lsp.default_capabilities() })
end

-- Replaces a per-server on_attach: an on_attach in a server config would replace the one
-- nvim-lspconfig ships for that server (basedpyright defines one).
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end
    local bufnr = args.buf

    -- LSP keybindings are now set globally in mappings.lua to avoid load-order issues
    -- They are set as global keymaps instead of buffer-local to ensure they persist
    -- and don't get shadowed by other plugins during LSP attachment

    if client:supports_method("textDocument/documentSymbol") then
      local navic_ok, navic = pcall(require, "nvim-navic")
      if navic_ok then
        navic.attach(client, bufnr)
      end
    end

    if client:supports_method("textDocument/inlayHint") then
      vim.keymap.set("n", "<leader>li", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
      end, { buffer = bufnr, silent = true, desc = "LSP: toggle inlay hints" })
    end
  end,
})

-- The servers that start, on every machine. Mason installs them; nothing else is enabled.
-- SQL has no LSP on purpose (dadbod completes, sqlfluff formats). stylua, eslint and
-- biome run as tools through conform and nvim-lint instead of as servers.
local servers = {
  "lua_ls",
  "basedpyright",
  "ruff",
  "ts_ls",
  "bashls",
  "yamlls",
  "jsonls",
  "dockerls",
  "taplo",
  "marksman",
}

-- mason-lspconfig v2 only installs servers here; automatic_enable would start every
-- server Mason happens to hold.
local ok_mlc, mason_lspconfig = pcall(require, "mason-lspconfig")
if ok_mlc then
  mason_lspconfig.setup({ ensure_installed = servers, automatic_enable = false })
else
  vim.notify("mason-lspconfig is not installed: LSP servers will not be auto-installed", vim.log.levels.WARN)
end

vim.lsp.enable(servers)
