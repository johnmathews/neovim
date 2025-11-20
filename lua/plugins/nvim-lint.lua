-- lua/plugins/nvim-lint.lua

local lint = require("lint")
lint.linters_by_ft = {
	bash = { "shellcheck" },
	javascript = { "eslint_d" },
	json = { "jsonlint" },
	lua = { "luacheck" },
	markdown = { "markdownlint-cli2" },
	python = { "ruff" },
	sh = { "shellcheck" },
	typescript = { "eslint_d" },
}

-- Run linters on keystroke (real-time feedback) and on save
local group = vim.api.nvim_create_augroup("Linting", { clear = true })
vim.api.nvim_create_autocmd(
	{ "BufEnter", "BufWinEnter", "BufWritePost", "TextChanged", "TextChangedI", "InsertLeave" },
	{
		group = group,
		callback = function()
			if lint.linters_by_ft[vim.bo.filetype] then
				lint.try_lint()
			end
		end,
	}
)

-- Manual
vim.keymap.set("n", "<leader>cl", function()
	require("lint").try_lint()
end, { desc = "Run lint" })
