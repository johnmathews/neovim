-- lua/plugins/lsp.lua
local lspconfig = require("lspconfig")
local mason_lspconfig = require("mason-lspconfig")

-- Recommended: faster Lua module loading since Nvim 0.9+
pcall(vim.loader.enable)

-- Capabilities for nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_cap = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
	capabilities = cmp_cap.default_capabilities(capabilities)
end

-- Basic on_attach
local on_attach = function(client, bufnr)
	local map = function(mode, lhs, rhs)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
	end
	map("n", "gd", vim.lsp.buf.definition)
	map("n", "gr", vim.lsp.buf.references)
	map("n", "K", vim.lsp.buf.hover)
	-- Toggle inlay hints (Nvim 0.10+)
	if vim.lsp.inlay_hint then
		map("n", "<leader>li", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
		end)
	end
end

require("mason").setup({})
mason_lspconfig.setup({
	ensure_installed = {
		"lua_ls",
		"basedpyright", -- or "pyright"
		"ruff_lsp",
		"ts_ls", -- or "vtsls"
		"bashls",
		"yamlls",
		"jsonls",
		"dockerls",
	},
	handlers = {
		function(server)
			lspconfig[server].setup({ on_attach = on_attach, capabilities = capabilities })
		end,
		-- Example: tuned Lua
		["lua_ls"] = function()
			lspconfig.lua_ls.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				settings = { Lua = { diagnostics = { globals = { "vim" } }, workspace = { checkThirdParty = false } } },
			})
		end,
	},
})

-- Ensure non-LSP tools are installed
require("mason-tool-installer").setup({
	ensure_installed = {
		-- formatters
		"stylua",
		"shfmt",
		"prettierd",
		"biome",
		"black",
		"isort",
		"ruff",
		-- linters
		"eslint_d",
		"markdownlint-cli2",
		"shellcheck",
		"mypy",
	},
	auto_update = false,
	run_on_start = true,
})
