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

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
	return
end

local util = require("lspconfig.util")

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

local on_attach = function(client, bufnr)
	-- <leader>f uses conform, with LSP as a fallback
	vim.keymap.set(
		{ "n", "v" },
		"<leader>f",
		function()
			require("conform").format({
				lsp_fallback = true,
				async = true,
				timeout_ms = 3000,
			})
		end,
		KeymapBufferOptions({
			description = "Format (Conform with LSP fallback)",
			bufnr = bufnr,
		})
	)

	-- Disable LSP formatting for yamlls so Conform handles it exclusively
	if client.name == "yamlls" then
		client.server_capabilities.documentFormattingProvider = false
	end

	vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, KeymapOptions("Diagnostic - Open Location List")) -- view a list of errors and warnings

	vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, KeymapOptions("LSP Type Definition"))
	vim.keymap.set(
		"n",
		"gD",
		vim.lsp.buf.declaration,
		KeymapBufferOptions({ description = "LSP goto Declaration", bufnr = bufnr })
	)
	vim.keymap.set(
		"n",
		"gd",
		vim.lsp.buf.definition,
		KeymapBufferOptions({ description = "LSP goto Definition", bufnr = bufnr })
	)
	vim.keymap.set(
		"n",
		"gi",
		vim.lsp.buf.implementation,
		KeymapBufferOptions({ description = "LSP goto Implementation", bufnr = bufnr })
	)
	vim.keymap.set(
		"n",
		"gr",
		vim.lsp.buf.references,
		KeymapBufferOptions({ description = "LSP goto references", bufnr = bufnr })
	)
	vim.keymap.set(
		"n",
		"<C-k>",
		vim.lsp.buf.signature_help,
		KeymapBufferOptions({ description = "LSP signature help", bufnr = bufnr })
	)

	vim.keymap.set(
		"n",
		"<leader>wa",
		vim.lsp.buf.add_workspace_folder,
		KeymapBufferOptions({ description = "LSP add workspace folder", bufnr = bufnr })
	)
	vim.keymap.set(
		"n",
		"<leader>wr",
		vim.lsp.buf.remove_workspace_folder,
		KeymapBufferOptions({ description = "LSP remove workspace folder", bufnr = bufnr })
	)
	vim.keymap.set("n", "<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, KeymapBufferOptions({ description = "LSP list workspace folders", bufnr = bufnr }))
end

local lsp_flags = {
	debounce_text_changes = 500,
}

local capabilities = require("cmp_nvim_lsp").default_capabilities()

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

mason_lspconfig.setup({
	ensure_installed = { "tailwindcss", "lua_ls", "jsonls", "pyright", "sqls", "yamlls" },
	automatic_enable = true,
})

-- Common LSP opts
local default = {
	on_attach = on_attach,
	capabilities = capabilities,
	flags = lsp_flags,
}

-- Helper to merge tables
local function with_defaults(tbl)
	return vim.tbl_deep_extend("force", default, tbl or {})
end

-- Global/default config for "most" servers (applied before enable)
-- Tip: get a list of names with :lua =require("mason-lspconfig").get_available_servers()
for _, name in ipairs(require("mason-lspconfig").get_available_servers()) do
	-- we'll override these below, so skip them here
	if not vim.tbl_contains({ "lua_ls", "pyright", "sqls" }, name) then
		vim.lsp.config(name, with_defaults())
	end
end

-- Per-server overrides

-- Pyright
vim.lsp.config(
	"pyright",
	with_defaults({
		settings = {
			python = {
				analysis = {
					typeCheckingMode = "basic",
					autoSearchPaths = true,
					autoImportCompletions = true,
					diagnosticMode = "workspace",
					useLibraryCodeForTypes = true,
				},
			},
		},
	})
)

-- Lua
vim.lsp.config(
	"lua_ls",
	with_defaults({
		settings = {
			Lua = {
				telemetry = { enable = false },
				runtime = { version = "LuaJIT", path = vim.fn.expand("$VIMRUNTIME/lua") },
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
						line_length = 180,
					},
				},
				completion = { callSnippet = "Both" },
				diagnostics = {
					globals = {
						"KeymapBufferOptions",
						"KeymapOptions",
						"P",
						"pcall",
						"require",
						"string",
						"vim",
						"Functions",
					},
					disable = { "lowercase-global", "trailing-space" },
				},
			},
		},
	})
)

-- SQL (sqls)
vim.lsp.config(
	"sqls",
	with_defaults({
		cmd = { "sqls" }, -- installed via Mason
		filetypes = { "sql", "mysql" },
		root_dir = util.root_pattern("config.yml", ".git"),
		settings = {
			sqls = {
				connections = {
					-- Example (optional): configure DSNs for hover/completion across DBs
					-- {driver = "postgresql", dataSourceName = "host=127.0.0.1 port=5432 user=postgres dbname=mydb sslmode=disable" },
					-- {driver = "mysql",      dataSourceName = "user:pass@tcp(127.0.0.1:3306)/mydb" },
				},
			},
		},
	})
)
