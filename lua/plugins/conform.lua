-- lua/plugins/conform.lua

local conform = require("conform")
conform.setup({
	notify_on_error = true,
	format_on_save = function(bufnr)
		-- Don’t auto-format huge files
		local max = 200 * 1024
		local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
		if ok and stats and stats.size > max then
			return nil
		end
		return { timeout_ms = 1000, lsp_fallback = true }
	end,
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_format", "black" }, -- fast + stable formatting
		javascript = { "biome", "prettierd", "prettier" },
		typescript = { "biome", "prettierd", "prettier" },
		json = { "biome", "jq" },
		yaml = { "yamlfmt", "lsp" },
		markdown = { "prettierd", "prettier" },
		sh = { "shfmt" },
	},
	-- Prefer project-local binaries where possible
	formatters = { prettierd = { cwd = require("conform.util").root_file({ ".prettierrc", "package.json", ".git" }) } },
})
-- Optional mapping
vim.keymap.set({ "n", "v" }, "<leader>cf", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format file/range" })
