-- lua/plugins/lsp.lua
local lspconfig = require("lspconfig")
local util = require("lspconfig.util")

-- Faster module loading (Nvim ≥ 0.9)
pcall(vim.loader.enable)

-- Global diagnostic style (toggle virtual_text via your plugin or here)
vim.diagnostic.config({
	virtual_text = false, -- you can toggle this at runtime if you want
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = { border = "rounded" },
})

-- Better LSP borders
local _open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or "rounded"
	return _open_floating_preview(contents, syntax, opts, ...)
end

-- Capabilities (nvim-cmp)
local capabilities = vim.lsp.protocol.make_client_capabilities()
do
	local ok_cmp, cmp_cap = pcall(require, "cmp_nvim_lsp")
	if ok_cmp then
		capabilities = cmp_cap.default_capabilities(capabilities)
	end
end

-- on_attach: minimal, with inlay-hint toggle
local on_attach = function(_client, bufnr)
	local map = function(mode, lhs, rhs)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
	end
	map("n", "gd", vim.lsp.buf.definition)
	map("n", "gr", vim.lsp.buf.references)
	map("n", "K", vim.lsp.buf.hover)

	if vim.lsp.inlay_hint then
		map("n", "<leader>li", function()
			local enabled = vim.lsp.inlay_hint.is_enabled and vim.lsp.inlay_hint.is_enabled(bufnr)
			if enabled == nil then
				enabled = vim.lsp.inlay_hint.is_enabled and vim.lsp.inlay_hint.is_enabled() or false
			end
			if vim.lsp.inlay_hint.enable then
				vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
			else
				vim.lsp.inlay_hint(bufnr, not enabled) -- very old API
			end
		end)
	end
end

-- mason-lspconfig: install + per-server handlers
local ok_mlc, mason_lspconfig = pcall(require, "mason-lspconfig")
if not ok_mlc then
	return
end

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
})

mason_lspconfig.setup_handlers({
	-- default handler
	function(server)
		lspconfig[server].setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})
	end,

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
						unusedLocalExclude = { "^_" }, -- allow _foo/_client
						globals = { "vim", "KeymapOptions", "Functions", "Functions_ok" },
					},
					hint = { enable = true },
					telemetry = { enable = false },
				},
			},
		})
	end,

	["ruff_lsp"] = function()
		lspconfig.ruff_lsp.setup({
			on_attach = function(client, bufnr)
				-- Keep Ruff for lint/code actions; let Pyright handle hovers/signature
				client.server_capabilities.hoverProvider = false
				client.server_capabilities.signatureHelpProvider = nil
				on_attach(client, bufnr)
			end,
			capabilities = capabilities,
		})
	end,

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
						typeCheckingMode = "basic", -- try "standard"/"strict" if you like
						autoImportCompletions = true,
					},
				},
			},
		})
	end,

	["yamlls"] = function()
		lspconfig.yamlls.setup({
			on_attach = on_attach,
			capabilities = capabilities,
			settings = {
				yaml = {
					validate = true,
					format = { enable = false }, -- keep conform.nvim as the formatter
					keyOrdering = false,
				},
			},
		})
	end,

	["ts_ls"] = function()
		lspconfig.ts_ls.setup({
			on_attach = on_attach,
			capabilities = capabilities,
			root_dir = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
			single_file_support = true,
		})
	end,
})
